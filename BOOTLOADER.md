# BOOTLOADER 
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
