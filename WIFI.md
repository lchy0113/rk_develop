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
  [Document](#decument)  

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


CONFIG_RTL8822CU

 WiFi 드라이버 로딩은 wifi chip type 노드에 의존하지 않으므로, board 수준 dts 를 구성할 필요 없다.

 usb wifi driver entry는 os_dep/linux/usb_intf.c의 rtw_drv_entry() 


```bash
# usb company/device info
Bus 001 Device 002: ID 0bda:c82c

# module file  
/vendor/lib/modules/88x2cu.ko
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
<br/>
<hr>

## Reference

<br/>
<br/>
<hr>

### Document
