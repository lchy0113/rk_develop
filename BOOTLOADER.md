# rk_bootloader interoduce

## version
RK3568 SDK에 사용되는 부트로더(next-dev)는 RK사에서 v2017.09(official version) 기반에서 개발한 버전이며 RK3568 AP를 공식적으로 지원합니다.

> RK의 U-Boot에는 이전 버전 v2014 및 새 버전 v2017의 두 가지 버전이 있으며 내부 이름은 각각 rkdevelop 및 next-dev입니다.

next-dev는 아래 기능을 지원합니다. 

- Support RK Android firmware boot;
- Support Android AOSP firmware boot;
- Support Linux Distro firmware boot;
- Support both Rockchip miniloader and SPL/TPL pre-loader boot;
- Support LVDS, EDP, MIPI, HDMI, CVBS, RGB and other display devices;
- Support eMMC, Nand Flash, SPI Nand flash, SPI NOR flash, SD card, U disk and other storage devices to start;
- Support FAT, EXT2, EXT4 file system;
- Support GPT, RK parameter partition table;
- Support boot LOGO, charging animation, low power management, power management;
- Support I2C, PMIC, CHARGE, FUEL GUAGE, USB, GPIO, PWM, GMAC, eMMC, NAND, Interrupt, etc.;
- Support Vendor storage to save user's data and configuration;
- Support both RockUSB and Google Fastboot USB gadgets to program eMMC;
- Support Mass storage, ethernet, HID and other USB devices;
- Support dynamic selection of kernel DTB by hardware state;

## DM
DM(Driver Model)은 커널의 Device-driver와 유사한 u-boot의 standard device-driver 개발 모델 입니다. 
v2017 버전은 DM framework을 따라 module을 개발합니다. 

[driver model in u-boot|https://www.linux4sam.org/bin/view/Linux4SAM/DriverModelInUBoot]

## Boot-order
front-level loader code의 open source여부에 따라서 RK platform 은 2가지 startup methods 를 제공합니다. 
- pre-loader closed source <br/>
	BOOTROM ▶️ ddr bin ▶️ Miniloader ▶️ TRUST ▶️ U-boot ▶️ KERNEL
- open source pre-loader <br/>
	BOOTROM ▶️ TPL ▶️ SPL ▶️ TRUST ▶️ U-BOOT ▶️ KERNEL

> TPL은 ddr bin과 동일하고, SPL은 Miniloader 와 동일한 기능을 제공합니다. 
> 즉 TPL+SPL 의 조합은 rk 코드  ddr.bin=miniloader와 동일한 기능을 제공하며 서로 교체되어 사용할 수 있습니다.

## TPL/SPL/U-Boot-proper
U-Boot는 하나의 코드에서 TPL/SPL/U-Boot-proper이라는 컴파일 조건을 사용하여 각각 다른 기능을 가진 로더를 얻을 수 있습니다. 
TPL(Tiny Program Loader) 과 SPL(Secondary Program Loader)는 U-Boot 이전의 로더 입니다. 
- TPL : SRAM에서 실행되며 DDR(DRAM)초기화를 담당합니다.
- SPL : DDR에서 실행되며, system의 lowlevel initialization & latter firmware(trust.img, u-boot.img) 로드를 담당합니다. 
- U-Boot-proper : DDR에서 실행되며, kernel의 booting을 담당합니다. 
> Note : U-Boot-proper 용어는 SPL과 구별하기 위한 것입니다. 일반적으로 U-Boot는 U-Boot-proper을 의미 합니다. 

부팅 절차 :
BOOTROM ▶️ TPL(ddr bin) ▶️ SPL(miniloader) ▶️ TRUST ▶️ U-BOOT ▶️ KERNEL
> Note : More references : doc/README.TPL and doc/README.SPL

## Build-Output
U-Boot가 빌드 되면, root directory에 file이 생성됩니다. (TPL/SPL은 지원되는 경우에만 생성됩니다.)

```bash
// U-Boot
u-boot$ ls -alh u-boot*
-rwxr-xr-x 1 lchy0113 lchy0113 9.9M  4월 13 08:23 u-boot				// ELF file, similar to the kernel's vmlinux (important!)
-rw-r--r-- 1 lchy0113 lchy0113 1.2M  4월 13 08:23 u-boot.bin			// Executable binary file will be packaged into uboot.img for programming
-rw-r--r-- 1 lchy0113 lchy0113  18K  4월 13 08:23 u-boot.cfg
-rw-r--r-- 1 lchy0113 lchy0113  12K  4월 13 08:23 u-boot.cfg.configs
-rw-r--r-- 1 lchy0113 lchy0113  14K  4월 13 08:23 u-boot.dtb			// u-boot's own dtb file
-rw-r--r-- 1 lchy0113 lchy0113 1.2M  4월 13 08:23 u-boot-dtb.bin
-rw-r--r-- 1 lchy0113 lchy0113 1.3K  4월  7 14:21 u-boot.lds
-rw-r--r-- 1 lchy0113 lchy0113 966K  4월 13 08:23 u-boot.map			// MAP table file
-rwxr-xr-x 1 lchy0113 lchy0113 1.2M  4월 13 08:23 u-boot-nodtb.bin
-rwxr-xr-x 1 lchy0113 lchy0113 3.4M  4월 13 08:23 u-boot.srec
-rw-r--r-- 1 lchy0113 lchy0113 374K  4월 13 08:23 u-boot.sym			// SYMBOL table file

```

```bash
u-boot$ ls -alh spl/u-boot*
-rw-r--r-- 1 lchy0113 lchy0113  18K  4월 13 08:23 spl/u-boot.cfg
-rwxr-xr-x 1 lchy0113 lchy0113 3.3M  4월 13 08:23 spl/u-boot-spl			// ELF file, similar to the kernel's vmlinux (important!)
-rw-r--r-- 1 lchy0113 lchy0113 231K  4월 13 08:23 spl/u-boot-spl.bin		// Executable binary file, which will be packaged into a loader for programming
-rw-r--r-- 1 lchy0113 lchy0113  14K  4월 13 08:23 spl/u-boot-spl.dtb		// spl's own dtb file
-rw-r--r-- 1 lchy0113 lchy0113 231K  4월 13 08:23 spl/u-boot-spl-dtb.bin
-rw-r--r-- 1 lchy0113 lchy0113 1.1K  4월  7 14:21 spl/u-boot-spl.lds
-rw-r--r-- 1 lchy0113 lchy0113 316K  4월 13 08:23 spl/u-boot-spl.map		// MAP table file
-rwxr-xr-x 1 lchy0113 lchy0113 217K  4월 13 08:23 spl/u-boot-spl-nodtb.bin
-rw-r--r-- 1 lchy0113 lchy0113 113K  4월 13 08:23 spl/u-boot-spl.sym		// SYMBOL table file

```

```bash
u-boot$ ls -alh tpl/u-boot*
-rw-r--r-- 1 lchy0113 lchy0113  18K  4월 13 08:23 tpl/u-boot.cfg
-rw-r--r-- 1 lchy0113 lchy0113  985  4월  7 14:21 tpl/u-boot-spl.lds
-rwxr-xr-x 1 lchy0113 lchy0113 284K  4월 13 08:23 tpl/u-boot-tpl			// ELF file, similar to the kernel's vmlinux (important!)
-rwxr-xr-x 1 lchy0113 lchy0113 1.2K  4월 13 08:23 tpl/u-boot-tpl.bin		// The executable binary file will be packaged into a loader for prgramming
-rw-r--r-- 1 lchy0113 lchy0113  38K  4월 13 08:23 tpl/u-boot-tpl.map		// MAP table file
-rwxr-xr-x 1 lchy0113 lchy0113 1.2K  4월 13 08:23 tpl/u-boot-tpl-nodtb.bin
-rw-r--r-- 1 lchy0113 lchy0113 5.1K  4월 13 08:23 tpl/u-boot-tpl.sym		// SYMBOL table file
```

## U-Boot DTS
U-Boot에는 자체 DTS 파일이 있어 컴파일 시, 해당 DTB 파일을 자동으로 생성하며 u-boot.bin 끝에 추가됩니다.
File directory :
```
arch/arm/dts/
```

각 플랫폼에서 사용되는 DTS파일은 defconfig의 *CONFIG_DEFAULT_DEVICE_TREE*에 의해 정의됩니다.

## Relocation
부트 단계에서 U-Boot는 이전단계의 부트로더에 의해 DRAM의 low address에 로드됩니다. 
U-Boot는 board_f.c의 프로세스를 완료한 후, 메모리 끝의 예약된 주소로 redirect(relocation, 이 주소는 U-Boot 메모리 레이아웃에 따라 결정됨)하고 relocation 완료 후, board_r.c 프로세스를 완료합니다. 
부팅 정보로 확인할 수 있습니다.
```bash
AK7755 : Master
TCC : SlaveU-Boot 2017.09 #lchy0113 (Apr 13 2022 - 08:23:57 +0900)

Model: Rockchip RK3568 Evaluation Board
PreSerial: 2, raw, 0xfe660000
DRAM:  2 GiB
Sysmem: init
Relocation Offset: 7d352000
Relocation fdt: 7b9f8530 - 7b9fecd8
CR: M/C/I
Using default environment
...
```

<hr/>

# RK architecture

## storage layout
Default storage map

|           Partition          	| Start Sector 	|          	| Number of Sectors 	|          	| Partition Size 	|        	| PartNum in GPT 	|             Requirements             	|
|:----------------------------:	|:------------:	|:--------:	|:-----------------:	|:--------:	|:--------------:	|:------:	|:--------------:	|:------------------------------------:	|
| MBR                          	| 0            	| 00000000 	| 1                 	| 00000001 	| 512            	| 0.5KB  	|                	|                                      	|
| Primary GPT                  	| 1            	| 00000001 	| 63                	| 0000003F 	| 32256          	| 31.5KB 	|                	|                                      	|
| loader1                      	| 64           	| 00000040 	| 7104              	| 00001bc0 	| 4096000        	| 2.5MB  	| 1              	| preloader (miniloader or U-Boot SPL) 	|
| Vendor Storage               	| 7168         	| 00001c00 	| 512               	| 00000200 	| 262144         	| 256KB  	|                	| SN, MAC and etc.                     	|
| Reserved Space               	| 7680         	| 00001e00 	| 384               	| 00000180 	| 196608         	| 192KB  	|                	| Not used                             	|
| reserved1                    	| 8064         	| 00001f80 	| 128               	| 00000080 	| 65536          	| 64KB   	|                	| legacy DRM key                       	|
| U-Boot ENV                   	| 8128         	| 00001fc0 	| 64                	| 00000040 	| 32768          	| 32KB   	|                	|                                      	|
| reserved2                    	| 8192         	| 00002000 	| 8192              	| 00002000 	| 4194304        	| 4MB    	|                	| legacy parameter                     	|
| loader2                      	| 16384        	| 00004000 	| 8192              	| 00002000 	| 4194304        	| 4MB    	| 2              	| U-Boot or UEFI                       	|
| trust                        	| 24576        	| 00006000 	| 8192              	| 00002000 	| 4194304        	| 4MB    	| 3              	| trusted-os like ATF, OP-TEE          	|
| boot（bootable must be set） 	| 32768        	| 00008000 	| 229376            	| 00038000 	| 117440512      	| 112MB  	| 4              	| kernel, dtb, extlinux.conf, ramdisk  	|
| rootfs                       	| 262144       	| 00040000 	| -                 	| -        	| -              	| -MB    	| 5              	| Linux system                         	|
| Secondary GPT                	| 16777183     	| 00FFFFDF 	| 33                	| 00000021 	| 16896          	| 16.5KB 	|                	|                                      	|
> Note 1: If preloader is miniloader, loader2 partition available for uboot.img and trust partition available for trust.img; if preloader is SPL without trust support, loader2 partition is available for u-boot.bin and trust partition not available; If preloader is SPL with trust support(ATF or OPTEE), loader2 is available for u-boot.itb(including u-boot.bin and trust binary) and trust partition not available.
>
>

## ATAGS parameters
RK platform의 부팅 프로세스 :  
```
BOOTROM ➡️ ddr-bin ➡️ Miniloader ➡️ TRUST ➡️ U-BOOT ➡️ KERNEL
```
