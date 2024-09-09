# COMBO MODULE
support WIFI, BT

<br/>
<br/>
<br/>
<br/>
<br/>
<hr>

[Fn-Link 6222D-UUC](#fn-link-6222d-uuc)  
[Fn-Link 6222B-SRC](#fn-link-6222b-src)  

[Develop wifi](#develop.wifi)  
[Develop bluetooth](#develop.bluetooth)  

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
 **Realtek RTL8822CS-VE-CG** IC을 기반으로 함.

 - Host Interface 
   * SDIO V3.0/V2.0/V1.1 interface for WLAN
     + 3.3V : default speed(25MHz), high speed(50MHz)
     + WLAN 디바이스가 SDIO interface를 Turn on 할때, "out-of-band" interrupt signal을 사용.

   * UAR/PCM interface for Bluetooth
 - bluettoth : bt5.0 

```bash
+--------------------------+             +-----------------+
|(host)                    |             |(combomodule)    |
| GPIO0_B6            BT_EN+----->>>-----+BT_REG_ON(38)    | //enable pin for bt device.(on:high,off:low)
|                          |             |                 |
| GPIO1_B1(41) BT_WAKE_HOST+-----<<<-----+BT_WAKE_HOST(50) | //bt device to wake-up HOST
| GPIO1_B0(40) HOST_WAKE_BT+----->>>-----+HOST_WAKE_BT(49) | //HOST wake-up bt device
|   UART6                  |             |                 |
| GPIO2_B7(79)       BT_RTS+-------------+UART_CTS_N       |
| GPIO2_C0(80)       BT_CTS+-------------+UART_RTS_N       |
| GPIO2_A4(68)       BT_TXD+-------------+UART_RXD         |
| GPIO2_A3(67)       BT_RXD+-------------+UART_TXD         |
|                          |             |                 |
|                          |             |                 |
|                          |             |                 |
| GPIO1_A7(39)       WL_RST+----->>>-----+SD_RESET(44)     | //reset active low
|                          |             |                 |
| GPIO0_A4(4)         WL_EN+----->>>-----+WL_REG_ON(15)    | //enable pin for wlan device.(on:high,off:low)
|                          |             |                 |    (WL_DIS_N)(if Pin44 connected this pin can NC)
| GPIO1_B3(43) WL_WAKE_HOST+-----<<<-----+WL_WAKE_HOST(16) | //WLAN to wake-up HOST
|                          |             |                 |
| GPIO0_B5(13) WL_SDIO0_INT+-----<<<-----+WL_WAKE_HOST/OOB(24) | //SDIO interrupt
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

## Develop_wifi

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

```bash
// check sdio(mmc0)
SYS_GRF(0xfdc60000)
0x001c : SDMMC0_D0, SDMMC0_D1, SDMMC0_D2, 
0x0020 : SDMMC0_D3, SDMMC0_CMD, SDMMC0_CLK


0xfdc6001c : 0x00001110 : sdmmc0_d2, sdmmc0_d1, sdmmc0_d0 
0xfdc60020 : 0x00003111 : uart6rxm0, sdmmc0_clk, sdmmc0_cmd, sdmmc0_d3 


// check sd_reset(gpio1_a7)
SYS_GRF(0xfdc60000)
0x0004 : 0x00000222 : gpio1_a7

```

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


 - android.hardware.wifi@1.0  
 wifi hal의 이름이며, android system server 와 통신하여 wifi 기능 제어.
 기존의 wpa_supplicant 프로세스를 대체하는 hidl 인터페이스로 wifi 인증 및 연결 관리 담당.

 /hardware/interfaces/wifi/1.5/default/Android.mk

```bash
int main(...) 
   |
   +-> int wifi_load_driver() // frameworks/opt/net/wifi/libwifi_hal
         // libwifi_hal코드는 frameworks/opt/net/wifi 경로에 위치하는데, 프레임워크의 일부로 통합되어 있음.



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

## Develop_bluetooth

<br/>
<br/>
<hr>

### Library

 1. Libbt 
 bluetooth firmware load 및 bluetooth chip의 초기화를 담당.  
 보통 Libbt는 칩 제조업체에서 제공.  

 안드로이드의 경우, *hardware/realtek/rtkbt/code/libbt-vendor* 경로를 통해 제공

 Libbt는 일반적으로 수정할 필요 없다. 
 bluetooth module에서 사용하는 포트와 bluetooth firmware 경로만 구성하면 됨.  
 *hardware/realtek/rtkbt/vendor/etc/bluetooth/rtkbt.conf*
  
  
 2. bluedroid
 bluedroid 소스 코드는 system/bt경로에 위치함. 
 android 9.0 부터 bluedroid로 컴파일된 library는 libbluetooth.so. 

 bluedroid는 *device/rockchip/rk356x/bluetooth/bdroid_buildcfg.h* 에서 구성할 수있는 파일이 존재함.  

 [persist.bluetooth.btsnoopenable]: [false] 을 설정하여 snoop 로그 출력 여부를 제어 할수 있다.
 - bluetooth snoop은 bluetooth HCI(Host Controller Interface)트래픽을 캡처하고 기록하는 파일 형식.  
   bluetooth 문제를 디버깅하고 protocol stack 을 디버깅하는데 사용.  
   /data/misc/bluetooth/logs 경로에 저장.  

 3. pcba bt


<br/>
<br/>
<hr>

### ble

 - GATT (Generic Attribute Profile)
   bluetooth low energy (ble) 장치 간에 데이터를 주고 받는 방법을 정의 하는 프로파일
   GATT 는 서비스(service) 와 특성(characteristic)이라는 개념을 사용하여 데이터를 전송.
   
   * 서비스(service) : 기능 또는 데이터의 집합으로 장치가 제공하는 기능을 정의.
   * 특성(characteristic) : 서비스 내에서 데이터를 나타내는 단위. 읽기,쓰기,알림,표시 등의 작업을 수행.
   
   GATT는 연결이 설정된 후에 사용되며, 연결은 독점적이다. 
   즉, ble 주변 장치는 한번에 하나의 중앙 장치(ex. smartphone) 에 만 연결할 수 있다. 
   연결이 설정되면 양방향 통신이 가능하며, 중앙 장치와 주변 장치간에 데이터를 주고 받을 수 있다. 

<br/>
<br/>
<hr>

### HAL
 
 android.hardware.bluetooth@1.0

 Android 하드웨어 HAL 레이어의 인터페이스 중 하나로, 블루투스 하드웨어와 상호 작용하기 위한 표준 인터페이스를 정의.
 Android 프레임워크와 블루투스 하드웨어 간의 통신 지원.
 블루투스 HAL 헤더 파일 : hardware/libhardware/include/hardware/bluetooth.h 

 hardware/interfaces/bluetooth/1.0/default/Android.bp

```
cc_binary {
    name: "android.hardware.bluetooth@1.0-service",
    defaults: ["hidl_defaults"],
    relative_install_path: "hw",
    vendor: true,
    init_rc: ["android.hardware.bluetooth@1.0-service.rc"],
    srcs: ["service.cpp"],

    shared_libs: [
        "liblog",
        "libcutils",
        "libdl",
        "libbase",
        "libutils",
        "libhardware",
        "libhidlbase",
        "android.hardware.bluetooth@1.0",
    ],
}
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

