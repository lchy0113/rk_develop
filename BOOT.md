
<hr/>

# 1. Boot introduce
linux os 를 부팅할 때 많은 부팅 단계가 있습니다.   
이미지가 어느 위치에 flashing되는지 설명하며,   
storage에 flash 후, storage에서 부팅하는 방법을 설명합니다.    
Rockschip사에서 released된 binarie는 rkbin(https://github.com/rockchip-linux/rkbin) 을 통하여 배포됩니다.  

## 1.1 boot flow
Rockchip 플랫폼에서 사용되는 boot flow에 대해 설명합니다.  2종류의 boot path가 있습니다. 
- upstream 또는 Rockchip u-boot 의 tls/spl 을 사용. (소스코드 제공)
- Rockchip사 rkbin 프로젝트를 통해 배포되는 Rockchip ddr init bin 과 miniloader bin이 포함된 idbLoader를 사용합니다.  

```bash
+--------+----------------+----------+-------------+---------+
| Boot   | Terminology #1 | Actual   | Rockchip    | Image   |
| stage  |                | program  |  Image      | Location|
| number |                | name     |   Name      | (sector)|
+--------+----------------+----------+-------------+---------+
| 1      |  Primary       | ROM code | BootRom     |         |
|        |  Program       |          |             |         |
|        |  Loader        |          |             |         |
|        |                |          |             |         |
| 2      |  Secondary     | U-Boot   |idbLoader.img| 0x40    | pre-loader
|        |  Program       | TPL/SPL  |             |         |
|        |  Loader (SPL)  |          |             |         |
|        |                |          |             |         |
| 3      |  -             | U-Boot   | u-boot.itb  | 0x4000  | including u-boot and atf
|        |                |          | uboot.img   |         | only used with miniloader
|        |                |          |             |         |
|        |                | ATF/TEE  | trust.img   | 0x6000  | only used with miniloader
|        |                |          |             |         |
| 4      |  -             | kernel   | boot.img    | 0x8000  |
|        |                |          |             |         |
| 5      |  -             | rootfs   | rootfs.img  | 0x40000 |
+--------+----------------+----------+-------------+---------+
```
BootRom에 Rom code(idbLoader)를 write하여 ddr init 및 초기 AP initialize가 필요한 부분을 수행하고 u-boot 코드로 점프하게 됩니다.

일반적인 이미지 업데이트 모드는 u-boot에서 GPIO Pin 형태로 Boot-pin 또는 switch 인식하여 전환하게 되는데, 
만약 BootRom 내에 이미 Code가 Write 되어 Rom 내역을 수행하고 u-boot로 jump하는 흐름에서 문제 발생되었을 때는 정상적으로 부팅을 하지 못하게 됩니다.

이 상황에서 Mask Rom 모드로 진입이 가능하도록 eMMC 또는 부팅 매체로 jump되지 못하도록 설정하여 Rom 이미지를 다시 Write 또는 설정합니다.

Rockchip AP의 Boot Flow는 아래의 그림과 같습니다.

![Rockchip bootflow](./images/BOOT_01.png)

- bootflow-1 : 일반적인 Rockchip Boot Flow로 Rockchip miniloader 바이너리를 사용.
- bootflow-2 : 일반적인 대부분의 AP부팅 Sequence로 u-boot TPL/SPL에서 DDR init을 진행하고 다음 스테이지 진행.

보통의 경우 위의 두 가지 중 bootflow-1을 주로 쓰며, 바이너리 형태로 배포되는 miniloader를 rkbin github에서 받아 Android Tool을 이용하여 프로그램을 flash 합니다.

## 1.2 packages option
 stage 2~4 단계의 package 에 사용되는 파일 목록은 다음과 같습니다.
 - from source code:
   * from u-boot : u-boot-spn.bin, u-boot.bin(u-boot-nodtb.bin 및 u-boot.dtb를 대신 사용할 수 있음).
   * from kernel : kernel Image/zImage file, kernel dtb.
   * from ATF ; bl31.elf.
 - from rockchip binary:
   * ddr, usbplug, miniloader , bl31/op-tee, ( 파일명은  'rkxx_' 로 시작 하며, '_x.xx.bin' 으로 끝맺임 합니다. )

### 1.2.1 The Pre-bootloader(idbLoader)
#### 1.2.1.1 idbLoader 란 
idbLoader.img는 SoC start up시 동작하며, 아래 기능을 포함하는 Rockchip 형식의 pre-loader 입니다.
 - Rockchip BootRom 으로 알려진 IDBlock header 
 - MaskRom에 의해 load되고, 내부 SRAM에서 실행되는 DRAM 초기화 프로그램.
 - MaskRom에 의해 load되고, DRAM에서 다음 loader를 실행시킵니다.

#### 아래 방법으로 idbLoader를 얻을 수 있습니다. 

#### 1.2.1.2 Rockchip release loader에서 eMMC용 idbLoader 패키징.
Rockchip release loader를 사용하는 경우, eMMC idbLoader.img를 패키징할 필요가 없습니다. 
아래 명령어를 사용하여 eMMC idbLoader를 얻을 수 있습니다.
```bash
rkdeveloptool db rkxx_loader_vx.xx.bin	// rkxx_loader_vx.xx.bin 을 download.
rkdeveloptool ul rkxx_loader_vx.xx.bin	// rkxx_loader_vx.xx.bin 을 upgrade.	
```

#### 1.2.1.3 Rockchip binary 에서 idbLoader.img를 패키징 합니다.
SD boot 또는 eMMC의 경우, idbLoader가 필요 합니다. 
```bash
tools/mkimage -n rkxxxx -T rksd -d rkxx_ddr_vx.xx.bin idbLoader.img
cat rkxx_miniloader_vx.xx.bin >> idbloader.img
```


#### 1.2.1.4 U-boot TPL/SPL(fully open source) 에서 idbLoader.img를 패키징 합니다.
```bash
tools/mkimage -n rkxxxx -T rksd -d tpl/u-boot-tpl.bin idbloader.img
cat spl/u-boot-spl.bin >> idbloader.img
```
statge 2에서 idbloader.img 를 offset 0x40 위치에 flash 합니다. 
이후 stage 3 진행을 위해 uboot.img 가 필요로 합니다.
 
### 1.2.2 u-boot

#### 1.2.2.1 uboot.img
Rockchip miniloader 의 idbLoader 를 사용하는 경우, miniloader 에 로드될 형식의 u-boot.bin 이 필요합니다. 
```bash
tools/loaderimage --pack --uboot u-boot.bin uboot.img $SYS_TEXT_BASE
```
> Note: $SYS_TEXT_BASE 값은 각 SoC에 따라 따릅니다.

#### 1.2.2.1 u-boot.itb
When using SPL to load the ATF/OP-TEE, package the bl31.bin, u-boot-nodtb.bin and uboot.dtb into one FIT image. 
You can skip the step to package the Trust image and flash that image in the next section.
```bash
make u-boot.itb
```
> Note: please copy the trust binary() to u-boot root directory and rename it to tee.bin(armv7) or bl31.elf(armv8).

### 1.2.3 trust
#### 1.2.3.1 trust.img

### 1.2.4 boot.img
This image is package the kernel Image and dtb file into a know filesystem(FAT or EXT2) image for distro boot.
See Install kernel for detail about generate boot.img from kernel zImage/Image, dtb.
Flash the boot.img to offset 0x8000 which is stage 4.

### 1.2.5 rootfs.img
Flash the rootfs.img to offset 0x40000 which is stage 5. As long as the kernel you chosen can support that filesystem, there is not limit in the format of the image.

### 1.2.6 rkxx_loader_vx.xx.xxx.bin
rkdeveloptool을 사용하여 eMMC에 펌웨어를 upgrade하는데 사용되는 바이너리로, Rockchip사에서 제공합니다.
ddr.bin, usbplug.bin, miniloader.bin 의 package 입니다. Rockchip tool db 명령어로 usbplug.bin 을 만들어 target에서 실행시킵니다.
Rockchip사에서는 대부분의 장치의 이 이미지를 제공합니다.

<hr/>
<br/>
<br/>
<br/>
<hr/>

## 2 flash and boot from Media device
아래 과정을 통해 eMMC에 flash합니다.
 - maskrom mode 진입합니다.
 - usb cable을 통해 target과 host pc 연결합니다.
 - rkdeveloptool을 사용하여 이미지를 eMMC에 flash합니다.

target 장치의 eMMC에 flash하는 예제 입니다.

target 장치에 GPT partition을 flash 합니다.
```bash
lchy0113@kdiwin-nb:~/Develop/Rockchip/rk3568b2/Android11/rk3568_android11/u-boot$ ~/Develop/Rockchip/rockchip-linux/rkdeveloptool/rkdeveloptool db rk356x_spl_loader_v1.10.111.bin 
Downloading bootloader succeeded.

lchy0113@kdiwin-nb:~/Develop/Rockchip/rk3568b2/Android11/rk3568_android11/rkbin/tools$ ~/Develop/Rockchip/rockchip-linux/rkdeveloptool/rkdeveloptool gpt /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/rockdev/Image-rk3568_r/parameter.txt
Writing gpt succeeded.
```

- For with SPL ;
```bash
```

- for with miniloader
```bash
lchy0113@kdiwin-nb:~/Develop/Rockchip/rk3568b2/Android11/rk3568_android11/rkbin/tools$ ~/Develop/Rockchip/rockchip-linux/rkdeveloptool/rkdeveloptool db ../../u-boot/rk356x_spl_loader_v1.10.111.bin 
Downloading bootloader succeeded.
lchy0113@kdiwin-nb:~/Develop/Rockchip/rk3568b2/Android11/rk3568_android11/rkbin/tools$ ~/Develop/Rockchip/rockchip-linux/rkdeveloptool/rkdeveloptool ul ../../u-boot/rk356x_spl_loader_v1.10.111.bin 
Upgrading loader succeeded.
lchy0113@kdiwin-nb:~/Develop/Rockchip/rk3568b2/Android11/rk3568_android11/rkbin/tools$ ~/Develop/Rockchip/rockchip-linux/rkdeveloptool/rkdeveloptool wl 0x40 ../../u-boot/uboot.im
```
### 2.1 Boot from eMMC



-----

## rockusb

### 소개
rockusb 는 Rockchip에서 공급하는 Rockchip SoCs firmware download vendor specific USB class입니다. 

### rockusb 진입
 rockusb 진입하는 방법.  
 (1) maskrom mode, chip에 firmware가 없는 경우 maskrom rockusb driver를 실행합니다.   
 (2) usbplug mode.  
 (3) miniLoader rockusb mode, miniloader rockusb driver를 실행합니다.  
 (4) uboot rockusb mode  
 
#### (1) maskrom mode
bootable firmware가 보드에 없는 경우, SoC는 **rockusb** driver를 자동으로 실행합니다. 이것을 Bootrom 또는 Maskrom mode라고 부릅니다. 
> "reboot bootrom" command를 u-boot 나 kernel에서 입력해서 진입가능합니다. 

maskrom mode 에서는 DRAM은 이용가능 할 수 없습니다. 그래서 download size는 내부 memory size만큼 제한이 있습니다.   
maskrom mode에서 가능한 명령어
 - 'db' command : 시스템은 DRAM 초기화, download size에 제한이 없는 usbplug(rockusb driver에 포함된) mode로 실행합니다.
 - 'ul' command : 'db' command를 수행하고, idbloader 를 emmc의 0x40 위치에 다운로드 합니다.
 - 'uf' command : 'db' command를 수행하고, update.img 를 emmc에 다운로드 합니다. 
> dram에 액세스하는데 필요한 모든 명령은 'db" command 를 수행한 후 진행할 있습니다.

#### (2) usbplug mode
usbplug 는 rkdeveloptool의 db command를 통하여 USB 다운로드 가능한 펌웨어로, 내부에 rockusb 드라이버가 존재하고있고, dram이 초기화된 이후에 사용가능합니다.


#### (3) miniloader rockusb mode
rockchip legacy image(with u-boot 2014.10)은 miniloader를 default USB firmware upgrade path로 사용합니다.  
miniloader rockusb mode에 진입하기
 - 'recovery' 또는 'volumn +' 키를 부팅 시 누릅니다. 
 - 다음 부팅 단계의 이미지를 찾을 수 없는 경우, 진입합니다.
	 ```
	 mmc erase 0x4000 0x2000
	 ```
 - 커널에서 "reboot loader" command 입력

> miniloader rockusb에서 rkdeveloptool의 offset 은 physical address가 아닙니다. physical address 0x0 ~ 0x2000 은 wl 명령어로 액세스 할수 없습니다. wl command에서 언급된  0x2000 은 physical address 에 0x2000을 더한 것 입니다. 
> ex. rkdeveloptool wl 0x2000 uboot.img 는 uboot.img 를 emmc 0x4000 위치에 writing 합니다.

#### (4) uboot rockusb mode
 - 'recovery' 또는 'volumn +' 키를 부팅 시 누릅니다. 
 - 커널에서 "reboot loader" command 입력
 - uboot 쉘에서 아래 명령어를 입력합니다.
 ```
 rockusb 0 mmc 0
 ```

### rockusb 의 usb vid/pid
rockchip vendor id : 0x2207
rk3568 product id : 0x350a


### firmware 다운로드
*rkdeveloptool*, *upgrade_tool*은 usb 인터페이스를 통해 rockusb protocol을 사용하여 firmware upgrade를 할수 있습니다. 

#### upgradetool
upgrade_tool은 linux 환경에서 firmware upgrade 툴 입니다. 
(ANDROID_ROOT)/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65/upgrade_tool 경로에 위치합니다.

upgradetool은 maskrom rockusb mode에서 아래 경로 이미지를 flash 합니다. 
(ANDROID_ROOT)/rockdev/Image-rk3568_r/

```bash
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65$ ./upgrade_tool ul
Program Data in /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65
Loading loader...
Support Type:RK3568     Loader ver:1.01 Loader Time:2022-06-16 15:56:49
Upgrade loader ok.
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65$ ./upgrade_tool di -p /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/rockdev/Image-rk3568_r/parameter.txt
Program Data in /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65
directlba=1,first4access=1,gpt=1
Write gpt...
Write gpt ok.
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65$ ./upgrade_tool di -p /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/rockdev/Image-rk3568_r/parameter.txt^C
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65$ ./upgrade_tool pl
Program Data in /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65
Partition Info(gpt):
NO  LBA        Size       Name
01  0x00002000 0x00002000 security
02  0x00004000 0x00002000 uboot
03  0x00006000 0x00002000 trust
04  0x00008000 0x00002000 misc
05  0x0000a000 0x00002000 dtbo
06  0x0000c000 0x00000800 vbmeta
07  0x0000c800 0x00014000 boot
08  0x00020800 0x00030000 recovery
09  0x00050800 0x000c0000 backup
10  0x00110800 0x000c0000 cache
11  0x001d0800 0x00008000 metadata
12  0x001d8800 0x00000800 baseparameter
13  0x001d9000 0x00614000 super
14  0x007ed000 0x0325cfc0 userdata
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65$ ./upgrade_tool di -u /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/u-boot/uboot.img
Program Data in /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65
directlba=1,first4access=1,gpt=1
Download uboot start...(0x00004000)
Download image ok.
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65$ ./upgrade_tool rd
Program Data in /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65
Reset Device OK.
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/RKTools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65$
```

#### rkdeveloptool
rkdeveloptool은 Rockusb device와 통신하기 위한 Rockchip사의 tool로, upgrade_tool의 오픈 소스 버전 입니다.(upgrade_tool과 차이가 없습니다.)

- downlaod rkdeveloptool
```bash
git clone https://github.com/rockchip-linux/rkdeveloptool.git
```

- build rkdeveloptool
```
sudo apt-get install libudev-dev libusb-1.0-0-dev dh-autoreconf
```
then
```
autoreconf -i
./configure
make
make install
```

- flash image to target emmc
1. target는 rockusb mode로 진입합니다.
2. host pc와 usb interface 연결합니다.
3. emmc에 tool command를 사용하여 write 합니다.
```bash
lchy0113@kdiwin-nb:~/Develop/Rockchip/rockchip-linux/rkdeveloptool$ ./rkdeveloptool db /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/u-boot/rk356x_spl_loader_v1.10.111.bin

Downloading bootloader succeeded.
lchy0113@kdiwin-nb:~/Develop/Rockchip/rockchip-linux/rkdeveloptool$ ./rkdeveloptool ef
Erasing flash complete.

lchy0113@kdiwin-nb:~/Develop/Rockchip/rockchip-linux/rkdeveloptool$ ./rkdeveloptool rd
Reset Device OK.

lchy0113@kdiwin-nb:~/Develop/Rockchip/rockchip-linux/rkdeveloptool$ ./rkdeveloptool ld
DevNo=1 Vid=0x2207,Pid=0x350a,LocationID=103    Maskrom

lchy0113@kdiwin-nb:~/Develop/Rockchip/rockchip-linux/rkdeveloptool$ ./rkdeveloptool db /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/u-boot/rk356x_spl_loader_v1.10.111.bin
Downloading bootloader succeeded.

lchy0113@kdiwin-nb:~/Develop/Rockchip/rockchip-linux/rkdeveloptool$ ./rkdeveloptool ul /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/u-boot/rk356x_spl_loader_v1.10.111.bin
Upgrading loader succeeded.

lchy0113@kdiwin-nb:~/Develop/Rockchip/rockchip-linux/rkdeveloptool$ ./rkdeveloptool gpt /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/rockdev/Image-rk3568_r/parameter.txt
Writing gpt succeeded.

lchy0113@kdiwin-nb:~/Develop/Rockchip/rockchip-linux/rkdeveloptool$ ./rkdeveloptool ppt
**********Partition Info(GPT)**********
NO  LBA       Name
00  00002000  security
01  00004000  uboot
02  00006000  trust
03  00008000  misc
04  0000A000  dtbo
05  0000C000  vbmeta
06  0000C800  boot
07  00020800  recovery
08  00050800  backup
09  00110800  cache
10  001D0800  metadata
11  001D8800  baseparameter
12  001D9000  super
13  007ED000  userdata
lchy0113@kdiwin-nb:~/Develop/Rockchip/rockchip-linux/rkdeveloptool$ ./rkdeveloptool rd
Reset Device OK.

lchy0113@kdiwin-nb:~/Develop/Rockchip/rockchip-linux/rkdeveloptool$ ./rkdeveloptool wl 0x4000 /home/lchy0113/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/u-boot/uboot.img
Write LBA from file (100%)

lchy0113@kdiwin-nb:~/Develop/Rockchip/rockchip-linux/rkdeveloptool$ ./rkdeveloptool rd
Reset Device OK.
```
4. flash image to each partition
```bash

lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID12/rockdev/Image-rk3568_s$ fastboot flash misc misc.img
Sending 'misc_a' (48 KB)                           OKAY [  0.006s]
Writing 'misc_a'                                   OKAY [  0.026s]
Finished. Total time: 0.056s
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID12/rockdev/Image-rk3568_s$ fastboot flash dtbo dtbo.img
Sending 'dtbo_a' (0 KB)                            OKAY [  0.001s]
Writing 'dtbo_a'                                   OKAY [  0.006s]
Finished. Total time: 0.026s
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID12/rockdev/Image-rk3568_s$ fastboot flash boot boot.img
Sending 'boot_a' (30136 KB)                        OKAY [  1.260s]
Writing 'boot_a'                                   OKAY [  0.228s]
Finished. Total time: 4.167s
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID12/rockdev/Image-rk3568_s$ fastboot flash recovery recovery.img
Invalid sparse file format at header magic
Sending sparse 'recovery_a' 1/2 (65532 KB)         OKAY [  2.902s]
Writing 'recovery_a'                               OKAY [  0.511s]
Sending sparse 'recovery_a' 2/2 (31632 KB)         OKAY [  1.388s]
Writing 'recovery_a'                               OKAY [  0.237s]
Finished. Total time: 13.646s
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID12/rockdev/Image-rk3568_s$ fastboot flash baseparameter baseparameter.img
Sending 'baseparameter_a' (1024 KB)                OKAY [  0.093s]
Writing 'baseparameter_a'                          OKAY [  0.017s]
Finished. Total time: 0.128s
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID12/rockdev/Image-rk3568_s$ fastboot flash super super.img
Sending sparse 'super_a' 1/27 (65532 KB)           OKAY [  5.882s]
Writing 'super_a'                                  OKAY [  0.486s]
Sending sparse 'super_a' 2/27 (63536 KB)           OKAY [  5.681s]
Writing 'super_a'                                  OKAY [  0.479s]
Sending sparse 'super_a' 3/27 (61604 KB)           OKAY [  5.477s]
Writing 'super_a'                                  OKAY [  0.450s]
Sending sparse 'super_a' 4/27 (58132 KB)           OKAY [  5.221s]
Writing 'super_a'                                  OKAY [  0.442s]
Sending sparse 'super_a' 5/27 (65532 KB)           OKAY [  5.807s]
Writing 'super_a'                                  OKAY [  0.472s]
Sending sparse 'super_a' 6/27 (65532 KB)           OKAY [  5.869s]
Writing 'super_a'                                  OKAY [  0.477s]
Sending sparse 'super_a' 7/27 (65532 KB)           OKAY [  5.736s]
Writing 'super_a'                                  OKAY [  2.264s]
Sending sparse 'super_a' 8/27 (65534 KB)           OKAY [  5.701s]
Writing 'super_a'                                  OKAY [  2.935s]
Sending sparse 'super_a' 9/27 (64524 KB)           OKAY [  5.763s]
Writing 'super_a'                                  OKAY [  0.466s]
Sending sparse 'super_a' 10/27 (59524 KB)          OKAY [  5.380s]
Writing 'super_a'                                  OKAY [  0.460s]
Sending sparse 'super_a' 11/27 (65532 KB)          OKAY [  5.865s]
Writing 'super_a'                                  OKAY [  0.472s]
Sending sparse 'super_a' 12/27 (65532 KB)          OKAY [  5.863s]
Writing 'super_a'                                  OKAY [  0.473s]
Sending sparse 'super_a' 13/27 (65532 KB)          OKAY [  5.839s]
Writing 'super_a'                                  OKAY [  0.497s]
Sending sparse 'super_a' 14/27 (65532 KB)          OKAY [  5.875s]
Writing 'super_a'                                  OKAY [  0.472s]
Sending sparse 'super_a' 15/27 (58232 KB)          OKAY [  5.191s]
Writing 'super_a'                                  OKAY [  0.464s]
Sending sparse 'super_a' 16/27 (65532 KB)          OKAY [  5.884s]
Writing 'super_a'                                  OKAY [  1.368s]
Sending sparse 'super_a' 17/27 (65535 KB)          OKAY [  5.861s]
Writing 'super_a'                                  OKAY [  0.834s]
Sending sparse 'super_a' 18/27 (65532 KB)          OKAY [  5.794s]
Writing 'super_a'                                  OKAY [  0.477s]
Sending sparse 'super_a' 19/27 (65532 KB)          OKAY [  5.897s]
Writing 'super_a'                                  OKAY [  0.470s]
Sending sparse 'super_a' 20/27 (58492 KB)          OKAY [  5.192s]
Writing 'super_a'                                  OKAY [  0.445s]
Sending sparse 'super_a' 21/27 (58180 KB)          OKAY [  5.256s]
Writing 'super_a'                                  OKAY [  0.420s]
Sending sparse 'super_a' 22/27 (59048 KB)          OKAY [  5.430s]
Writing 'super_a'                                  OKAY [  0.448s]
Sending sparse 'super_a' 23/27 (64092 KB)          OKAY [  5.716s]
Writing 'super_a'                                  OKAY [  0.500s]
Sending sparse 'super_a' 24/27 (65532 KB)          OKAY [  5.821s]
Writing 'super_a'                                  OKAY [  0.473s]
Sending sparse 'super_a' 25/27 (65532 KB)          OKAY [  5.842s]
Writing 'super_a'                                  OKAY [  0.471s]
Sending sparse 'super_a' 26/27 (65532 KB)          OKAY [  5.845s]
Writing 'super_a'                                  OKAY [  0.484s]
Sending sparse 'super_a' 27/27 (1148 KB)           OKAY [  0.100s]
Writing 'super_a'                                  OKAY [  0.024s]
Finished. Total time: 167.641s
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID12/rockdev/Image-rk3568_s$ fastboot flash vbmeta vbmeta.img
Sending 'vbmeta_a' (4 KB)                          OKAY [  0.001s]
Writing 'vbmeta_a'                                 OKAY [  0.005s]
Finished. Total time: 0.024s
lchy0113@kdiwin-nb:~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID12/rockdev/Image-rk3568_s$ fastboot reboot
Rebooting                                          OKAY [  0.001s]
Finished. Total time: 0.051s
```
- references : http://opensource.rock-chips.com/wiki_Boot_option
