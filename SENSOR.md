
SENSOR
=====

 > sensor deviec 를 개발하는 wiki

<br/>
<br/>

[VISHAY,VCNL4200](#vishay-vcnl4200)
[Analyse](#analyse)
[Reference](#reference)

<br/>
<br/>
<br/>
<hr>

# VISHAY,VCNL4200 

 High Sensitivity Long Distance Proximity and Ambient Light Sensor (PS and ALS)


```bash
 
 +---VCNL4200---+     +---------HOST----------+
 |              |     |                       |
 |           i2c+-----+i2c5                   |
 |           int+-----+gpio4_d1               |
 |              |     |                       |
 +--------------+     +-----------------------+

```

<br/>
<br/>
<br/>
<br/>
<hr>

# Analyse


## kernel layer
 
<br/>
<br/>
<hr>

### sendor-dev.c

 code : kernel/drivers/input/sensors/sensor-dev.c 는 가속도, 자이로, 등 다양한 유형의 센서를 통합하는 코드.  

<br/>
<br/>
<br/>
<hr>



## hal layer

 Android *hardware/interfaces/sensor* 디렉토리는 Android 시스템에서 센서와 관련된 하드웨어 추상화 계층(HAL)  
 을 정의하는 곳.   
 다양한 물리적 센서에 대한 인터페이스를 제공하며, 애플리케이션에서 센서 데이터에 접근할 수 있도록 한다.  
  
 android.hardware.sensors@1.0  
 android.hardware.sensors@2.0  
 android.hardware.sensors@2.1  

 - 센서 정의  
   * hardware/interfaces/sensor 디렉토리에는 센서 HAL을 정의하는 .hal파일이 포함.  
   * 각 센서 유형에 대한 인터페이스가 정의되어 있음.  
  
 - 센서 데이터 흐름  
   * 센서 데이터를 하드웨어에서 읽어 Android Framework 에 전달.  

 - 센서 HAL 2.0  
   * 센서 HAL 2.0의 주요 문서는  hardware/interfaces/sensors/2.0/ISensors.hal 에 정의.  
  
```bash
struct sensor_module_t HAL_MODULE_INFO_SYN (hardware/rockchip/sensor/st/sensors.c)
  | 
setatic int open_sensors(...) (hardware/rockchip/sensor/st/sensors.c)
```

 - develop file

```bash

LOCAL_SRC_FILES := \
    sensors.c \
    nusensors.cpp \
    GyroSensor.cpp \
    InputEventReader.cpp \
    SensorBase.cpp \
    AkmSensor.cpp \
    MmaSensor.cpp \
    LightSensor.cpp \
    ProximitySensor.cpp \
    PressureSensor.cpp \
    TemperatureSensor.cpp
```

 - code

```c
// hardware/rockchip/sensor/st/sensors.c
static struct hw_module_methods_t sensors_module_methods = {
    .open = open_sensors
};
 struct sensors_module_t HAL_MODULE_INFO_SYM = {
    .common = {
        .tag = HARDWARE_MODULE_TAG,
        .version_major = 1,
        .version_minor = 0,
        .id = SENSORS_HARDWARE_MODULE_ID,
        .name = "Rockchip Sensors Module",
        .author = "The RKdroid Project",
        .methods = &sensors_module_methods,
    },
    .get_sensors_list = sensors__get_sensors_list
};

static int open_sensors(...)
    |
    +-> init_nusensors(module, device);
        /**
          * sensors_poll_context_t() // 센서 모듈 초기화 
          * light, proximity, mma, akm, gyro, pressure, temperature
          */
           |
           +-> ProximitySensor()
               /**
                 * SensorBase(PS_DEVICE_NAME, "proximity") // PS_DEVICE_NAME      "/dev/psensor"
                 * open_device() // 
                 * ioctl(PSENSOR_IOCTL_GET_ENABLED, &flags) -> sensor_dev module 
                 * sensor_dev module feedback status_cur(SENSOR_ON) -> hal
                 */ 
            /**
              * device version : 1.3
              * device.activate = poll__activate;
              * device.setDelay = poll__setDelay;
              * device.poll = poll__poll;
              * device.batch = poll__batch;
              * device.flush = poll__flush;
              */


```

<br/>
<br/>
<br/>
<br/>
<hr>

# Develop

## vcnl4000.c

branch feature/proximity_sensor

```bash
kernel-4.19/arch/arm64/boot/dts/rockchip/rk3568-edp-p04.dts
kernel-4.19/Documentation/devicetree/bindings/iio/light/vcnl4000.txt
kernel-4.19/drivers/iio/light/vcnl4000.c
  |  
  |  struct vcnl4000_data {
  |     struct i2c_client *client;
  |     enum vcnl4000_device_ids id;
  |     int rev;
  |     int al_scale;
  |     const struct vcnl4000_chip_spec *chip_spec;
  |     struct mutex vcnl4000_lock;
  |     struct vcnl4200_channel vcnl4200_al;
  |     struct vcnl4200_channel vcnl4200_ps;
  |  };
  |  
  |    struct vcnl4200_channel {
  |        u8 reg;
  |        ktime_t last_measurement;
  |        ktime_t sampling_rate;
  |        struct mutex lock;
  |    };
  |
  +-> vcnl4000_probe(...)
    |  /**
    |    * iio device 메모리 할당 
    |    */
    |  
    +-> vcnl4200_init(struct vcnl4000_data *data)
    |     /**
    |       * read VCNL4200 device id(id : 0x58, rev : 0x10)
    |       * write 0x00 to VCNL4200 Ambient light configuration(0x00) ; ALS power on
    |       * write 0x00 to VCNL4200 Proximity configuration(0x03) ; PS power on
    |       * vcnl4200_al.reg = VCNL4200_AL_DATA(0x09)
    |       * vcnl4200_ps.reg = VCNL4200_PS_DATA(0x08)
    |       * vcnl4200_al.sampling_rate = 54ms (54000 * 1000 ns)
    |       * vcnl4200_ps.sampling_rate = 4.2ms (4200 * 1000 ns)
    |       * al_scale = 24000;
    |       * vcnl4200_al.last_measurement = 0ms
    |       * vcnl4200_ps.last_measurement = 0ms
    |       * init vcnl4200_al, vcnl4200_ps mutex
    |       */
    |   
    +-> indio_dev->info = vcnl4000_info; // reference include/linux/iio/iio.h
    +-> indio_dev->channels = vcnl4000_channels; // support IIO_LIGHT, IIO_PROXIMITY
    +-> indio_dev->modes = INDIO_DIRECT_MODE;
    +-> // iio device 커널 등록

    |   +-> vcnl4200_measure(data, &data->vcnl4200_al, val);
    +-> vcnl4200_measure_proximity(struct vcnl4000_data *data, int *val)
        +-> vcnl4200_measure(data, &data->vcnl4200_pl, val);


```

 - iio 장치
  
  code : kernel/drivers/iio/industrialio-core.c
  __devm_iio_device_register를 통해 등록

 iio 장치(industrial i/o) 서브시스템에 장치를 등록해서 Lumar, proximity 값이 올라오는것 확인. 

```bash

sys/bus/iio/devices/iio:device1 # ls
dev  in_illuminance_raw  in_illuminance_scale  in_proximity_raw  name  of_node  power  subsystem  uevent

/dev/iio:device1

```

 - sensor dev
 

<br/>
<br/>
<br/>
<br/>
<hr>

# Reference 

## rk3568-evb

 rk3568 evb 는 Gyroscaope + G-sensor 을 support 함.   

```bash
 
 +---MXC6655XA@15--+
 |                 |
 |              i2c+-----+i2c5
 |              int+-----+
 |                 |
 +-----------------+
```

 Accelerometer sensor   

```dtb
&i2c5 {
    status = "okay";

    mxc6655xa: mxc6655xa@15 {
        status = "okay";
        compatible = "gs_mxc6655xa";
        pinctrl-names = "default";
        pinctrl-0 = <&mxc6655xa_irq_gpio>;
        reg = <0x15>;
        irq-gpio = <&gpio3 RK_PC1 IRQ_TYPE_LEVEL_LOW>;
        irq_enable = <0>;
        poll_delay_ms = <30>;
        type = <SENSOR_TYPE_ACCEL>;
        power-off-in-suspend = <1>;
        layout = <1>;
    };
};
```
 
 - code

```c
// drivers/input/sensors/accel/mxc6655xa.c
gsensor_mxc6655_probe(...)
    |    sensor_register_device(client, NULL, devid, &gsensor_mxc6655_ops);
    +-> int sensor_register_device(struct i2c_client *client,
                    struct sensor_platform_data *slave_pdata,
                    const struct i2c_device_id *devid,
                    struct sensor_operate *ops)
                    
            // drivers/input/sensors/sensor-dev.c
```

```bash
# dumpsys sensorservice 
Captured at: 16:45:16.929
Sensor Device:
Total 1 h/w sensors, 1 running 0 disabled clients:
Sensor List:
0000000000) Accelerometer sensor      | The Android Open Source Project | ver: 1 | type: android.sensor.accelerometer(1) | perm: n/a | flags: 0x00000000
        continuous | minRate=5.00Hz | maxRate=142.86Hz | no batching | non-wakeUp | 
        Fusion States:
        9-axis fusion disabled (0 clients), gyro-rate= 200.00Hz, q=< 0, 0, 0, 0 > (0), b=< 0, 0, 0 >
        game fusion(no mag) disabled (0 clients), gyro-rate= 200.00Hz, q=< 0, 0, 0, 0 > (0), b=< 0, 0, 0 >
        geomag fusion (no gyro) disabled (0 clients), gyro-rate= 200.00Hz, q=< 0, 0, 0, 0 > (0), b=< 0, 0, 0 >
        Recent Sensor events:
        Active sensors:
        Socket Buffer size = 39 events
        WakeLock Status: not held 
        Mode : NORMAL
        Sensor Privacy: disabled
        0 active connections
        0 direct connections
        Previous Registrations:
```
  
 - hal code  
 /hardware/rockchip/sensor/st/Android.mk  
  
 - log   
  Tag : SensorsHal, SensorService   
  
```Makefile
# Sensor HAL
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-service \
    android.hardware.sensors@1.0-impl \
    sensors.$(TARGET_BOARD_HARDWARE)
```

<br/>
<br/>
<br/>
<hr>


## rk3326-evb

```dtb
    ls_stk3410: light@48 {
        compatible = "ls_stk3410";
        status = "okay";
        reg = <0x48>;
        type = <SENSOR_TYPE_LIGHT>;
        irq_enable = <0>;
        als_threshold_high = <100>;
        als_threshold_low = <10>;
        als_ctrl_gain = <2>; /* 0:x1 1:x4 2:x16 3:x64 */
        poll_delay_ms = <100>;
    };

    ps_stk3410: proximity@48 {
        compatible = "ps_stk3410";
        status = "okay";
        reg = <0x48>;
        type = <SENSOR_TYPE_PROXIMITY>;
        //pinctrl-names = "default";
        //pinctrl-0 = <&gpio2_c3>;
        //irq-gpio = <&gpio0 RK_PB7 IRQ_TYPE_LEVEL_LOW>;
        //irq_enable = <1>;
        ps_threshold_high = <0x200>;
        ps_threshold_low = <0x100>;
        ps_ctrl_gain = <3>; /* 0:x1 1:x4 2:x16 3:x64 */
        ps_led_current = <3>; /* 0:12.5mA 1:25mA 2:50mA 3:100mA */
        poll_delay_ms = <100>;
    };
```


code 

```c
static int proximity_stk3410_probe(struct i2c_client *client, const struct i2c_device_id *devid)
    |
    +-> sensor_register_device(client, NULL, devid, &psensor_stk3410_ops);
        |
        +-> int sensor_register_device(...)
            /**
              * drivers/input/sensors/sensor-dev.c
              */
                static int sensor_probe(...)
                    /**
                      * parse device tree
                      * sensor_chip_init(...)
                      * 입력장치 할당 및 초기화
                      */
(...)

struct sensor_operate psens0r_stk3410_ops = {
    .name            = "ps_stk3410",
    .type            = SENSOR_TYPE_PROXIMITY,
    .id_i2c          = PROXIMITY_ID_STK3410,
    .read_reg        = DATA1_PS,
    .read_len        = 2,
    .id_reg          = SENSOR_UNKNOW_DATA,
    .id_data         = SENSOR_UNKNOW_DATA,
    .precision       = 16,
    .ctrl_reg        = STK_STATE,
    .int_status_reg  = STK_FLAG,
    .range           = {100, 65535},
    .brightness      = {10, 255},
    .trig            = IRQF_TRIGGER_LOW | IRQF_ONESHOT | IRQF_SHARED,
    .active          = sensor_active,
    .init            = sensor_init,
    .report          = sensor_report_value,
};


static int sensor_init(struct i2c_client *client)
    |
    +-> sensor->ops->active(client, 0, 0)
        |
        +-> static int sensor_active(...)
            /**
              * read ctrl_regs
              */




```

<br/>
<br/>
<br/>
<hr>

## micom

```bash
// addr : 0x00 ALS_CONF
// val : 0x41; 0100 0001 : ALS_integration time, persistence, interrupt, and function enable / disable

// addr : 0x03 PS_CONF1, PS_CONF2
// val : 0x6a; 0110 1010 : PS duty ratio(1/320), persistence(3), integration time(9T), and PS enable / disable(enable)
// val : 0x0b; 0000 1011 : PS_HD(output 16bit), PS interrupt trigger method(trigger by closing)

// addr : 0x04 PS_CONF3, PS_MS
// val : 0x70; 0111 0000 : PS multi pulse(8 multi pulses), active force mode, enable sunlight cancellation
// val : 0x07; 0000 0111 : PS mode selection, sunlight capability, sunlight protection mode
```


<br/>
<br/>
<br/>
<hr>

## other board

 - ps_stk3410
 - ps_stk3171
 - ps_em3071x
 - ps_ap321xx
 - proximity_al3006
