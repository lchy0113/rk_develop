
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
