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

## v4l subdev driver 설명
  
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
	 

