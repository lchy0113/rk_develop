# WIFI

<br/>
<br/>
<br/>
<br/>
<br/>
<hr>

[Fn-Link 6222D-UUC](#fn-link-6222d-uuc)  
[Fn-Link 6222B-SRC](#fn-link-6222b-src)  

[Develop](#develop)  

[Reference](#reference)  
[..Document](#document)  

<br/>
<br/>
<br/>
<hr>

## Fn-Link 6222D-UUC

 FN-Link 사에서 제공하는 6222D-UUC(WiFi BT combo module) 
 **Realtek RTL8822CU** IC을 기반으로 함.

> CU : "Combo", "USB"

 - wifi표준 : IEEE 802.11 a/b/g/n/ac
 - 데이터전송률 : 최대 867Mbps
 - 인터페이스 : SDIO V3.0(wifi), uart/pcm 인터페이스 사용
 - bluetooth : bt5.0, bt4.2 지원
 - datasheet : https://downloads.codico.com/misc/AEH/FN-Link/?dir=USB%5C6222D-UUC#


```bash
+----------------------+             +-----------------+
|(host)                |             |(combomodule)    |
| GPIO0_B4 BT_WAKE_HOST+-------------+BT_WAKE_HOST     |
| GPIO0_B5 HOST_WAKE_BT+-------------+HOST_WAKE_BT     |
| GPIO1_D6 HOST_WAKE_WL+-------------+HOST_WAKE_WL     |
| GPIO1_D5 WL_WAKE_HOST+-------------+WL_WAKE_HOST     |
|                      |             |                 |
| GPIO0_B3        RESET+-------------+RESET            |
|                      |             |                 |
| USB2_HOST2_DP    HSDP+-------------+WL_DP+           |
| USB2_HOST2_DM    HSDM+-------------+WL_DM-           |
|                      |             |                 |
|                 GPIO0+-------------+GPIO0            |
|                 GPIO1+-------------+GPIO1            |
|              GPIO WPS+-------------+GPIO3_WPS        |
|              GPIO LED+-------------+GPIO8_LED        |
|                      |             |                 |
+----------------------+             +-----------------+

```

<br/>
<br/>
<br/>
<hr>

## Fn-Link 6222B-SRC

 FN-Link 사에서 제공하는 6222B-SRC 
 **Realtek RTL8822CS-VE-CG**i IC을 기반으로 함.

 - Host Interface 
   * SDIO V3.0/V2.0/V1.1 interface for WLAN
   * UAR/PCM interface for Bluetooth
 - bluettoth : bt5.0 

```bash
+--------------------------+             +-----------------+
|(host)                    |             |(combomodule)    |
| GPIOx_xx            BT_EN+----->>>-----+BT_REG_ON(38)    | //enable pin for bt device.(on:high,off:low)
|                          |             |                 |
| GPIO1_B1     BT_WAKE_HOST+-----<<<-----+BT_WAKE_HOST(50) | //bt device to wake-up HOST
| GPIO1_B0     HOST_WAKE_BT+----->>>-----+HOST_WAKE_BT(49) | //HOST wake-up bt device
|                          |             |                 |
| GPIOx_xx           BT_RTS+-------------+UART_CTS_N       |
| GPIOx_xx           BT_CTS+-------------+UART_RTS_N       |
| GPIOx_xx           BT_TXD+-------------+UART_RXD         |
| GPIOx_xx           BT_RXD+-------------+UART_TXD         |
|                          |             |                 |
|                          |             |                 |
|                          |             |                 |
| GPIO1_A7(39)       WL_RST+----->>>-----+SD_RESET(44)     | //reset active low
|                          |             |                 |
| GPIO0_A4(4)         WL_EN+----->>>-----+WL_REG_ON(15)    | //enable pin for wlan device.(on:high,off:low)
|                          |             |                 |    (WL_DIS_N)(if Pin44 connected this pin can NC)
| GPIO1_B3(43) WL_WAKE_HOST+-----<<<-----+WL_WAKE_HOST(16) | //WLAN to wake-up HOST
|                          |             |                 |
| GPIO0_B5(13) WL_SDIO0_INT+-----<<<-----+WL_WAKE_HOST/OOB | //SDIO interrupt
|                          |             |                 |
| SDMMC0_D0     WL_SDIO0_D0+-------------+SDIO_DATA_0      |
| SDMMC0_D1     WL_SDIO0_D1+-------------+SDIO_DATA_1      |
| SDMMC0_D2     WL_SDIO0_D2+-------------+SDIO_DATA_2      |
| SDMMC0_D3     WL_SDIO0_D3+-------------+SDIO_DATA_3      |
| SDMMC0_CLK   WL_SDIO0_CLK+-------------+SDIO_CLK         |
| SDMMC0_CMD   WL_SDIO0_CMD+-------------+SDIO_CMD         |
|                          |             |                 |
+--------------------------+             +-----------------+

```


 - Host Interface Timing

   * power up timing
     + vdd >>> SD_RESET(39)(high) >>> CHIP_EN(4)(high) 


<br/>
<br/>
<br/>
<hr>

## Develop

 >branch feature/wifi

```bash
/develop/Rockchip/ROCKCHIP_ANDROID12_DEV$ repo status 
project device/kdiwin/nova/common/              (*** NO BRANCH ***)
 -m     media/bootanimation.zip
 project device/kdiwin/test/rk3568_edpp04/       branch feature/wifi
 project device/rockchip/common/                 branch feature/wifi
 project device/rockchip/rk356x/                 branch feature/wifi
 project hardware/rockchip/libhwjpeg/            (*** NO BRANCH ***)
  -m     src/version.h
  project kernel-4.19/                            branch feature/wifi
   -m     logo.bmp
    --     logo.bmp.dev
	 -m     logo_kernel.bmp
	  --     logo_kernel.bmp.dev
	  project packages/modules/BootPrebuilt/5.10/arm64/ (*** NO BRANCH ***)
	   -t     boot-userdebug.img

```


 - interface

 전원이 켜진 후, 시스템에 SDIO wifi 장치가 있는지 확인. 
 sdio 의 경우 아래 로그 출력.

```bash
mmc0:new ultra high speed SDR104 SDIO card at address 0001
mmc0: new high speed SDIO card at address 0001

mmc2: new HS200 MMC card at address 0001

```

 sdio interface 에 연결된 sdio pid, vid정보를 통해 확인.
 RTL8822CS 모듈의 SDIO PID와 VID 정보는 다음과 같습니다:

 Vendor ID (VID): 0x024C
 Product ID (PID): 0xC822

```bash
/sys/bus/sdio/devices/mmc0:0001:1 # cat uevent 
SDIO_CLASS=07
SDIO_ID=024C:C822
MODALIAS=sdio:c07v024CdC822
```

 - kernel module

CONFIG_RTL8822CU

 WiFi 드라이버 로딩은 wifi chip type 노드에 의존하지 않으므로, board 수준 dts 를 구성할 필요 없다.

 usb wifi driver entry는 os_dep/linux/usb_intf.c의 rtw_drv_entry() 


```bash
# usb company/device info
Bus 001 Device 002: ID 0bda:c82c

# module file  
/vendor/lib/modules/88x2cu.ko

# insmod module with debug level
# insmod 8822.ko rtw_drv_log_level=6
```

<br/>
<br/>
<hr>

### wifi chip recognition process

 1. power up wifi module
 2. wifi 장치 초기화 시, System은 /sys/bus/usb file system에서 uevent를 읽는다.
 3. load wifi ko driver (check vid pid)
 4. load wpa_supplicant parameter 

```bash
# the key code directory:

android/frameworks/opt/net/wifi
kernel/net/rfkill/rfkill-wlan.c
hardware/realtek
external/wpa_supplicant_8
```

<br/>
<br/>
<hr>

### HAL

```bash
device/kdiwin/test/rk3568_edpp04/BoardConfig.mk
  | // BOARD_WIFI_SUPPROT := true
  |
  +-> device/rockchip/common/device.mk
      |
      +-> vendor/rockchip/common/BoardconfigVendor.mk
      |   |  // PRODUCT_HAVE_RKWIFI ?= true
      |   +-> 
      |
      | // if (BOARD_WIFI_SUPPORT) xml file copy
      |    frameworks/native/data/etc/android.hardware.wifi.xml
      |    frameworks/native/data/etc/android.hardware.wifi.direct.xml
      |    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml
      |    frameworks/native/data/etc/android.software.ipsec_tunnels.xml

device/rockchip/common/device.mk
  | // $(call inherit-product-if-exists, vendor/rockchip/common/device-vendor.mk)
  |
  +-> vendor/rockchip/common/device-vendor.mk
      $(call inherit-product-if-exists, vendor/rockchip/common/wifi/wifi.mk)
        // copy WIFI_KO_FILES

```


<br/>
<br/>
<hr>

### module

 - drivers/net/wireless/rockchip_wlan/rtl8821cs/ 
// rtl8821cs module base 로 진행
// rtl8821cs 는 기존 kernel 에 있는 코드

<br/>
<br/>
<br/>
<hr>

## Reference

<br/>
<br/>
<hr>

### Document

