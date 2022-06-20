# rk_Develop
repository about developing the Rockchip Platform.

## Compiling command summary
- Android
```bash
build/envsetup.sh
lunch rk3568_r-userdebug
```
 * one key compiling
```bash
./build.sh -AUCKu

( WHERE: -U = build uboot
	-C = build kernel with Clang
	-K = build kernel
	-A = build android
	-p = will build packaging in IMAGE
	-o = build OTA package
	-u = build update.img
	-v = build android with 'user' or 'userdebug'
	-d = huild kernel dts name
	-V = build version
	-J = build jobs
	------------you can use according to the requirement, no need to record
uboot/kernel compiling commands------------------
)
============================================================
Please remember to set the environment variable before using the one key
compiling command, and select the platform to be compiled, for example:
source build/envsetup.sh
lunch rk3566_rgo-userdebug
============================================================

```
- kernel compiling
  * Android11
```bash
make ARCH=arm64 rockchip_defconfig rk356x_evb.config android-11.config
make ARCH=arm64 rk3568-evb7-ddr4-v10.img -j32

ls kernel/boot.img
```  
  * Android12
```bash
make	\ 
		CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 	\
		ARCH=arm64				\
		rockchip_defconfig

make	\ 
		CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1 	\
		ARCH=arm64				\
		rk3568-evb1-ddr4-v10.img 

```

- uboot compoling
```bash
./make.sh rk3568
```

- build out
```bash
make 

```

- out image
> one key compiling 시 아래 파일만 사용된다
```bash
rockdev/Image-rk3568_r/
├── boot.img
├── dtbo.img
├── MiniLoaderAll.bin
├── misc.img
├── parameter.txt
├── recovery.img
├── super.img
├── uboot.img
└── vbmeta.img
```


<hr />

## Document

 - Develop/Rockchip/Develop_data/
   * Rockchip_Developer_Guide_Android11_SDK_V1.1.4_EN.pdf
    : Android11 가이드 문서 (전체적인 내용 boot~android)
   * Rockchip RK3568B2 Datasheet V1.0-20210701.pdf
     : RK3568B2 datasheet 

 - Develop/Rockchip/Develop_data/RK3568_DDR4_EVB/DOC/
   * Rockchip_RK3568_EVB1_User_Guide_V1.0_CN.pdf 
    : RK3568 evboard user guide

 - Develop/Rockchip/RKDocs/android/
   * Rockchip_Developer_Guide_*
    : Android feature 기능에 대한 설명 문서

        Peripheral support list
        DDR/EMMC/NAND FLASH/WIFI/3G/CAMERA support lists keep updating in redmine, through the
        following link:
        https://redmine.rockchip.com.cn/projects/fae/documents
        Android document
        RKDocs\android
        Android_SELinux(Sepolicy) developer guide
        RKDocs/android/Rockchip_Developer_Guide_Android_SELinux(Sepolicy)_CN.pdf
        Wi-Fi document
        RKDocs/android/wifi/
        ├── Rockchip_Introduction_Android10.0_WIFI_Configuration_CN&EN.pdf
        └── Rockchip_Introduction_REALTEK_WIFI_Driver_Porting_CN&EN.pdf

 - Develop/Rockchip/RKDocs/common/
    : boot & device 설명 문서 

   * 3G/4G module instruction document  
    RKDocs/common/mobile-net/  
    ├── Rockchip_Introduction_3G_Data_Card_USB_File_Conversion_CN.pdf  
    ├── Rockchip_Introduction_3G_Dongle_Configuration_CN.pdf  
    └── Rockchip_Introduction_4G_Module_Configuration_CN&EN.pdf  
   * Kernel document  
    RKDocs\common  
   * DDR related document  
    RKDocs/common/DDR/  
    ├── Rockchip-Developer-Guide-DDR-CN.pdf  
    ├── Rockchip-Developer-Guide-DDR-EN.pdf  
    ├── Rockchip-Developer-Guide-DDR-Problem-Solution-CN.pdf  
    ├── Rockchip-Developer-Guide-DDR-Problem-Solution-EN.pdf  
    └── Rockchip-Developer-Guide-DDR-Verification-Process-CN.pdf  
   * Audio module document  
    RKDocs/common/Audio/  
    ├──    Rockchip_Developer_Guide_Audio_Call_3A_Algorithm_Integration_and_Parameter_Debugging_CN.pdf  
    ├── Rockchip_Developer_Guide_Linux4.4_Audio_CN.pdf  
    └── Rockchip_Developer_Guide_RK817_RK809_Codec_CN.pdf  
   * CRU module document  
    RKDocs/common/CRU/
    ├── Rockchip_Developer_Guide_Linux3.10_Clock_CN.pdf  
    └── Rockchip_RK3399_Developer_Guide_Linux4.4_Clock_CN.pdf  
   * GMAC module document
    RKDocs/common/GMAC/
    └── Rockchip_Developer_Guide_Ethernet_CN.pdf  
   * PCie module document  
    RKDocs/common/PCie/
    └── Rockchip-Developer-Guide-linux4.4-PCIe.pdf  
   * I2C module document
    RKDocs/common/I2C/
    └── Rockchip_Developer_Guide_I2C_CN.pdf  
   * PIN-Ctrl GPIO module document  
    RKDocs/common/PIN-Ctrl/  
    └── Rockchip-Developer-Guide-Linux-Pin-Ctrl-CN.pdf  
   * SPI module document
    RKDocs/common/SPI/
    └── Rockchip-Developer-Guide-linux4.4-SPI.pdf  
   * Sensor module document  
    RKDocs/common/Sensors/  
    └── Rockchip_Developer_Guide_Sensors_CN.pdf  
   * IO-Domain module document  
    RKDocs/common/IO-Domain/  
    └── Rockchip_Developer_Guide_Linux_IO_DOMAIN_CN.pdf  
   * Leds module document
    RKDocs/common/Leds/
    └── Rockchip_Introduction_Leds_GPIO_Configuration_for_Linux4.4_CN.pdf  
   * Thermal control module document
    RKDocs/common/Thermal/  
    ├── Rockchip-Developer-Guide-Linux4.4-Thermal-CN.pdf  
    └── Rockchip-Developer-Guide-Linux4.4-Thermal-EN.pdf  
   * PMIC power management module document
    RKDocs/common/PMIC/  
    ├── Archive.zip
    ├── Rockchip_Developer_Guide_Power_Discrete_DCDC_EN.pdf  
    ├── Rockchip-Developer-Guide-Power-Discrete-DCDC-Linux4.4.pdf  
    ├── Rockchip-Developer-Guide-RK805.pdf
    ├── Rockchip_Developer_Guide_RK817_RK809_Fuel_Gauge_CN.pdf  
    ├── Rockchip_RK805_Developer_Guide_CN.pdf
    └── Rockchip_RK818_RK816_Introduction_Fuel_Gauge_Log_CN.pdf  
   * MCU module document
    RKDocs/common/MCU/
    └── Rockchip_Developer_Guide_MCU_EN.pdf  
   * Power consumption and sleep module document  
    RKDocs/common/power/  
    ├── Rockchip_Developer_Guide_Power_Analysis_EN.pdf  
    └── Rockchip_Developer_Guide_Sleep_and_Resume_CN.pdf  
   * UART module document
    RKDocs/common/UART/
    ├── Rockchip-Developer-Guide-linux4.4-UART.pdf  
    └── Rockchip-Developer-Guide-RT-Thread-UART.pdf  
   * DVFS CPU/GPU/DDR frequency scaling related document  
    RKDocs/common/DVFS/
    ├── Rockchip_Developer_Guide_CPUFreq_CN.pdf  
    ├── Rockchip_Developer_Guide_CPUFreq_EN.pdf  
    ├── Rockchip_Developer_Guide_Devfreq_CN.pdf  
    ├── Rockchip_Developer_Guide_Linux4.4_CPUFreq_CN.pdf  
    └── Rockchip_Developer_Guide_Linux4.4_Devfreq_CN.pdf  
   * EMMC/SDMMC/SDIO module document
    RKDocs/common/MMC  
    └── Rockchip-Developer-Guide-linux4.4-SDMMC-SDIO-eMMC.pdf  
   * PWM module document
    RKDocs/common/PWM/
    ├── Rockchip-Developer-Guide-Linux-PWM-CN.pdf  
    └── Rockchip_Developer_Guide_PWM_IR_CN.pdf  
   * USB module document  
    RKDocs/common/usb/
    ├── putty20190213_162833_1.log  
    ├── Rockchip-Developer-Guide-Linux4.4-RK3399-USB-DTS-CN.pdf  
    ├── Rockchip-Developer-Guide-Linux4.4-USB-CN.pdf  
    ├── Rockchip-Developer-Guide-Linux4.4-USB-FFS-Test-Demo-CN.pdf  
    ├── Rockchip-Developer-Guide-Linux4.4-USB-Gadget-UAC-CN.pdf  
    ├── Rockchip-Developer-Guide-USB-Initialization-Log-Analysis-CN.pdf  
    ├── Rockchip-Developer-Guide-USB-Performance-Analysis-CN.pdf  
    ├── Rockchip-Developer-Guide-USB-PHY-CN.pdf
    └── Rockchip-Developer-Guide-USB-SQ-Test-CN.pdf  
   * HDMI-IN function document
    RKDocs/common/hdmi-in/  
    └── Rockchip_Developer_Guide_HDMI_IN_CN.pdf  
   * Security module document  
    RKDocs/common/security/  
    ├── Efuse process explain .pdf  
    ├── RK3399_Efuse_Operation_Instructions_V1.00_20190214_EN.pdf  
    ├── Rockchip_Developer_Guide_Secure_Boot_V1.1_20190603_CN.pdf  
    ├── Rockchip_Developer_Guide_TEE_Secure_SDK_CN.pdf  
    ├── Rockchip_RK3399_Introduction_Efuse_Operation_EN.pdf  
    ├── Rockchip-Secure-Boot2.0.pdf
    ├── Rockchip-Secure-Boot-Application-Note-V1.9.pdf  
    └── Rockchip Vendor Storage Application Note.pdf  
   * uboot introduction document
    RKDocs\common\u-boot\Rockchip-Developer-Guide-UBoot-nextdev-CN.pdf  
   * Trust introduction document
    RKDocs/common/TRUST/  
    ├── Rockchip_Developer_Guide_Trust_CN.pdf  
    └── Rockchip_Developer_Guide_Trust_EN.pdf  
   * Camera document  
    RKDocs\common\camera\HAL3\  
   * Camera IQ Tool document  
    external/camera_engine_rkaiq/rkisp2x_tuner/doc/  
    ├── Rockchip_Color_Optimization_Guide_ISP2x_CN_v2.0.0.pdf  
    ├── Rockchip_IQ_Tools_Guide_ISP2x_CN_v2.0.0.pdf  
    └── Rockchip_Tuning_Guide_ISP21_CN_v2.0.0.pdf
   * Tool document  
    RKDocs\common\RKTools manuals  
   * PCBA development and usage document  
    RKDocs\android\Rockchip_Developer_Guide_PCBA_Test_Tool_CN&EN.pdf  
   * Panel driver debugging guide
    RKDocs\common\display\Rockchip_Developer_Guide_DRM_Panel_Porting_CN.pdf  
   * HDMI debugging guide
    RKDocs\common\display\Rockchip_Developer_Guide_HDMI_Based_on_DRM_Framework_CN.pdf  
   * Graphic display DRM Hardware Composer(HWC) issue analyzing  
    RKDocs\common\display\Rockchip FAQ DRM Hardware Composer V1.00-20181213.pdf  
   * DRM display developer guide
    RKDocs\common\display\Rockchip DRM Display Driver Development Guide V1.0.pdf  
   * RGA related issues analyzing
    RKDocs\common\display\Rockchip_RGA_FAQ.pdf  
   * Graphic display framework common issue analysis  
    include frameworks、GPU.Gralloc、GUI、HWComposer、HWUI、RGA  
    RKDocs\common\display\Rockchip_Trouble_Shooting_Graphics  


<hr />

## Tool
 - StressTest
 - Module Related
 - Non module related
 - PCBA test tool
 - DeviceTest
 - Development flashing tool
   * Linux version
```bash
$ sudo ./upgrade_tool -h
Program Data in /home/lchy0113/Develop/Rockchip/rk3568b2/Android11/ROCKCHIP_ANDROID11.0_SDK_RELEASE_rkr10/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65

---------------------Tool Usage ---------------------
Help:             H
Quit:             Q
Version:          V
Clear Screen:     CS
------------------Upgrade Command ------------------
ChooseDevice:           CD
ListDevice:                 LD
SwitchDevice:           SD
UpgradeFirmware:        UF <Firmware> [-noreset]
UpgradeLoader:          UL <Loader> [-noreset]
DownloadImage:          DI <-p|-b|-k|-s|-r|-m|-u|-t|-re image>
DownloadBoot:           DB <Loader>
EraseFlash:             EF <Loader|firmware> [DirectLBA]
PartitionList:          PL
WriteSN:                SN <serial number>
ReadSN:             RSN
ReadComLog:             RCL <File>
CreateGPT:              GPT <Input Parameter> <Output Gpt>
----------------Professional Command -----------------
TestDevice:             TD
ResetDevice:            RD [subcode]
ResetPipe:              RP [pipe]
ReadCapability:         RCB
ReadFlashID:            RID
ReadFlashInfo:          RFI
ReadChipInfo:           RCI
ReadSecureMode:         RSM
ReadSector:             RS  <BeginSec> <SectorLen> [-decode] [File]
WriteSector:            WS  <BeginSec> <File>
ReadLBA:                RL  <BeginSec> <SectorLen> [File]
WriteLBA:               WL  <BeginSec> <File>
EraseLBA:               EL  <BeginSec> <EraseCount>
EraseBlock:             EB <CS> <BeginBlock> <BlokcLen> [--Force]
RunSystem:              RUN <uboot_addr> <trust_addr> <boot_addr> <uboot> <trust> <boot>
-------------------------------------------------------

lchy0113@kdiwin-nb:~/Develop/Rockchip/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65$


```
