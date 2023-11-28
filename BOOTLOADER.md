# BOOTLOADER

## rk_bootloader interoduce

### version
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

### DM
DM(Driver Model)은 커널의 Device-driver와 유사한 u-boot의 standard device-driver 개발 모델 입니다. 
v2017 버전은 DM framework을 따라 module을 개발합니다. 
  
https://www.linux4sam.org/bin/view/Linux4SAM/DriverModelInUBoot
  
### Boot-order
front-level loader code의 open source여부에 따라서 RK platform 은 2가지 startup methods 를 제공합니다. 
- pre-loader closed source <br/>
	BOOTROM ▶️ ddr bin ▶️ Miniloader ▶️ TRUST ▶️ U-boot ▶️ KERNEL
- open source pre-loader <br/>
	BOOTROM ▶️ TPL ▶️ SPL ▶️ TRUST ▶️ U-BOOT ▶️ KERNEL

> TPL은 ddr bin과 동일하고, SPL은 Miniloader 와 동일한 기능을 제공합니다. 
> 즉 TPL+SPL 의 조합은 rk 코드  ddr.bin=miniloader와 동일한 기능을 제공하며 서로 교체되어 사용할 수 있습니다.

### TPL/SPL/U-Boot-proper
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

### U-Boot DTS
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
<br/>
<br/>
<br/>
<hr/>

## RK source code architecture

```bash
(uboot)/arch/arm/include/asm/arch-rockchip/
(uboot)/arch/arm/mach-rockchip/
(uboot)/board/rockchip/
(uboot)/include/configs/

(uboot)/configs/

(uboot)/arch/arm/mach-rockchip/board.c
```

### 플랫폼 구성
- configure file : 플랫폼의 configuration  option 및 parameter는 일반적으로 다음 위치에 있습니다.
```bash
//Public files of each platform (developers usually do not need to modify)
(uboot)/arch/arm/mach-rockchip/Kconfig
(uboot)/include/configs/rockchip-common.h

//Unique to each platform, take rk3568 as an example
(uboot)/include/configs/rk3568_common.h
(uboot)/include/configs/evb_rk3568.h
(uboot)/configs/rk3568_defconfig
```

### start process
RK platform의 u-boot startup process는 아래와 같습니다. 

```bash
arch/arm/cpu/armv8/start.S
// Assembly environment
// ARM architecture related lowlevel initialization
	|
	+-> _main
		|
		+-> stack	// Prepare the stack required by the C environment
		|	// [Phase 1] Initialize the C environment and initiate a series of function calls
		+-> board_init_f() // common/board_f.c
		|	|
		|	+-> initf_malloc
		|		arch_cpu_init		// 【SoC lowlevel initialization】
		|		serial_init 		// serial port initialization
		|		dram_init 		    // 【get ddr capacity information】
		|	 	reserve_mmu		    // reserve memory from the end of ddr to lower addresses
		|		reserve_video
		|		reserve_uboot
		|		reserve_malloc
		|		reserve_global_data
		|		reserve_fdt
		|		reserve_stacks
		|		dram_init_banksize
		|		sysmem_init
		|		setup_reloc			// Determine the address to be relocated by U-Boot itself
		|		// assembly environment
		|-> relocate_code			// Assemble the relocation of U-Boot code
		|	// [Phase 2] Initialize the C environment and initiate a series of function calls
		|-> board_init_r // common/board_r.c
		|	|
		|	+-> initr_caches		// Enable MMU and I/D cache
		|	|	initr_malloc
		|	|	bidram_initr
		|	|	sysmem_initr
		|	|	initr_of_live		// Initialize of_line
		|	|	initr_dm			// Initialize the dm frame
		|	|	board_init		    // 【platform initialization, the most core part】
		|	|	board_debug_uart_init		// Serial port iomux, clk configuration
		|	|	init_kernel_dtb				// 【cut to kernel dtb】!
		|	|	clks_probe					// Initialize system frequency
		|	|	regulators_enable_boot_on	// Initialize system power
		|	|	io_domain_init				// io-domain initialization
		|	|	set_armclk_rate				// __weak, ARM frequency increase (the platform needs to be implemented)
		|	|	dvfs_init					// Frequency modulation and voltage regulation of wide temperature chips
		|	|	rk_board_init				// __weak, implemented by each specific platform
		|	console_init_r
		|	board_late_init					// 【Platform late initialization 】
		|	+->	rockchip_set_ethaddr		// Set mac address
		|	+->	rockchip_set_serialno		// set serialno
		|	+->	setup_boot_mode				// Parse the "reboot xxx" command,
											// Identify buttons and loader programming mode,
recovery	
		+->	charge_display			// U-boot charging	
		+->	rockchip_show_logo		// Show the boot logo 
		+->	soc_clk_dump			// Print clk tree
		+->	rk_board_late_init		// __weak, implemented by each specific platform
	run_main_loop		// 【Enter the command line mode, or execute the startup command 】
			
```

### storage layout
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

### Kernel-DTB
 RK 플랫폼은 kernel dtb mechanism을 지원합니다. 커널 dtb를 사용하여 주변 장치를 초기화 합니다. 
 power, clock, display, 등과 같은 정보를 호환합니다.
 - u-boot dtb : storage, serial port 및 다른 장치를 초기화 합니다. 
 - kernel dtb : storage, printing devices 외 serial port를 초기화 합니다.

 U-Boot가 초기화되면 먼저 U-Boot DTB를 사용하여 storage 초기화를 완료하고 serial port를 출혁한 다음 storage에서 Kernel DTB를 로드하고 이 DTB를 사용하여 다른 주변 장치를 계속 초기화합니다. 
 Kernel DTB의 코드는 init_kernel_dtb() 함수에서 구현됩니다.

 일반적으로 개발자는 U-Boot DTB를 수정할 필요가 없습니다.(print serial port가 변경되지 않는 한) 각 플랫폼에서 릴리스된 SDK에서 사용되는 defconfig는 kernel DTB 메커니즘을 활성화합니다.


 u-boot dtb 정보:
 dts :
```bash
./arch/arm/dts/
```
 kernel dtb mechanism 이 활성화 된 후, compile 단계에서 u-boot dts의 u-boot, dm-pre-reloc 및 u-boot, dm-spl properties이 있는 노드가 필터링 되고, 이를 기반으로 defconfig에서 CONFIG_OF_SPL_REMOVE_PROPS에 의해 지정된 property 이 제거되고 마지막으로 u-boot.dtb파일을 생성하여 U-boot.bin 이미지의 끝에 추가합니다.

 u-boot를 컴파일 한 후, 사용자는 fdtdump 명령을 통해 dtb내용을 확인 할 수 있습니다.
```bash
fdtdump ./u-boot.dtb | less
```

## ATAGS parameters
RK platform의 부팅 프로세스 :  
```
BOOTROM ➡️ ddr-bin ➡️ Miniloader ➡️ TRUST ➡️ U-BOOT ➡️ KERNEL
```

## U-Boot 부트 펌웨어
 u-boot 와 RK platform의 trust는 2가지 firmware format이 있습니다. 
 RK 및 FIT format은 Miniloader 및 SPL에 의해 guide 됩니다. 

 - RK foramt
	 : Rockchip 의 custom firmware format 입니다. u-boot와 trust는 각각 uboot.img 및  trust.img로 패키징 됩니다. uboot.img 및 trust.img 이미지 파일의 magic 값은 "LOADER" 입니다.

 - FIT format
	 : u-boot mainline에서 지원하는 very flexible firmware format입니다. u-boot, trust, mcu와 같은 펌웨어는 uboot.img로 패키징 됩니다. 
	 uboot.img 이미지의 magic값은 "d0 0d fe ed"이며, fdtdump uboot.img 명령을 사용하여 펍웨어 헤더를 확인합니다.


## 단축키
RK플랫폼은 디버깅 및 프로그래밍을 위해 단축어 트리거를 U-BOOT에서 지원합니다. 
 * ctrl+c: Enter U-Boot command line mode;
 * ctrl+d: enter loader programming mode;
 * ctrl+b: enter maskrom programming mode;
 * ctrl+f: enter fastboot mode;
 * ctrl+m: print bidram/system information;
 * ctrl+i: enable kernel initcall_debug;
 * ctrl+p: print cmdline information;
 * ctrl+s: Enter U-Boot command line after "Starting kernel...";

## make.sh 스크립트 파일 (u-boot)
make.sh는 컴파일 스크립트일 뿐만 아니라 패키징 및 디버깅 도구이기도 합니다. 펌웨어를 분해하고 패키징하는 데 사용할 수 있습니다.
```bash

lchy0113@df9836d77478:~/Develop/Rockchip/rk3568b2/Android11/rk3568_android11/u-boot$ ./make.sh help

Usage:
        ./make.sh [board|sub-command]

         - board:        board name of defconfig
         - sub-command:  elf*|loader|trust|uboot|--spl|--tpl|itb|map|sym|<addr>
         - ini:          ini file to pack trust/loader

Output:
         When board built okay, there are uboot/trust/loader images in current directory

Example:

1. Build:
        ./make.sh evb-rk3399               --- build for evb-rk3399_defconfig
        ./make.sh firefly-rk3288           --- build for firefly-rk3288_defconfig
        ./make.sh EXT_DTB=rk-kernel.dtb    --- build with exist .config and external dtb
        ./make.sh                          --- build with exist .config
        ./make.sh env                      --- build envtools

2. Pack:
        ./make.sh uboot                    --- pack uboot.img
        ./make.sh trust                    --- pack trust.img
        ./make.sh trust <ini>              --- pack trust img with assigned ini file
        ./make.sh loader                   --- pack loader bin
        ./make.sh loader <ini>             --- pack loader img with assigned ini file
        ./make.sh --spl                    --- pack loader with u-boot-spl.bin
        ./make.sh --tpl                    --- pack loader with u-boot-tpl.bin
        ./make.sh --tpl --spl              --- pack loader with u-boot-tpl.bin and u-boot-spl.bin

3. Debug:
        ./make.sh elf                      --- dump elf file with -D(default)
        ./make.sh elf-S                    --- dump elf file with -S
        ./make.sh elf-d                    --- dump elf file with -d
        ./make.sh elf-*                    --- dump elf file with -*
        ./make.sh <no reloc_addr>          --- unwind address(no relocated)
        ./make.sh <reloc_addr-reloc_off>   --- unwind address(relocated)
        ./make.sh map                      --- cat u-boot.map
        ./make.sh sym                      --- cat u-boot.sym

```

<hr/>
<br/>
<br/>
<br/>
<hr/>

# Compilation and programming
## 준비 : rkbin, GCC
 * rkbin
    - RK에서 제공하는 bin, scripts, packaging tool 저장소 입니다. (open source X) u-boot 컴파일 시, warehouse에서 관련 파일을 index하고, loader, trust, uboot firmware를 패키징 및 생성합니다.
    - https://github.com/rockchip-linux/rkbin
	> (rk3568_android11 or rk3568_android12)/rkbin 경로에 존재
 * GCC
    - 32bit : prebuilts/gcc/linux-x86/arm/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf/
	- 64bit : prebuilts/gcc/linux-x86/aarch64/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu/ 
 * defconfig 
   | chip   	| defconfig                     	| support kernel dtb 	| comment                      	|
   |--------	|-------------------------------	|--------------------	|------------------------------	|
   | rk3568 	| rk3568_defconfig              	| y                  	| generic version              	|
   |        	| rk3568-spl-spi-nand-defconfig 	| y                  	| eMMC, SPI-nand dedicated SPL 	|

   - config fragment 소개
      제품의 다양화 및 차별화된 요구사항으로 인해 defconfig로 충족할 수 없습니다. config gragment, 즉 defconfig를 overlay 하는 것을 지원합니다. 
	  예를 들어, CONFIG_BASE_DEFCONFIG="rk3568_defconfig"는 configs/rk3568-spi-nand.config, configs/rk3566.config에 선언되어 있습니다. . 
	   단일 플랫폼에서 제품의 차별화된 요구 사항으로 인해 defconfig는 더 이상 충족할 수 없습니다. 그래서 RV1126부터는 config fragment, 즉 defconfig를 오버레이하는 것을 지원합니다.

	   예를 들면: CONFIG_BASE_DEFCONFIG="rv1126_defconfig"는 rv1126-emmc-tb.config에 지정되어 있습니다. .config가 사용됩니다. .config 오버레이의 구성입니다.

	   이 명령은 다음과 같을 수 있습니다.

## 프로그래밍 
 * programming mode : RK platform은 2가지 programming mode(loader mode, maskrom mode)가 있습니다. 
   - loader mode(u-boot)
	 + Loader programming mode 진입방법  
	   = 전원 인가 시, volume + 버튼을 누른다.   
	   = 부팅 시, ctrl+d 단축어를 입력한다.  
	   = console에서 "download" 또는 "$ rockusb 0 $devtype $devnum" 입력한다.  
   - maskrom mode  
     + 부팅 시, ctrl+b 단축어를 입력한다.  
	 + console에서 "rbrom"을 입력한다.   


## 빌드 명령어
make.sh 는 compile script 이며, 외에 firmware packaging 및 디버깅 툴 입니다.   
package firmware를 분해(disassemble) 및 패키징하는데 사용할 수 있습니다.
- Non-FIT format:
```bash
./make.sh trust 		// trust image package
./make.sh loader		// loader image package
./make.sh trust <ini-file> // trust image package시, ini파일을 지정한다.  지정하지 않은 경우 default ini 파일이 사용됨.
./make.sh loader <ini-file> // loader image package시, ini파일을 지정한다. 지정하지 않은 경우 default ini 파일이 사용됨.
```

- FIT format:
```bash
// old script :
./make.sh spl  // ddr 및 miniloader를 tpl+spl로 교체하고, packages 
./make.sh spl -s // ddr 및 miniloader를 tpl=spl로 교체하고, packages


// new script :
./make.sh --spl // miniloader를 spl로 교체하고 loader에 packages
./make.sh --tpl // ddr 을 tpl로 교체하고 loader에 packages
./make.sh --tpl --spl // ddr 및 miniloader를 spl 및 tpl로 교체하고 loader에 packages
./make.sh --spl-new // ./make.sh --spl 명령어는 packages만 진행합니다. -new 옵션이 추가되면 recompile을 한 후, packages합니다. 
```

<hr/>
<br/>
<br/>
<br/>
<hr/>

# Write GPT partition
 ## Write GPT partition table through rkdeveloptool
 [rkdeveloptool](https://github.com/rockchip-linux/rkdeveloptool.git) 은 Rockusb 장치와 통신하기 위한 Rockchip의 tool입니다. 

```bash
// 1. boot device rockusb mode(maskrom mode)
// 2. connect target to host pc via usb interface.
$ ./rkdeveloptool ld
DevNo=1 Vid=0x2207,Pid=0x350a,LocationID=105    Maskrom

// 3. write the image to the eMMC with tool command.

$ ./rkdeveloptool --help 

---------------------Tool Usage ---------------------
Help:                   -h or --help
Version:                -v or --version
ListDevice:             ld
DownloadBoot:           db <Loader>
UpgradeLoader:          ul <Loader>
ReadLBA:                rl  <BeginSec> <SectorLen> <File>
WriteLBA:               wl  <BeginSec> <File>
WriteLBA:               wlx  <PartitionName> <File>
WriteGPT:               gpt <gpt partition table>
WriteParameter:         prm <parameter>
PrintPartition:         ppt
EraseFlash:             ef
TestDevice:             td
ResetDevice:            rd [subcode]
ReadFlashID:            rid
ReadFlashInfo:          rfi
ReadChipInfo:           rci
ReadCapability:         rcb
PackBootLoader:         pack
UnpackBootLoader:       unpack <boot loader>
TagSPL:                 tagspl <tag> <U-Boot SPL>
-------------------------------------------------------

// downloadboot 명령을 사용하여 타겟의 dram을 초기화 하고, usbplug을 실행합니다. 
$ ./rkdeveloptool db ~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/u-boot/rk356x_spl_loader_v1.10.111.bin
Downloading bootloader succeeded.

// upgradeloader 명령을 사용하여 rockchip loader 에서 idbLoader를 idb에 write합니다.
$ ./rkdeveloptool ul ~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/u-boot/rk356x_spl_loader_v1.10.111.bin
Upgrading loader succeeded.

// Note : upgradeloader 명령어는 rockchip miniloader를 사용하는 아래 명령어와 동일한 동작을 취합니다.
$ ./rkdeveloptool wl 0x40 idbLoader.img

// gpt 명령을 사용하여 gpt table을 write 합니다.
$ ./rkdeveloptool gpt ~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/rockdev/Image-rk3568_r/parameter.txt
Writing gpt succeeded.

// ppt 명령을 사용하여 gpt table 을 확인한다.
$ ./rkdeveloptool ppt
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

```

# Flash binary to device

```bash
// uboot partition영역에 uboot.img 을 flash한다.
$ ./rkdeveloptool wlx uboot ~/AOA_PC/ssd/Rockchip/ROCKCHIP_ANDROID11/u-boot/uboot.img
Write LBA from file (100%)

```
## Write GPT partition table through U-boot
## Write GPT partition table through U-boot's fastboot

# SPL

 SPL은 miniloader를 replace하여, trust.img 및 uboot.img의 loading 과 booting을 완료하는 것 입니다.  
 SPL은 현재 두 가지 type의 firmware booting을 지원합니다.  
 	-  FIT firmware : 기본적으로 활성화되어 있습니다.  
	-  RKFW firmware : 기본적으로 비활성화되어 있으며 사용자가 구성하고 활성화해야 합니다.  

### FIT firmware

 FIT(flattended image tree) format은 SPL에서 지원하는 firmware format으로 multiple image packaging 및 검증을 지원합니다.  
 FIT은 DTS syntax를 사용하여 packaged image를 기술하며, 기술 파일은 u-boot.its이며 이를 통해 생성된 FIT firmware 는 u-boot.itb 입니다.  
  
 FIT의 장점 : dts의 syntax 및 compile rule이 재사용되요 유연하고 firmware 구문 분석에서 Libfdt library를 직접 사용할 수 있습니다.  


 - u-boot.its file
	 * /images : dtsi의 rule과 유사하며, 사용 가능한 모든 resource configurations(last available, optional)을 정적으로 정의합니다.
	 * /configurations : 각 config node는 board-level 의 Dts 와 유사한 booting 가능한 configurations 을 기술합니다.
	 * use default = 현재 선택된 default configuration을 지정합니다.

 - u-boot.itb 
-----


# FIT 
FIT format 과 FIT format 기반의 security / non security 부팅 scheme 에 대해 설명합니다.

 u-boot 빌드 시, FIT는 Flattened Image Tree의 약어로, 여러 개의 이미지를 하나의 이미지로 결합한 이미지이다. 
 u-boot 는 일반적으로 커널, 펌웨어, 디바이스 트리 등을 포함하는 여러 개의 이미지로 구성된다. 
 FIT 이미지는 이러한 이미지를 하나로 결합하여 부팅 프로세스를 간소화 하고, 부팅 시간을 단축하는데 도움된다.

FIT(Flattened Image Tree)는 U-boot에서 지원하는 새로운 firmware type의 부팅 방식으로, 여러 이미지 패키징을 지원합니다.
FIT은 its(image source file)파일을 사용하여 image 정보를 기술하고, itb(flattened image tree blob)이미지를 mkimage tool을 통해 생성합니다.  
its파일은 DTS 문법을 따릅니다.

자세한 내용은 다음을 참조하십시오. (/doc/uImage.FIT/)

RK 플랫폼은 U-boot와 함께 컴파일된 mkimage tool을 사용해야합니다.(RK사에서 최적화함)

## sample
u-boot.its, u-boot.itb를 설명합니다.
```dts
/dts-v1/;

/ {
	description = "FIT Image with ATF/OP-TEE/U-Boot/MCU";
	#address-cells = <1>;

	images {

		uboot {
			description = "U-Boot";
			data = /incbin/("u-boot-nodtb.bin");
			type = "standalone";
			arch = "arm64";
			os = "U-Boot";
			compression = "none";
			load = <0x00a00000>;
			hash {
				algo = "sha256";
			};
		};
		atf-1 {
			description = "ARM Trusted Firmware";
			data = /incbin/("./bl31_0x00040000.bin");
			type = "firmware";
			arch = "arm64";
			os = "arm-trusted-firmware";
			compression = "none";
			load = <0x00040000>;
			hash {
				algo = "sha256";
			};
		};
		atf-2 {
			description = "ARM Trusted Firmware";
			data = /incbin/("./bl31_0x00068000.bin");
			type = "firmware";
			arch = "arm64";
			os = "arm-trusted-firmware";
			compression = "none";
			load = <0x00068000>;
			hash {
				algo = "sha256";
			};
		};
		atf-3 {
			description = "ARM Trusted Firmware";
			data = /incbin/("./bl31_0xfdcd0000.bin");
			type = "firmware";
			arch = "arm64";
			os = "arm-trusted-firmware";
			compression = "none";
			load = <0xfdcd0000>;
			hash {
				algo = "sha256";
			};
		};
		atf-4 {
			description = "ARM Trusted Firmware";
			data = /incbin/("./bl31_0xfdcc9000.bin");
			type = "firmware";
			arch = "arm64";
			os = "arm-trusted-firmware";
			compression = "none";
			load = <0xfdcc9000>;
			hash {
				algo = "sha256";
			};
		};
		atf-5 {
			description = "ARM Trusted Firmware";
			data = /incbin/("./bl31_0x00066000.bin");
			type = "firmware";
			arch = "arm64";
			os = "arm-trusted-firmware";
			compression = "none";
			load = <0x00066000>;
			hash {
				algo = "sha256";
			};
		};
		optee {
			description = "OP-TEE";
			data = /incbin/("tee.bin");
			type = "firmware";
			arch = "arm64";
			os = "op-tee";
			compression = "none";
			
			load = <0x8400000>;
			hash {
				algo = "sha256";
			};
		};
		fdt {
			description = "U-Boot dtb";
			data = /incbin/("./u-boot.dtb");
			type = "flat_dt";
			arch = "arm64";
			compression = "none";
			hash {
				algo = "sha256";
			};
		};
	};
//	configuration node는 여러개 정의가능하지만 타겟 제품의 configurations만 정의합니다.
	configurations {
		default = "conf";
		conf {
			description = "rk3568-evb";
			rollback-index = <0x0>;
			firmware = "atf-1";
			loadables = "uboot", "atf-2", "atf-3", "atf-4", "atf-5", "optee";
			
			fdt = "fdt";
			signature {
				algo = "sha256,rsa2048";
				
				key-name-hint = "dev";
				sign-images = "fdt", "firmware", "loadables";
			};
		};
	};
};
```
itb 파일은 mkimages tools과 its파일을 사용하여 생성할 수 있습니다.

```bash
                          mkimage + dtc
[u-boot.its] + [images] =================> [u-boot.itb]
```

fdtdump 명령은  itb 파일의 내용을 dump 할 수 있습니다.
```bash
/dts-v1/;
// magic:		0xd00dfeed
// totalsize:		0xc00 (3072)
// off_dt_struct:	0x48
// off_dt_strings:	0xa30
// off_mem_rsvmap:	0x28
// version:		17
// last_comp_version:	16
// boot_cpuid_phys:	0x0
// size_dt_strings:	0xc5
// size_dt_struct:	0x9e8

/memreserve/ 0x7f64f54bd000 0xc00;
/ {
    version = <0x00000000>;						// firmware version 
    totalsize = <0x001d6600>;					// total itb size 
    timestamp = <0x62babb79>;					// firmware 생성 time stamp
    description = "FIT Image with ATF/OP-TEE/U-Boot/MCU";
    #address-cells = <0x00000001>;
    images {
        uboot {
            data-size = <0x00131378>;			// firmware size 
            data-position = <0x00001000>;		// firmware offset
            description = "U-Boot";
            type = "standalone";
            arch = "arm64";
            os = "U-Boot";
            compression = "none";
            load = <0x00a00000>;
            hash {							// firmware checksum value
                value = <0xb754a07c 0x3ce1c0a4 0xfc00e114 0x8f17e58b 0xd8ed74d0 0x6f415de4 0xb5f09b95 0x814165f7>;
                algo = "sha256";
            };
        };
        atf-1 {
            data-size = <0x00026000>;
            data-position = <0x00132400>;
            description = "ARM Trusted Firmware";
            type = "firmware";
            arch = "arm64";
            os = "arm-trusted-firmware";
            compression = "none";
            load = <0x00040000>;
            hash {
                value = <0xfe4f274c 0x0624c2d7 0xe7b9aa0d 0x5b40a333 0x1801664b 0xf6253677 0x02d2116d 0xbe452466>;
                algo = "sha256";
            };
        };
        atf-2 {
            data-size = <0x00004c4b>;
            data-position = <0x00158400>;
            description = "ARM Trusted Firmware";
            type = "firmware";
            arch = "arm64";
            os = "arm-trusted-firmware";
            compression = "none";
            load = <0x00068000>;
            hash {
                value = <0x8d440360 0x954c39a1 0xd9a1eb60 0x4c0642e7 0x201f4a47 0x679272a9 0x885cfd46 0x205aa418>;
                algo = "sha256";
            };
        };
        atf-3 {
            data-size = <0x00002000>;
            data-position = <0x0015d200>;
            description = "ARM Trusted Firmware";
            type = "firmware";
            arch = "arm64";
            os = "arm-trusted-firmware";
            compression = "none";
            load = <0xfdcd0000>;
            hash {
                value = <0xe410275b 0x51692587 0xb5d09c79 0x4ae13f2d 0xcd4d187b 0xd6ab1eb2 0x998bf18d 0x44750876>;
                algo = "sha256";
            };
        };
        atf-4 {
            data-size = <0x00002000>;
            data-position = <0x0015f200>;
            description = "ARM Trusted Firmware";
            type = "firmware";
            arch = "arm64";
            os = "arm-trusted-firmware";
            compression = "none";
            load = <0xfdcc9000>;
            hash {
                value = <0x990c53fc 0x0167a7bc 0xd877235f 0x09a3ac69 0x11841c97 0x8a4e270d 0x89f6259e 0xc1d36144>;
                algo = "sha256";
            };
        };
        atf-5 {
            data-size = <0x00001df4>;
            data-position = <0x00161200>;
            description = "ARM Trusted Firmware";
            type = "firmware";
            arch = "arm64";
            os = "arm-trusted-firmware";
            compression = "none";
            load = <0x00066000>;
            hash {
                value = <0x315a4195 0xa9f6536f 0x971c695a 0x79fcab48 0x70363fc7 0xfc97f355 0xbd091d8d 0x7092261a>;
                algo = "sha256";
            };
        };
        optee {
            data-size = <0x0006f998>;
            data-position = <0x00163000>;
            description = "OP-TEE";
            type = "firmware";
            arch = "arm64";
            os = "op-tee";
            compression = "none";
            load = <0x08400000>;
            hash {
                value = <0x66bbd173 0x528d12e9 0x739c3369 0x26e33ee1 0xac1f4c70 0x78fcac57 0x12eeb874 0x7d02163e>;
                algo = "sha256";
            };
        };
        fdt {
            data-size = <0x000037d1>;
            data-position = <0x001d2a00>;
            description = "U-Boot dtb";
            type = "flat_dt";
            arch = "arm64";
            compression = "none";
            hash {
                value = <0xcdc53337 0x74568a0f 0x6036d65f 0x954be664 0xaa59bdb8 0x9ec52694 0xda58cf54 0x85483213>;
                algo = "sha256";
            };
        };
    };
    configurations {
        default = "conf";
        conf {
            description = "rk3568-evb";
            rollback-index = <0x00000000>;			// firmware anti-rollback version number, default is 0.
            firmware = "atf-1";
            loadables = "uboot", "atf-2", "atf-3", "atf-4", "atf-5", "optee";
            fdt = "fdt";
            signature {
                algo = "sha256,rsa2048";
                key-name-hint = "dev";
                sign-images = "fdt", "firmware", "loadables";
            };
        };
    };
}
```

itb structure

itb는 fdt_blob + image 파일 로 구성되어 잇습니다. 다음과 같은 패키징 방법이 있습니다.  
RK 플랫폼은 structure 2방법을 채택합니다.

```bash
             fdt blob
+----------------------------------------+
|    +------+    +------+    +------+    |
|    | img0 |    | img1 |    | img2 |    |
|    +------+    +------+    +------+    |
+----------------------------------------+

struct 1 : image is in fdt_blob, 
ie : itb = fdt_blob (including img)

```

```bash
+-------------+--------+--------+--------+
|             |        |        |        |
|  fdt blob   |  img0  |  img1  |  img2  |
|             |        |        |        |
+-------------+--------+--------+--------+

struct 2 : image is outside fdt_blob,
ie : itb = fdt_blob + img
```

## platform configuraiton
code configuration
code : 
```bash
// frame code
./common/image.c
./common/image-fit.c
./common/spl/spl_fit.c

// platform code
./arch/arm/mack-rockchip/fit.c
./cmd/bootfit.c

// tool code
./tools/mkimage.c
./tools/fit_image.c
```

configuration:
```bash
// u-boot stage supports FIT
CONFIG_ROCKCHIP_FIT_IMAGE=y

// u-boot stage : secure boot, anti-rollback, hardware crypto
# CONFIG_FIT_SIGNATURE is not set
CONFIG_FIT_HW_CRYPTO=y

// uboot.img image contains several copies of uboot.lib, how big is a single copy of uboot.itb
CONFIG_SPL_FIT_IMAGE_KB=2048
CONFIG_SPL_FIT_IMAGE_MULTIPLE=2

// After the uboot project is compiled, it will output uboot.img in fit format by default; otherwise, it will be uboot.img and trust.img in traditional RK format.
CONFIG_ROCKCHIP_FIT_IMAGE_PACK=y
```


## image file
 - uboot.img document
 	uboot.itb = trust + u-boot.bin + mcu.bin(option)
	uboot.img = uboot.itb * N copies (N is generally 2)
	> trust와 mcu files은 rkbin project로 부터 제공 받습니다. 

 - boot.img document
    boot.itb = kernel + fdt + resource + ramdisk(optional)
	boot.img = boot.itb * M copies ( M is generall 1)

 - SPL document
 	SPL 파일은 spl/u-boot-spl.bin 경로에 컴파일 후 생성됩니다. 
	uboot.img 를 FIT format 으로 부팅하는 역할을 합니다.

## tools
```bash
./tools/mkimage		// the core packaging tool
./make.sh			// firmware packaging script
./scripts/fit-resign.sh	// firmware resginature script
./scripts/fit-unpack.sh	// firmware unpacking script
./scripts/fit-repack.sh	// firmware replacement script 
```
 tools 사용 방법에 대해 설명합니다.
 - --spl-new : --spl-new 를 옵션으로 사용하면 현재 컴파일된 spl 파일이 loader를 패키징하는데 사용됩니다. (그렇지 않으면 rkbin 의 spl 파일이 사용됩니다.)
 - --version-uboot [n] : uboot.img 의 firmware 버전 번호를 지정합니다.  n은 양수
 - --version-boot [n] : boot.img 의 firmware 버전 번호를 지정합니다. n은 양수 
 - --version-recovery [n] : recovery.img 의 firmware 버전 번호를 지정합니다. n은 양수

 security booting이 활성화 된 경우,
 - --rollback-index-uboot [n] : 
 - --rollback-index-boot [n] : 
 - --rollback-index-recovery [n] : 
 - --no-check : 




<hr/>
<br/>
<br/>
<br/>
<hr/>

# build u-boot

## coufigure u-boot 
configure :
```bash
make CROSS_COMPILE=arm-linux-android- rk3568_defconfig
```

menuconfig  :
```bash
make CROSS_COMPILE=arm-linux-gnueabi- menuconfig
```

## build rockchip u-boot
rockchip은 make.sh 스크립트를 제공합니다.  make.sh스크립트는 toolchain과 rkbin이 요구됩니다.
```bash
//u-boot/make.sh
13 ########################################### User can modify #############################################
14 RKBIN_TOOLS=../rkbin/tools
15 CROSS_COMPILE_ARM32=../prebuilts/gcc/linux-x86/arm/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
16 CROSS_COMPILE_ARM64=../prebuilts/gcc/linux-x86/aarch64/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
```

```bash
├── prebuilts
│   └── gcc
│       └── linux-x86 
│           ├── aarch64
│           └── arm
├── rkbin
├── u-boot
```

build image 
```bash
./make.sh rk3568
```


output : pre-loader, trust, u-boot image 가 생성되며 해당 파일은 rockchip upgrade tool을 통해 사용합니다.
```bash
u-boot/
├── rk356x_spl_loader_v1.10.111.bin
└── uboot.img


```

<hr/>
<br/>
<br/>
<br/>
<hr/>



# 👨‍💻 develop bootloader
> bootloader 개발 이력을 정리합니다. 

## config
- rk3568_poc_defconfig


## platform architecture file 
1. Platform Directory :
```bash
./arch/arm/include/asm/arch-rockchip/
./arch/arm/mach-rockchip/
./board/rockchip/
```
2. Platform header files:
```bash
./arch/arm/include/asm/arch-rockchip/sdram_rk3568.h
./arch/arm/include/asm/arch-rockchip/grf_rk3568.h
./arch/arm/include/asm/arch-rockchip/cru_rk3568.h
```
```bash
./include/configs/poc_rk3568.h
./include/configs/rk3568_common.h
./include/configs/evb_rk3568.h
```
3. Platform driver file:
```bash
./arch/arm/mach-rockchip/rk3568/rk3568.c
./board/rockchip/poc_rk3568/poc_rk3568.c
```
4. Common board files (core!):
```bash
./arch/arm/mach-rockchip/board.c
```
5. README : 
```bash
./board/rockchip/sheep_rk3368/README
```
6. defconfig : 
```bash
./configs/rk3568_poc_defconfig
```


<hr/>
<br/>
<br/>
<br/>
<hr/>

## Rockchip loader binaries naming rule

 - naming rule : 아래 네이밍 규칙을 사용합니다.
 [chip]_[module]_[feature]_[version].[postfix]
   * chip : chip 또는 chip 시리즈 이름 사용, 필수, 소문자, uboot,kernel에서 사용
   * module : 모듈 이름,(예, loader, ddr, miniloader, usbplug, bl3x, tee, tee_ta), 소문자
   * version : 버전 정보, 형식은 [v1.00], 정식 출시 이전에는 [v0.xx], 소문자
   * postfix : 접미사를 나타냄. 컴파일된 코드의 기본값은 .bin, .elf일 수도 있음. 병합후에는 소문자 .img를 사용
 연결 기호는 "_"를 사용

  - special rule : 
   1. merged loader naming : 
     * loader : ddrbin, usbplug, miniloader에서 merge되고 upgrade_tool에서 사용하는 loader
	 * ubootloader : ddrbin, usbplug, u-boot에서 merge되고 upgrade_tool에서 사용하는 loader
	 * idbloader : IDB 포멧에 따라 ddrbin과 miniloader 또는 uboot와 merge되어 IDB 영역에 binary를 programming하는데 사용
   2. version definition of the merged loader : 

## ddrbin_tool 사용 가이드

```
./ddrbin_tool ddrbin_param.txt ../../u-boot/rk356x_spl_loader_v1.13.112.bin
```


<hr/>
<br/>
<br/>
<br/>
<hr/>


