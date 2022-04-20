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

<hr/>

