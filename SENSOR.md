
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

<br/>
<br/>
<br/>
<hr>

## kernel layer
 
<br/>
<br/>
<hr>

### sendor-dev.c

 code : kernel/drivers/input/sensors/sensor-dev.c 는 가속도, 자이로, 등 다양한 유형의 센서를 통합하는 코드.  

 - interrupt or polling
 sensor device node의 irq_enable이 존재하는 경우, interrupt mode. 그렇지 않은 경우, polling

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

```cpp
//hardware/rockchip/sensor/st/ProximitySensor.cpp
class ProximitySensor : public SensorBase {
    ...
    sensors_event_t mPendingEvent;
    ...
}


//hardware/libhardware/include/hardware/sensors.h
/**
  * sensors_event_t 구조체는 Android 센서프레임워크에서 사용되며,
  * 센서 이벤트를 저장하고 관리하는데 사용된다. 
  */
typedef struct sensors_event_t {
    int32_t version;
    int32_t sensor;
    int32_t type;
    int32_t reserved0;
    int32_t timestamp;
    union {
        union {
            float data[16];
            ...
            float distance; // distance in centimeters
        }
    }
    ...
}

//hardware/rockchip/sensor/st/ProximitySensor.h

```

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
                 *     -> setInitialState() ; 초기화 값
                 *         -> get abs value from input device
                 *            struct input_absinfo {
                 *                __s32 value;
                 *                __s32 minimum;
                 *                __s32 maximum;
                 *                __s32 fuzz;
                 *                __s32 flat;
                 *                __s32 resolution;
                 *            };
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
<hr>

## Sensor

> Sensor 는 개발하는 proximity sensor에 App layer 에서 access 하는 API를 제공. 
> Sensor 추가 시, 어떤 SENSOR_TYPE 사용할 지에 대해 정리.

 - TYPE_PROXIMITY : proximity sensor. wakeup 목적의 센서.  
 SensorEvent.values 를 통해 값을 전달.

 - TYPE_SIGNIFICANT_MOTION : motion trigger 센서.  
 이벤트가 발생화면 트리거 된 다음 자동으로 비활성화 됨.  
 센서는 절전 모드에 있는동안 계속 작동하며, 움직임이 감지되면 자동으로 Wakeup.   
 App layer에서는 triggger하기 위해 wakelock을 관리하지 않아도 됨.   
   
    * TriggerEvent : TriggerEventListener에 의해 호출되며, 트리거가 발생했을때, 보유값(시간, 값, 정보 등)을 관리한다.  
      values : TYPE_SIGNIFICANT_MOTION 의 경우, 값 필드의 길이는 1. 센서가 트리거되면 value[0] = 1.0   
        (1.0 만 허용)  

<br/>
<br/>
<br/>
<br/>
<hr>

# Develop

<br/>
<br/>
<br/>
<hr>

## datasheet

 - PS_CONF1 
   * PS_Duty : PS_Duty 필드는 근접센서의 작동 주기 설정. 센서가 얼마나 자주 근접 감지를 수행할지를 결정.
          1/40 = 40번 중 1번 작동, 1/320 = 320번 중 1번 작동
   * PS_PERS : 근접 센서의 지속성 설정. 센서가 근접 이벤트를 감지할 때, 몇번의 연속된 측정을 통해 이벤트를 확인 할지 결정. 
          1 = 1회 연속 측정,  4 = 4회 연속 측정
   * PS_IT   : 근접 센서의 적외선 발광 다이오드(IRED) 펄스의 통합 시간 설정. 센서가 물체와의 거리를 감지하는데 사용되는 시간 간격을 나타냄. 
          1T = 1 펄스 통합 시간,  9T = 9 펄스 통합 시간 
          통합 시간의 역할 : 센서가 적외선 신호를 수집하고 처리하는데 걸리는 시간을 의미. 
          더 긴 통합 시간은 더 많은 신호를 수집하여 감지 정확도를 높일 수 있지만,  응답시간이 길어진다. 
          짧은 응담 시간은 빠른 응답을 제공하지만 감지 정확도가 낮다.  
          즉, 선택 기준으로 짧은 통합시간(1T, 1.5T, 2T) 빠른 응답이 필요한 분야.
              긴 통합 시간(4T,8T,9T) 높은 감지 정확도가 필요한 분야.  

 - PS_CONF2
   * PS_HD : 근접 센서의 동작 범위 설정. 높은 범위 설정 시, 센서의 감지 범위와 정확도가 향상
     0 = PS output is 12 bits, 1 = PS output is 16 bits
   * PS_INT : 근접 센서의 인터럽트 설정 제어
     (0,0) = 인터럽트 비활성화, (0:1) = 오는거, (1:0) = 가는거, (1:1) = 오는거 가는거

 - PS_CONF3 
   * PS_MPS        : 근접 센서의 다중 펄스 설정 제어. 다중 펄스 설정시, 여러 펄스를 사용하여 감지 정확도 향상
     (0,0) = 1, (0,1) = 2, (1,0) = 4, (1,1) = 8
   * PS_SMART_PERS : 스마트 지속성 기능. 불필요한 트리거를 줄이고 정확한 감지를 보장. 
     0 = 비활성화, 1 = 활성화
   * PS_AF         : 강제 활성화 모드. 센서가 특정 조건에서 강제로 작동하도록 함.
   * PS_TRIG       : 근접 센서의 트리거 모드 설정. 특정조건에서 트리거 되어 데이터를 보고하도록 함. 
   * PS_SC_ADV     : 고급 자가 보정 기능. 센서가 환경 변화에 따라 자동으로 보정
   * PS_SC_EN      : 자가 보정 기능. 센서가 초기 설정 시, 자동으로 보정. 
  

 - PS_MS
   * PS_MS  : 근접 센서 모드를 설정하는 필드
     - 0(Proximity Normal Operation with Interrupt Function) : 설정된 임계값을 초과할 때 인터럽트를 발생. 이를 통해 근접 상태를 감지하고 적절한 동작을 수행
     - 1(Proximity Detection Logic Output Mode Enable) : 근접 센서가 논리 출력 모드로 동작. 근접 상태를 단순히 논리 신호로 출력. 추가적인 처리없이 근접 여부를 확인
   * PS_SP  : 근접센서의 햇빚 내성을 설정. 
     - 0 = typical sunlight capability 를 의미. 즉 센서가 일반적인 햇빛 조건에서 정상적으로 동작하도록 설정.
     - 1 = 1.5 typical sunlight capability 를 의미, 일반적인 햇빛 조건의 1.5 배 강한 햇빛에서도 동작할 수 있도록 설정 
   * PS_SPO : 
   * LED_I  : 적외선 LED의 전류를 설정하는데 사용. 

 - CANC_L, CANC_H
   * PS_CANC_L : 근접 센서의 PS Cancellation Level을 설정하는데 사용. 
                 근접 센서가 감지하는 배경 신호를 보정.(하위 바이트)
   * PS_CANC_H : (상위 바이트)

 - PS_THDL_L, PS_THDL_H
   * PS_THDL_L : 근접센서의 낮은 임계값을 설정하는데 사용. (하위 바이트)
   * PS_THDL_H :(상위 바이트) 

 - PS_THDH_L, PS_THDH_H 
   * PS_THDH_L : 근접센서의 높은 임계값을 설정하는데 사용. (하위 바이트)
   * PS_THDH_H : (상위 바이트)

<br/>
<br/>
<br/>
<hr>

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

<br/>
<br/>
<br/>
<hr>

## proximity sensor rule

| **level** | **distance** | **value**             |
|-----------|--------------|-----------------------|
| 4         | 60cm~        |        value <= 0x0e  |
| 3         | 40cm~60cm    | 0x0e < value <= 0x10  |
| 2         | 20cm~40cm    | 0x10 < value <= 0x2a  |
| 1         | ~20cm        | 0x2a < value          |



<br/>
<br/>
<br/>
<br/>
<hr>

# Reference 

<br/>
<br/>
<br/>
<hr>

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
