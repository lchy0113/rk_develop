
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
 
 +---VCNL4200---+
 |              |
 |           i2c+-----+
 |           int+-----+
 |              |
 +--------------+

```

<br/>
<br/>
<br/>
<br/>
<hr>

# Analyse


## kernel layer
 
 code : kernel/drivers/input/sensors/sensor-dev.c 는 가속도, 자이로, 등 다양한 유형의 센서를 통합하는 코드.  

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

<br/>
<br/>
<br/>
<br/>
<hr>

# Develop

branch feature/proximity_sensor

```bash
// 240603
kernel-4.19/drivers/iio/light/vcnl4000.c
kernel-4.19/Documentation/devicetree/bindings/iio/light/vcnl4000.txt
kernel-4.19/arch/arm64/boot/dts/rockchip/rk3568-edp-p04.dts
//device probe 확인.

kernel-4.19/drivers/input/sensors/accel/mxc6655xa.c
```

 - iio 장치

 iio 장치(industrial i/o) 서브시스템에 장치를 등록해서 Lumar, proximity 값이 올라오는것 확인. 

 - sensor dev
 

<br/>
<br/>
<br/>
<br/>
<hr>

# Reference 

## EVB

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

 - bug   
 아래 파일 권한이 없어 초기화 되지 않았음.   
   
```   
chmod 777 /dev/8452_daemon
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
