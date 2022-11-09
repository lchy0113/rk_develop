# V4L

## V4L 관련 용어 

	- pad : pad는 entity 와 entity 간 연결 end-point 입니다.
	- link : 2개의 pad간 연결 인터페이스 입니다. data는 source pad에서 sink pad로 이동합니다.
	- media device : include/media/media-device.h 에 정의된 struct media_device 의 인스턴스 입니다. 
	- entities : include/media/media-entity.h 에 정의된 struct media_entity 의 인스턴스 입니다. v4l2_subdev 또는 video_device instances 인스턴스와 같은 구조의 higher-level structure입니다.


 - *media_device*

```c
struct media_device {
	struct device *dev;
	struct media_devnode *devnode;
	char model[32];
	char driver_name[32];
	char serial[40];
	char bus_info[32];
	u32 hw_revision;
	u64 topology_version;
	u32 id;
	struct ida entity_internal_idx;
	int entity_internal_idx_max;
	struct list_head entities;
	struct list_head interfaces;
	struct list_head pads;
	struct list_head links;
	struct list_head entity_notify;
	struct mutex graph_mutex;
	struct media_graph pm_count_walk;
	void *source_priv;
	int (*enable_source)(struct media_entity *entity, struct media_pipeline *pipe);
	void (*disable_source)(struct media_entity *entity);
	const struct media_device_ops *ops;
	struct mutex req_queue_mutex;
	atomic_t request_id;
};
```

 - *v4l2_subdev*

```c
struct v4l2_subdev {
#if defined(CONFIG_MEDIA_CONTROLLER)
	struct media_entity entity;
#endif
	struct list_head list;
	struct module *owner;
	bool owner_v4l2_dev;
	u32 flags;
	struct v4l2_device *v4l2_dev;
	const struct v4l2_subdev_ops *ops;
	const struct v4l2_subdev_internal_ops *internal_ops;
	struct v4l2_ctrl_handler *ctrl_handler;
	char name[V4L2_SUBDEV_NAME_SIZE];
	u32 grp_id;
	void *dev_priv;
	void *host_priv;
	struct video_device *devnode;
	struct device *dev;
	struct fwnode_handle *fwnode;
	struct list_head async_list;
	struct v4l2_async_subdev *asd;
	struct v4l2_async_notifier *notifier;
	struct v4l2_async_notifier *subdev_notifier;
	struct v4l2_subdev_platform_data *pdata;
};
```

 - *v4l2_subdev_ops*

```c
struct v4l2_subdev_ops  : Subdev operations
	|
	+-> struct v4l2_subdev_core_ops // core : defines core ops callbacks for subdevs
	|	+-> .s_power : puts subdevice in power saving mode(on==0) or normal operation mode(on==1)
	|	+-> .ioctl : called at the end of ioctl() syscall handler at the v4l2 core.used to provide support for private ioctls used on the driver
	|	+-> .compat_ioctl32 : called when a 32 bits applications used a 64 bits kernel, in order to fix data passed from/to userspace.in order to fix data passed from/to userspace.
	|
	+-> struct v4l2_subdev_video_ops // video : callbacks used when v4l device was opened in video mode
	|	+-> .s_stream :  used to notify the driver that a video stream will start or has stopped
	|	+-> .g_frame_interval : callback for VIDIOC_SUBDEV_G_FRAME_INTERVAL ioctl handler code
	|	+-> .g_mbus_config : get supported mediabus configurations
	|
	+-> struct v4l2_subdev_pad_ops // pad : v4l2-subdev pad level operations
		+-> .enum_mbus_code : callback for VIDIOC_SUBDEV_ENUM_MBUS_CODE ioctl handler code.
		+-> .enum_frame_size :  callback for VIDIOC_SUBDEV_ENUM_FRAME_SIZE ioctl hndler code.
		+-> .enum_frame_interval : callback for VIDIOC_SUBDIEV_ENUM_FRAME_INTERVAL() ioctl handler code.
		+-> .get_fmt : callback for VIDIOC_SUBDEV_G_FMT ioctl handler code.
		+-> .set_fmt : callback for VIDIOC_SUBDEV_S_FMT ioctl handler code.
```

 - *v4l2_subdev_internal_ops*

```c
struct v4l2_subdev_internal_ops : v4l2 subdev internal ops
	|
	+-> .open  : called when the subdev device node is opened by an application.
	+-> .close : called when the subdev device node is closed.

```

 - *v4l2_ctrl_ops*

```c
struct v4l2_ctrl_ops : the control operations that the driver has to provide
	|
	+-> .g_volatile_ctrl : get a new value for this control, generally only relevant for volatile controls.
	+-> .try_ctrl : test whether the control's value is valid.
	+-> .s_ctrl : actually set the new control value.


```

 - *v4l2_ctrl_handler*

```c
struct v4l2_ctrl_handler
```

----- 

## 1. v4l subdev driver 설명
 - subdev driver(sensor driver)는 CIF, RKISP와 독립적인 코드 입니다. remote-endpoint에 의해 async적으로 등록되어 통신 합니다.
 - Media Controller 구조에서 Sensor는 subdev로 사용되며 pad를 통해 cif, isp 또는 mipi_phy에 link 됩니다.
 - sensor driver 를 5 part로 분리하여 설명합니다.
   * power-on sequence (datasheet에 따른 vdd, reset, powerdown, clk, etc).
   * configure sensor register (센서의 resolution, format, etc).
   * v4l2_subdev_ops callback funcation.
   * v4l2 controller 추가(fps, exposure, gain, test pattern, etc).
   * .probe() function 와 media control, v4l2 sub device 초기화 코드.

 **Note** : driver를 작성한 후, documentation을 추가해야 합니다.
 - dts level에서 센서 driver를 작성할 때, 일반적으로 아래 field가 필요합니다.
   * clk, io mux
   * regulator and gpio (power-on sequence에 필요한..) 
   * cif 또는 isp 모듈과 link에 필요한 node
		[Documentation/devicetree/bindings/media/i2c/tp2860.txt](./attachment/V4L/tp2860.txt)

### 1.1 power-on sequence
 - sensor장치 마다 다른 power-on timing을 요구합니다.
   * mclk, vdd, reset, power status 구성에 따라 i2c 통신과 데이터가 출력 됩니다.
 - datasheet를 통해 정보가 제공됩니다.  
   * ex. tp2860 모듈은 __tp2860_power_on()를 사용하여 sensor power up 합니다.

```c
static int __tp2860_power_on(struct tp2860 *tp2860)
{
	DEGMSG();
	int ret;
	u32 delay_us;
	struct device *dev = &tp2860->client->dev;

	if (!IS_ERR(tp2860->reset_gpio)) {
		gpiod_set_value_cansleep(tp2860->reset_gpio, 0);
		usleep_range(10 * 1000, 20 * 1000);
		gpiod_set_value_cansleep(tp2860->reset_gpio, 1);
		usleep_range(10 * 1000, 20 * 1000);
		gpiod_set_value_cansleep(tp2860->reset_gpio, 0);
	}
	usleep_range(10 * 1000, 20 * 1000);

	return 0;
}

static void __tp2860_power_off(struct tp2860 *tp2860)
{
	DEGMSG();

	if (!IS_ERR(tp2860->reset_gpio))
		gpiod_set_value_cansleep(tp2860->reset_gpio, 1);
}

```  
   * (작성 예정)	 
 - power-on 여부 확인하기. 
   * sensor 의 chip id를 read하여 성공적으로 power-up이 되었는지 여부를 확인 할 수 있습니다.

### 1.2 configure sensor regiser 
 - tp2860 센서를 구성하는 register 데이터를 data sheet를 참고하여 작성합니다.
 - tp2860 에서 struct tp2860_mode에는 sensor mode에 따른 초기화 register가 정의 되어 있습니다. 
   * resolution, mbus, etc 
```c
/**
 * @brief sensor can support the information of each mode
 * The RKISP driver requires the use of use controls provided by the framework. 
 * The cameras sensor driver must implement the following control functions
 * .bus_fmt : sensor output format, reference MEDIA_BUS_FMT table
 * .width : the effective image width
 * .height : the effective image height
 * .max_fps : Image FPS, denominator/numerator is fps
 * *reg_list : Register list
 */
struct tp2860_mode {
	u32 width;
	u32 height;
	struct v4l2_fract max_fps;
	u32 field;
	u32 bus_fmt;
	const struct regval *reg_list;
};
```

### 1.3 v4l2_subdev_ops callback function
 - **v4l2_subdev_ops** callback function은 sensor 드라이버의 logic control의 core입니다. 
   * callback function : include/meida/v4l2-subdev.h 
   * 최소한으로  v4l2_subdev_ops의 callback function 을 따라야 합니다.





-----

  
1. i2c sub장치이므로 i2c driver로 구현 합니다.   

  1.1 i2c_driver의 아래 내용을 구현합니다.

  ```c
  struct driver.name
  struct driver.pm
  struct driver.of_match_table
  probe function
  remove function
  ```
  
  1.2 probe function에 대한 설명입니다.  
  
 - dts로 부터 resource 를 얻습니다.   
	ex. rockchip,camera-module-xxx와 같은 resource는 camera module에 대한 resourlce를 제공합니다.

 - v4l2 장치 media entity 초기화.  
	v4l2_i2c_subdev_init을 사용하여 subdev 장치로 등록합니다.

2. v4l2 sub-device driver를 구현합니다.



-----

## media-ctl / v4l2-ctl 툴


 - media-ctl
	 /dev/mediaX와 같은 media 장치를 통해 동작하며, media topology 에서 각 노드의 형식 및 크기, 링크를 관리합니다.

 - v4l2-ctl
	 /dev/videoX와 같은 비디오 장치를 통해 동작하며, set_fmt, reqbuf, qbuf, dqbuf, stream_on, stream_off와 같은 동작을 수행합니다.
	 

