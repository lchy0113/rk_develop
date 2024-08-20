# DEVICE 
> aosp rk3568 device 에 대한 문서 입니다.

----

<br/>
<br/>
<br/>
<br/>

## Device Map

### serial
 - upper layer에는 아래와 같은 serial node로 제공.
 - rgb(p04), edp(p03)

| **serial dev node** 	| **connect device**    	|
|-------------------	|---------------------------|
| /dev/ttyS0        	| rs485;device control  	|
| /dev/ttyS1        	| rs485;sub-phone,door lock	|
| /dev/ttyS2        	| rs485;rfid door        	|
| /dev/ttyS3        	| zigbee                	|
| /dev/ttyS4        	| bluetooth                	|


 - rk3568_rgb_p02 board
	  
```bash
+---------------+
| [RK3568]      |
|               |
|  SERIAL0------+ <-----> zigbee	(rk3568_rgb_p01: micom)
|               |
|  SERIAL1-+-M0-+
|          +-M1-+
|               |
|  SERIAL2-+-M0-+ <----> device control;rs485  (rk3568_rgb_p01: debug)
|          +-M1-+
|               |
|  SERIAL3-+-M0-+	(rk3558_rgb_p01: pstn modem)
|          +-M1-+
|               |
|  SERIAL4-+-M0-+	(rk3568_rgb_p01: device control;rs485)
|          +-M1-+ <----> debug
|               |
|  SERIAL5-+-M0-+
|          +-M1-+
|               |
|  SERIAL6-+-M0-+ <----> sub;rs485
|          +-M1-+
|               |
|  SERIAL7-+-M0-+
|          +-M1-+
|               |
|  SERIAL8-+-M0-+
|          +-M1-+
|               |
|  SERIAL9-+-M0-+ <----> mcu(temp)
|          +-M1-+
|               |
+---------------+
```

 - rk3568_rgb_p05 board

```bash
+---------------+
| [RK3568]      |
|               |
|  SERIAL0------+ <----> device control;rs485(/w GPIO0_C4) aliases:/dev/ttyS0
|               |
|  SERIAL1-+-M0-+ <----> loby;rs485 aliases:/dev/ttyS3
|          +-M1-+
|               |
|  SERIAL2-+-M0-+ <----> none aliases:/dev/ttyS2
|          +-M1-+
|               |
|  SERIAL3-+-M0-+
|          +-M1-+
|               |
|  SERIAL4-+-M0-+ <----> sub device;rs485 sub-phone aliases:/dev/ttyS1
|          +-M1-+
|               |
|  SERIAL5-+-M0-+
|          +-M1-+
|               |
|  SERIAL6-+-M0-+ <----> bluetooth;rtscts aliases:/dev/ttyS7
|          +-M1-+
|               |
|  SERIAL7-+-M0-+ <----> rfid door;rs485 aliases:/dev/ttyS4
|          +-M1-+
|               |
|  SERIAL8-+-M0-+
|          +-M1-+
|               |
|  SERIAL9-+-M0-+ <----> debug
|          +-M1-+
|               |
+---------------+
```


 - rk3568_edp_p02 board
	  
```bash
+---------------+
| [RK3568]      |
|               |
|  SERIAL0------+ <----> device control;rs485(/w GPIO0_C4) aliases:serial0
|               |
|  SERIAL1-+-M0-+
|          +-M1-+
|               |
|  SERIAL2-+-M0-+ <----> zigbee(to be) aliases:serial2
|          +-M1-+
|               |
|  SERIAL3-+-M0-+
|          +-M1-+
|               |
|  SERIAL4-+-M0-+ <----> sub device;rs485(w/ GPIO1_A5) aliases:serial1
|          +-M1-+
|               |
|  SERIAL5-+-M0-+
|          +-M1-+
|               |
|  SERIAL6-+-M0-+ <----> ladar aliases:serial3
|          +-M1-+
|               |
|  SERIAL7-+-M0-+
|          +-M1-+
|               |
|  SERIAL8-+-M0-+
|          +-M1-+
|               |
|  SERIAL9-+-M0-+ <----> debug
|          +-M1-+
|               |
+---------------+
```
 - rk3568_edp_p03 board
	  
```bash
+---------------+
| [RK3568]      |
|               |
|  SERIAL0------+ <----> device control;rs485(/w GPIO0_C4) aliases:serial0
|               |
|  SERIAL1-+-M0-+
|          +-M1-+
|               |
|  SERIAL2-+-M0-+ <----> zigbee(to be) aliases:serial2
|          +-M1-+
|               |
|  SERIAL3-+-M0-+
|          +-M1-+
|               |
|  SERIAL4-+-M0-+ <----> sub device;rs485(w/ GPIO1_A5) aliases:serial1
|          +-M1-+
|               |
|  SERIAL5-+-M0-+ <----> 
|          +-M1-+
|               |
|  SERIAL6-+-M0-+ <----> ladar aliases:serial3
|          +-M1-+
|               |
|  SERIAL7-+-M0-+
|          +-M1-+
|               |
|  SERIAL8-+-M0-+
|          +-M1-+
|               |
|  SERIAL9-+-M0-+ <----> debug
|          +-M1-+
|               |
+---------------+
```



 - rk3568_rgb_p04 board
	  
```bash
+---------------+
| [RK3568]      |
|               |
|  SERIAL0------+ <----> device control;rs485(/w GPIO0_C4) aliases:serial0
|               |
|  SERIAL1-+-M0-+
|          +-M1-+
|               |
|  SERIAL2-+-M0-+ <----> zigbee aliases:serial3
|          +-M1-+
|               |
|  SERIAL3-+-M0-+ <----> rfid door	aliases:serial2
|          +-M1-+
|               |
|  SERIAL4-+-M0-+ <----> sub device;rs485(w/ GPIO1_A5) door lock aliases:serial1
|          +-M1-+
|               |
|  SERIAL5-+-M0-+
|          +-M1-+
|               |
|  SERIAL6-+-M0-+ <----> bluetooth
|          +-M1-+
|               |
|  SERIAL7-+-M0-+
|          +-M1-+
|               |
|  SERIAL8-+-M0-+
|          +-M1-+
|               |
|  SERIAL9-+-M0-+ <----> debug
|          +-M1-+
|               |
+---------------+
```

 - rk3568_edp_p03 board
	  
```bash
+---------------+
| [RK3568]      |
|               |
|  SERIAL0------+ <----> device control;rs485(/w GPIO0_C4) aliases:serial0
|               |
|  SERIAL1-+-M0-+
|          +-M1-+
|               |
|  SERIAL2-+-M0-+ <----> zigbee aliases:serial3
|          +-M1-+
|               |
|  SERIAL3-+-M0-+ <----> rfid door	aliases:serial2
|          +-M1-+
|               |
|  SERIAL4-+-M0-+ <----> sub device;rs485(w/ GPIO1_A5) door lock aliases:serial1
|          +-M1-+
|               |
|  SERIAL5-+-M0-+
|          +-M1-+
|               |
|  SERIAL6-+-M0-+ <----> bluetooth
|          +-M1-+
|               |
|  SERIAL7-+-M0-+
|          +-M1-+
|               |
|  SERIAL8-+-M0-+
|          +-M1-+
|               |
|  SERIAL9-+-M0-+ <----> debug
|          +-M1-+
|               |
+---------------+
```

 - rk3568_edp_p04 board
	  
```bash
+---------------+
| [RK3568]      |
|               |
|  SERIAL0------+ <----> device control;rs485(/w GPIO0_C4) aliases:serial0
|               |
|  SERIAL1-+-M0-+
|          +-M1-+
|               |
|  SERIAL2-+-M0-+ <----> zigbee aliases:serial3
|          +-M1-+
|               |
|  SERIAL3-+-M0-+ <----> rfid door	aliases:serial2
|          +-M1-+
|               |
|  SERIAL4-+-M0-+ <----> sub device;rs485(w/ GPIO1_A5) door lock aliases:serial1
|          +-M1-+
|               |
|  SERIAL5-+-M0-+ <----> micom(voice)
|          +-M1-+
|               |
|  SERIAL6-+-M0-+ <----> bluetooth
|          +-M1-+
|               |
|  SERIAL7-+-M0-+
|          +-M1-+
|               |
|  SERIAL8-+-M0-+
|          +-M1-+
|               |
|  SERIAL9-+-M0-+ <----> debug
|          +-M1-+
|               |
+---------------+
```




----

### i2c

- rk3568_rgb_p03 board

```bash
+---------------+
| [RK3568]      |
|               |
|    I2C0-------+
|               |
|    I2C1-------+ <----> hot key
|               |
|    I2C2--+-M0-+
|          +-M1-+ <----> internal cam
|               |
|    I2C3--+-M0-+ <----> touch ic
|          +-M1-+
|               |
|    I2C4--+-M0-+ <----> pmic, decoder
|          +-M1-+
|               |
|    I2C5--+-M0-+
|          +-M1-+ <----> audio codec, proximity/ambient light sensor
|               |
|    I2C_HDMI---+
+---------------+
```

- rk3568_edp_p02 board

```bash
+---------------+
| [RK3568]      |
|               |
|    I2C0-------+
|               |
|    I2C1-------+ <----> hot key
|               |
|    I2C2--+-M0-+
|          +-M1-+ <----> internal cam(option)
|               |
|    I2C3--+-M0-+ <----> touch ic
|          +-M1-+
|               |
|    I2C4--+-M0-+ <----> pmic
|          +-M1-+
|               |
|    I2C5--+-M0-+
|          +-M1-+ <----> audio codec, decoder
|               |
|    I2C_HDMI---+
+---------------+
```

- rk3568_rgb_p04 board

```bash
+---------------+
| [RK3568]      |
|               |
|    I2C0-------+
|               |
|    I2C1-------+ <----> hot key, touch ic
|               |
|    I2C2--+-M0-+
|          +-M1-+ <----> internal cam
|               |
|    I2C3--+-M0-+
|          +-M1-+
|               |
|    I2C4--+-M0-+ <----> pmic, decoder
|          +-M1-+
|               |
|    I2C5--+-M0-+
|          +-M1-+ <----> audio codec, proximity/ambient light sensor
|               |
|    I2C_HDMI---+
+---------------+
```

- rk3568_edp_p03 board

```bash
+---------------+
| [RK3568]      |
|               |
|    I2C0-------+
|               |
|    I2C1-------+ <----> hot key, touch ic
|               |
|    I2C2--+-M0-+
|          +-M1-+ <----> internal cam(option)
|               |
|    I2C3--+-M0-+ 
|          +-M1-+
|               |
|    I2C4--+-M0-+ <----> pmic, decoder
|          +-M1-+
|               |
|    I2C5--+-M0-+
|          +-M1-+ <----> audio codec
|               |
|    I2C_HDMI---+
+---------------+
```

- rk3568_rgb_p05 board

```bash
+---------------+
| [RK3568]      |
|               |
|    I2C0-------+
|               |
|    I2C1-------+ <----> rtc, hot key, touch ic
|               |
|    I2C2--+-M0-+
|          +-M1-+ <----> internal cam
|               |
|    I2C3--+-M0-+ <----> touch ic
|          +-M1-+
|               |
|    I2C4--+-M0-+ <----> pmic, decoder
|          +-M1-+
|               |
|    I2C5--+-M0-+
|          +-M1-+ <----> audio codec
|               |
|    I2C_HDMI---+
+---------------+
```


----

### vop

- rk3568 support vop

```bash
+---------------+
| [RK3568]      |
|               |
|   Port0------ + <----> dsi0, dsi2, edp, hdmi 
|               |
|               |
|   Port2------ + <----> dsi0, dsi1, edp, hdmi, lvcd
|               |
|               |
|   Port2------ + <----> lvds, rgb 
|               |
|               |
+---------------+
```



- rk3568_rgb_p01, rk3568_rgb_p02 board

```bash
+---------------+
| [RK3568]      |
|               |
|   Port0------ + <----> hdmi
|               |
|               |
|   Port2------ +
|               |
|               |
|   Port2------ + <----> rgb565 
|               |
|               |
+---------------+
```

- rk3568_edp_p01 board

```bash
+---------------+
| [RK3568]      |
|               |
|   Port0------ + <----> hdmi
|               |
|               |
|   Port2------ + <----> edp
|               |
|               |
|   Port2------ + 
|               |
|               |
+---------------+
```

----

### io power domain

> rk3568_rgb_p01, rk3568_rgb_p02 board

```bash
+--------------------------------------------------------------------------------------+
| [RK3568]                                                                             |
|                                                                                      |
|     [io domain]    [pin num]    [supply power net name]    [voltage]                 |
|                                                                                      |
|     PMUIO1         Y20          VCC3V3_PMU                 3.3V                      | 
|                                                                                      |
|     PMUIO2         W19          VCC3V3_PMU                 3.3V                      |
|                                                                                      |
|     VCCIO1         H17          VCCIO_ACODEC               3.3V                      |
|                                                                                      |
|     VCCIO2         H18          VCCIO_FLASH                1.8V                      |
|                   /* pin "FLASH_VOL_SEL" must be logic High,                         |
|                     if VCCIO_FLASH=3.3V, FLASH_VOL_SEL must be logic low             |
|                     and VCCIO_FLASH=1.8V, FLASH_VOL_SEL must be logic high */        |
|                                                                                      |
|     VCCIO3         L22          VCCIO_SD                   3.3V                      |
|                                                                                      |
|     VCCIO4         J21          VCC_3V3                    3.3V                      |
|                                                                                      |
|     VCCIO5         V10 V11      VCC_3V3                    3.3V                      |
|                                                                                      |
|     VCCIO6         R9 U9        VCC_3V3                    3.3V                      |
|                                                                                      |
|     VCCIO7         V12          VCC_3V3                    3.3V                      |
|                                                                                      |
+--------------------------------------------------------------------------------------+
```

----

### gpio

#### 사용되는 GPIO 인터페이스 통일
 > naming rule : feature(대문자)_index(0~)


|        | 용도                                                       | standardize_name                       |
|--------|------------------------------------------------------------|----------------------------------------|
| input  | 도어장치의 도어 버튼 눌림 입력 신호 감지                   | DOORBUTTON_0 (door Button)             |
| input  | 도어장치의 모션 센서 입력 신호 감지 (Passive Infrared)     | DOORPIR_0 (door PIR)                   |
| input  | 방범1 센서의 입력 신호 감지                                | SECURITYSIGNAL_0 (security Signal)     |
| input  | 방범2 센서의 입력 신호 감지                                | SECURITYSIGNAL_1 (security Signal)     |
| input  | 비상 센서의 입력 신호 감지                                 | EMERGENCYSIGNAL_0 (emergency Signal)   |
| input  | 하향식 피난구1 입력 신호 감지                              | ESCAPESIGNAL_0 (escape Signal)         |
| input  | 하향식 피난구2 입력 신호 감지                              | ESCAPESIGNAL_1 (escape Signal)         |
| output | HDMI to CVBS 컨버터 초기화 (세컨드 디스플레이 사용시 세팅) | SUBDISPLAYINIT_0 (sub-display Initialize) |
| output | 도어장치에게 도어 오픈 신호 출력                           | DOOROPEN_0 (door Open)                 |
| output | 도어장치에게 도어 파워컨트롤 신호 출력 (카메라 활성화)     | DOORPOWERCTL_0 (door Powercontrol)     |
| output | 비상 경광등 신호 출력                                      | EMERGENCYOUT_0 (emergency Out)         |
| output | Zigbee 장치 초기화 신호 출력                               | ZIGBEEINIT_0 (zigbee Initialize)       |

#### rk3568_rgb_p02 board

- pio_hal

```bash
// input
	GPIO0_C6	DOOR_CALL_DET
	GPIO1_A6	ESCAPE_IN
	GPIO1_A7	EMG_IN
	GPIO1_B0	SEQ1_IN
	GPIO1_B1	SEQ2_IN
	GPIO2_C6	PIR_DET

// output
	GPIO0_A5	DOOR_OPEN
	GPIO0_B7	RST_CH710
	GPIO0_C2	ZIGBee_RST
	GPIO0_C5	DOOR_PCTL
	GPIO1_A5	EMER_LEDOUT
```


- audio
```bash
	GPIO0_A6	SEL_DC
	GPIO0_B1	DOOR_MIC_EN
	GPIO0_B2	SEL_DC_SUB
	GPIO0_C3	SEL_SUB-
	GPIO0_C4	SEL_ECHO_SUB+
	GPIO2_D1	SEL_DTMF
	GPIO3_A1	SEL_PSTN
	GPIo3_A2	SEL_SUB_PSTN
	GPIO3_C1	SEL_ECHO
	GPIO3_C2	SEL_SUB_VIDEO
	GPIO3_D0	DTMF_DATA
	GPIO3_D1	DTMF_EN
	GPIO3_D2	PSTN_OFF_HOOK
	GPIO3_D3	RING_DET
	GPIO3_D4	PSTN_DET
	GPIO4_C2	DTMF_CLK
	GPIO4_D2	SPK_AMP_EN
```

#### rk3568_edp_p02 board

- pio_hal

```bash
// input
	GPIO1_B1	DOOR_DET	(detect door call)
	GPIO1_B3	PIR_DET	(detect pio sensor)
	GPIO3_C7	SEQ1_IN	(detect seq1 sensor)
	GPIO3_D0	SEQ2_IN	(detect seq2 sensor)
	GPIO3_D2	EMG_IN	(detect emergency sensor)
	GPIO3_D3	ESCAPE_IN_1	(detect escape1 sensor)
	GPIO3_D4	ESCAPE_IN_2	(detect escape2 sensor)


// output
	GPIO0_B7	RST_CH710	(control ch710 module)
	GPIO1_A7	DOOR_OPEN	(control door)
	GPIO1_B0	DOOR_PCTL	(control door power)
	GPIO3_C6	EMER_OUT	(control emergency sensor)

```

- audio

```bash

// input

// output
	GPIO0_A6	SEL_DC	(control door audio path)
	GPIO0_B1	DOOR_MIC_EN	(control door mic enable)
	GPIO0_B2	SEL_DC_SUB	(control subphone device audio path)
	GPIO0_C2	SEL_ECHO_SUB	(control subphone device audio path)
	GPIO0_C3	SEL_SUB	(control subphone device autio path)
	GPIO4_D2	SPK_AMP_EN	(control speaker amp)

```

- device

```bash

// output
	GPIO0_C4	UART0_RSTN	(control txen on device-control interface)
	GPIO4_B0	(control work led)
	GPIO1_A5	UART4_SUB_TXEN	(control txen on sub decie interace)
	GPIO3_C4	LCD_BL_PWM
	GPIO3_C5	LCD_BL_EN

```

- etc

```bash
	GPIO0_A4/SDMMC0_DET_L (N/A)
	GPIO0_A5	(N/A)
	GPIO0_B5	(to be connect hot key interrupt interface)
	GPIO0_B6	(to be connect hot key reset interface)
	GPIO0_C5	(to be connect ladar motion detect)
	GPIO0_C6	(to be connect ladar reset)
	GPIO1_B2	(N/A)
	GPIO1_D5	(N/A)
	GPIO1_D6	(N/A)
	GPIO1_D7	(N/A)
	GPIO2_A0	(N/A)
	GPIO2_A1	(N/A)
	GPIO2_A2	(N/A)
	GPIO2_A5	(N/A)
	GPIO2_A6	SEL_SUB_VIDEO	(control video data from tv_out)
	GPIO2_C6	(N/A)
	GPIO2_D1	(N/A)
	GPIO3_A2	(N/A)
	GPIO3_C1	(N/A)
	GPIO3_C2	(N/A)
	GPIO3_D1	(N/A)
	GPIO4_B1	(N/A)

```

----- 

<br/>
<br/>
<br/>
<br/>


## source code

### kernel DTB

```bash
    /                               /                               /
    rk3568-pinctrl.dtsi----------+
    rk3568.dtsi------------------+	
    rk3568-poc.dtsi--------------+--rk3568-poc-v00.dtsi----------+--rk3568-poc-v00.dts
        +-> /**                         +-> /**
              * backlight                     * set iodomain
              * leds                          * panel 
              * sound card                    * usb
              * iodomain                      * camera
              * mmc                           * gmac
              * etc                           * i2c1-5
              */                              * uart
                                              */
                                    rk3568-android.dtsi----------+
                                        +-> /**
                                              * setting bootargs
                                              * reserved_memory
                                              */
// change

    rk3568-pinctrl.dtsi----------+                                                                                     
    rk3568.dtsi------------------+                                                                   
    rk3568-poc.dtsi--------------+--rk3568-rgb.dtsi--------------+--rk3568-rgb-p01.dts                     
                                 |                               +--rk3568-rgb-p02.dts                     
                                 |                               +
                                 +--rk3568-edp.dtsi--------------+--rk3568-edp-p01.dts
                                                                 +
                                    rk3568-android.dtsi----------+                       
                                                                 +
    /                               /                               /
```




### android Device

```bash
lchy0113@AOA:~/ssd/Rockchip/ROCKCHIP_ANDROID12/device$ tree -R company/test/rk3568_poc/
company/test/rk3568_poc/
├── AndroidBoard.mk
├── AndroidProducts.mk
├── BoardConfig.mk
├── bt_vendor.conf
├── media_profiles_default.xml
└── rk3568_poc.mk

0 directories, 6 files:w

```


```bash
device/company/test/rk3568_poc/AndroidBoard.mk
	|
	+-> include device/company/nova/rk3568/board.mk
		|	/* include rockchip's makefile */
		+-> include device/rockchip/common/build/rockchip/RebuildFstab.mk
		+-> include device/rockchip/common/build/rockchip/RebuildDtboImg.mk
		+-> include device/rockchip/common/build/rockchip/RebuildParameter.mk
		|
		+-> bootloader
		|	/* include common u-boot make template */
		+-> include device/company/nova/common/uboot.mk
		|
		+-> kernel
		|	/* include common kernel make template */
		|-> include device/company/nova/common/kernel.mk
		|
		+-> rockchip images
```


```bash
device/company/test/rk3568_poc/AndroidProducts.mk
	|
	+-> Makefile 지정(rk3568_poc.mk) 
	+-> lunch choice 등록
```

```bash
device/company/test/rk3568_poc/BoardConfig.mk
	|
	+-> include device/company/nova/rk3568/config.mk
	|	|
	|	+-> include device/company/nova/common/config.mk
	|	+->	include device/rockchip/rk356x/BoardConfig.mk
	|	|	+-> build default config 지정
	|	+-> bootloader, kernel, dtb, hal  build시 default config 재지정 
```

```bash
device/company/test/rk3568_poc/rk3568_poc.mk
	|
	+->	inherit device/company/nova/rk3568/device.mk
	|	|
	|	+-> include device/rockchip/common/build/rockchip/DynamicPartitions.mk 
	|	|	+->	파티션 설정
	|	+-> include device/company/nova/rk3568/config.mk
	|	|	|
	|	|	+-> include device/company/nova/common/config.mk
	|	|	+->	include device/rockchip/rk356x/BoardConfig.mk
	|	|	|	+-> build default config 지정
	|	|	+-> bootloader, kernel, dtb, hal  build시 config 재지정
	|	+-> include device/rockchip/common/Boardconfig.mk
	|	|		board config 기본 세팅
	|	+-> inherit device/company/nova/common/device.mk
	|	|	+-> copy init.nova.common.rc, setting nova overlay, copy adb key, copy system_dump.sh
	|`	+-> inherit device/rockchip/rk356x/device.mk
	|	|	+-> copy package and file related rockchip rk3568 
	|	+-> inherit device/rockchip/common/device.mk
	|	|	+-> copy package and file related rockchip and aosp platform
	|	+-> inherit frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk
	|	|	+-> setting property
	|	+-> overlay 및 package 지정.
	+-> product name, device, model, brand, manufacturer 세팅.  
```

----

<br/>
<br/>
<br/>
<br/>

## issue

### issue: userdata partition file system 검토
> change userdata partition file system to EXT4

 - diff 파일 참고.
   * [diff file](./attachment/diff_changed_data_partion_to_ext4_from_f2fs.diff)

-----

### issue: Data 영역 read/write performance 최적화

 - 데이터 영역 write performance 최적화.
   * 배터리가 있는 장치의 경우, 스토리지 읽기/쓰기 속도 및 성능을 향상시키기 위해 fstab의 데이터 파티션 탑재 매개변수에 'fsync_mode=nobarrier'를 추가하는 것이 좋다.
     + 이 매개변수는 배터리가 없는 장치에서 데이터 손상을 일으킬 수 있다.
     + 따라서 배터리가 없는 장치에는 이 매개변수를 추가하지 않는 것이 좋다.
     + fsync_mode = nobarrier는 linux에서 사용하는 Mount 옵션.    
     + 이 옵션을 사용하면 file system write작업이 완료 되기전에 하드웨어 cache를 flush 하지 않는다. 
     + 즉, 파일시스템의 쓰기 작업이 더 빨리 완료 된다. 반대로, 시스템에 손실에 발생할 위험이 있다. 
 

-----

### issue: OTP and efuse instruction

-----

<br/>
<br/>
<br/>
<br/>

## to do : 

 - [x] change userdata partition file system to EXT4  : 기본적으로 data 파티션의 파일시스템은 fsfs으로 구성된다.   배터리를 사용하지 않는 제품은 ext4 파일시스템으로 변경을 추천한다. (data loss 방지를 위해서 f2fs파일시스템을 사용함.)
```bash
/dev/block/dm-8 on /data type f2fs (rw,lazytime,seclabel,nosuid,nodev,noatime,background_gc=on,discard,no_heap,user_xattr,inline_xattr,acl,inline_data,inline_dentry,flush_merge,extent_cache,mode=adaptive,active_logs=6,reserve_root=32768,resuid=0,resgid=1065,alloc_mode=reuse,fsync_mode=posix)

// patch-01
device/rockchip/common$ git diff
diff --git a/scripts/fstab_tools/fstab.in b/scripts/fstab_tools/fstab.in
index 6e78b00..a658332 100755
--- a/scripts/fstab_tools/fstab.in
+++ b/scripts/fstab_tools/fstab.in
@@ -20,6 +20,6 @@ ${_block_prefix}system_ext /system_ext
 ext4 ro,barrier=1
${_flags},first_stage_
# For sdmmc
/devices/platform/${_sdmmc_device}/mmc_host*
 auto
 auto
 defaults
voldmanaged=sdcard1:auto
#
 Full disk encryption has less effect on rk3326, so default to enable this.
-/dev/block/by-name/userdata /data f2fs	noatime,nosuid,nodev,discard,reserve_root=32768,resgid=1065 latemount,wait,check,fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized,quota,formattable,reservedsize=128M,checkpoint=fs
+#/dev/block/by-name/userdata /data f2fs noatime,nosuid,nodev,discard,reserve_root=32768,resgid=1065 latemount,wait,check,fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized,quota,formattable,reservedsize=128M,checkpoint=fs
# for ext4
-#/dev/block/by-name/userdata
 /data
 ext4
discard,noatime,nosuid,nodev,noauto_da_alloc,data=ordered,user_xattr,barrier=1latemount,wait,formattable,check,fileencryption=software,quota,reservedsize=128M,checkpoint=block
+/dev/block/by-name/userdata /data ext4 discard,noatime,nosuid,nodev,noauto_da_alloc,data=ordered,user_xattr,barrier=1 latemount,wait,formattable,check,fileencryption=software,quota,reservedsize=128M,checkpoint=block

// patch-02
device/rockchip/rk356x$ git diff
diff --git a/rk3566_r/recovery.fstab b/rk3566_r/recovery.fstab
index 7532217..cf789ac 100755
--- a/rk3566_r/recovery.fstab
+++ b/rk3566_r/recovery.fstab
@@ -7,7 +7,7 @@
 /dev/block/by-name/odm				/odm	 		ext4	defaults	 defaults
 /dev/block/by-name/cache			/cache			ext4	defaults	 defaults
 /dev/block/by-name/metadata		/metadata		ext4	defaults	 defaults
-/dev/block/by-name/userdata		/data			f2fs	defaults	 defaults
+/dev/block/by-name/userdata		/data			ext4	defaults	 defaults
 /dev/block/by-name/cust			/cust			ext4	defaults	 defaults
 /dev/block/by-name/custom			/custom			ext4	defaults	 defaults
 /dev/block/by-name/radical_update	/radical_update ext4	defaults	 defaults
```

-----

 - [ ] app performance mode setting : Configure the file: package_performance.xml in device/rockchip/rk3xxx/. Add the package names which need to use performance mode in the node:(use aapt dump badging (file_path.apk) to acquire the package name)
```bash
< app package="package name" mode="whether to enable the acceleration, 1 for enable, 0 for disable"/>
// take antutu as example as below, 

< app package="com.antutu.ABenchMark"mode="1"/>
< app package="com.antutu.benchmark.full"mode="1"\/>
< app package="com.antutu.benchmark.full"mode="1"\/>
```

-----

 - [ ] download mode 진입 시, 2번 반복적으로 진입되는 현상.
   * download mode(fastboot mode) 2번 진입되는 현상. 
```bash
# adb reboot bootloader // (host pc side) 명령 시 다운로드 모드 2번 진입됨.
```

   * log 
```bash

[2023-06-19 09:56:46.797] [   46.394887] reboot: Restarting system with command 'bootloader'
[2023-06-19 09:56:46.925] DDR Version V1.13 20220218
[2023-06-19 09:56:46.925] In

(...)

[2023-06-19 09:56:47.783]
[2023-06-19 09:56:47.783]
[2023-06-19 09:56:47.783] U-Boot 2017.09-g9a4fa84aad-220408-dirty #lchy0113 (Jun 13 2023 - 01:49:52 +0000)
[2023-06-19 09:56:47.824]
[2023-06-19 09:56:47.824] Model: company nova platform rk3568 board rk3568-edp-p01.dts
[2023-06-19 09:56:47.825] PreSerial: 4, raw, 0xfe680000
[2023-06-19 09:56:47.825] DRAM:  2 GiB
[2023-06-19 09:56:47.825] Sysmem: init
[2023-06-19 09:56:47.825] Relocation Offset: 7d346000
[2023-06-19 09:56:47.825] Relocation fdt: 7b9f9460 - 7b9fece0
[2023-06-19 09:56:47.856] CR: M/C/I
[2023-06-19 09:56:47.856] Using default environment
[2023-06-19 09:56:47.856]
[2023-06-19 09:56:47.872] dwmmc@fe2b0000: 1, dwmmc@fe2c0000: 2, sdhci@fe310000: 0
[2023-06-19 09:56:47.948] Bootdev(atags): mmc 0
[2023-06-19 09:56:47.948] MMC0: HS200, 200Mhz
[2023-06-19 09:56:47.948] PartType: EFI
[2023-06-19 09:56:47.948] DM: v1
[2023-06-19 09:56:47.948] boot mode: bootloader
[2023-06-19 09:56:47.948] Android 12.0, Build 2022.3, v2
[2023-06-19 09:56:47.949] Found DTB in boot part
[2023-06-19 09:56:47.949] DTB: rk-kernel.dtb
[2023-06-19 09:56:47.949] HASH(c): OK
[2023-06-19 09:56:47.964] ANDROID: fdt overlay OK
[2023-06-19 09:56:47.980] I2c4 speed: 100000Hz
[2023-06-19 09:56:47.996] PMIC:  RK8090 (on=0x40, off=0x00)
[2023-06-19 09:56:47.996] vdd_logic init 900000 uV
[2023-06-19 09:56:48.012] vdd_gpu init 900000 uV
[2023-06-19 09:56:48.012] vdd_npu init 900000 uV
[2023-06-19 09:56:48.028] io-domain: OK
[2023-06-19 09:56:48.076] Model: company nova platform rk3568 edp p01 board


(...)

# fastboot reboot  // (host pc side)

(...)



request 000000007bdb7d00 was not queued to ep1in-bulk
DDR Version V1.13 20220218
[2023-06-19 09:57:57.541] In
[2023-06-19 09:57:57.602] ddrconfig:0
[2023-06-19 09:57:57.602] LP4 MR14:0x4d
[2023-06-19 09:57:57.602] LPDDR4, 324MHz
[2023-06-19 09:57:57.602] BW=32 Col=10 Bk=8 CS0 Row=16 CS=1 Die BW=16 Size=2048MB
[2023-06-19 09:57:57.603] tdqss: cs0 dqs0: 361ps, dqs1: 289ps, dqs2: 313ps, dqs3: 217ps,

(...)

[2023-06-19 09:57:57.603]
 [2023-06-19 09:57:58.443] Model: company nova platform rk3568 board rk3568-edp-p01.dts
 [2023-06-19 09:57:58.444] PreSerial: 4, raw, 0xfe680000
 [2023-06-19 09:57:58.444] DRAM:  2 GiB
 [2023-06-19 09:57:58.444] Sysmem: init
 [2023-06-19 09:57:58.444] Relocation Offset: 7d346000
 [2023-06-19 09:57:58.444] Relocation fdt: 7b9f9460 - 7b9fece0
 [2023-06-19 09:57:58.494] CR: M/C/I
 [2023-06-19 09:57:58.494] Using default environment
 [2023-06-19 09:57:58.495]
 [2023-06-19 09:57:58.495] dwmmc@fe2b0000: 1, dwmmc@fe2c0000: 2, sdhci@fe310000: 0
 [2023-06-19 09:57:58.574] Bootdev(atags): mmc 0
 [2023-06-19 09:57:58.574] MMC0: HS200, 200Mhz
 [2023-06-19 09:57:58.574] PartType: EFI
 [2023-06-19 09:57:58.574] DM: v1
 [2023-06-19 09:57:58.574] boot mode: recovery (misc)
 [2023-06-19 09:57:58.574] boot mode: normal
 [2023-06-19 09:57:58.574] Android 12.0, Build 2022.3, v2
 [2023-06-19 09:57:58.575] Found DTB in boot part
 [2023-06-19 09:57:58.575] DTB: rk-kernel.dtb
 [2023-06-19 09:57:58.575] HASH(c): OK
 [2023-06-19 09:57:58.590] ANDROID: fdt overlay OK
 [2023-06-19 09:57:58.606] I2c4 speed: 100000Hz
 [2023-06-19 09:57:58.636] PMIC:  RK8090 (on=0x40, off=0x00)
 [2023-06-19 09:57:58.636] vdd_logic init 900000 uV
 [2023-06-19 09:57:58.636] vdd_gpu init 900000 uV
 [2023-06-19 09:57:58.636] vdd_npu init 900000 uV
 [2023-06-19 09:57:58.652] io-domain: OK
 [2023-06-19 09:57:58.652] Model: company nova platform rk3568 edp p01 board
 [2023-06-19 09:57:58.698] Rockchip UBOOT DRM driver version: v1.0.1
 [2023-06-19 09:57:58.698] VOP have 2 active VP
 [2023-06-19 09:57:58.698] vp0 have layer nr:3[0 2 4 ], primary plane: 4
 [2023-06-19 09:57:58.699] vp1 have layer nr:3[1 3 5 ], primary plane: 5
 [2023-06-19 09:57:58.699] vp2 have layer nr:0[], primary plane: 0
 [2023-06-19 09:57:58.699] disp info 2, type:14, id:0

 (...)


```

-----

 - debug 
  first boot : bootloader 
  second boot : recovery(misc) & normal
  bootloader 부팅 후, recovery (misc) 로 부팅 됨.
 
-----
