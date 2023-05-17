# uboot make.sh 

- sequence :   
```bash
/** sub script */
SRCTREE=`pwd`
SCRIPT_FIT="${SRCTREE}/scripts/fit.sh"
SCRIPT_ATF="${SRCTREE}/scripts/atf.sh"
SCRIPT_TOS="${SRCTREE}/scripts/tos.sh"
SCRIPT_SPL="${SRCTREE}/scripts/spl.sh"
SCRIPT_UBOOT="${SRCTREE}/scripts/uboot.sh"
SCRIPT_LOADER="${SRCTREE}/scripts/loader.sh"
SCRIPT_DECOMP="${SRCTREE}/scripts/decomp.sh"
CC_FILE=".cc"
REP_DIR="./rep"
```
  01. **process_args**  
```bash
// make defconfig
```
  02. **prepare**  
```bash
RKBIN=rkbin

PLAT_TYPE="FIT'	// if CONFIG_ROCKCHIP_FIT_IMAGE=y from .config
```
  03. **select_toolchain**  
```bash
TOOLCHAIN=
TOOLCHAIN_NM=
TOOLCHAIN_OBJDUMP=
TOOLCHAIN_ADDR2LINE=
```
  04. **select_chip_info**  
```bash
RKCHIP=			RK3568
RKCHIP_LABEL=	RK3568	
RKCHIP_LOADER=	RK3568
RKCHIP_TRUST=	RK3568
INI_TRUST=		rkbin/RKTRUST/RK3568TRUST.ini
INI_LOADER=		rkbin/RKBOOT/RK3568MINIALL.ini
```
  05. **fixup_platform_configure**  
```bash
PLAT_RSA=
PLAT_SHA=
PLAT_UBOOT_SIZE=
PLAT_TRUST_SIZE=
PLAT_TYPE="RKFW" # default
```
  06. **select_ini_file**  
```bash
// to do: target board 별 ini_file 지정해야함.
// configs/rk3568_poc_defconfig에서 CONFIG_LOADER_INI 에 NAME 지정하도록 추가.
INI_LOADER=
```
 
  07. **handle,args_late**  
  08. **sub_commands**  
  09. **clean files**  
  10. **make PYTHON=python2 CROSS_COMPILE=${toolchain} all --jobs=${JOB}**  
  11. **pack_images**  
```bash
pack_fit_image --ini-trust rkbin/RKTRUST/RK3568TRUST.ini --ini-loader rkbin/RKBOOT?RK3568MINIALL.ini 
	${SCRIPT_FIT} ${ARG_LIST_FIT} --chip RK3568
		scripts/fit.sh
			scripts/fit-core.sh
				function fit_gen_uboot_itb()
					./make.sh itb 	 rkbin/RKTRUST/RK3568TRUST.ini
					./make.sh loader rkbin/RKBOOT/RK3568MINIALL.ini

					loader rkbin/RKBOOT/RK3568MINIALL.ini
					DEF_PATH:rkbin/rk356x_spl_loader_v1.13.112.bin
					IDB_PATH:rkbin/
```
  12. **finish**  
  13. **echo ${TOOLCHAIN}**  
  14. **date**  
 
-----

# tools

## boot_merger
 > ini 설정 파일에 따라서 miniloader + ddr + usb plug를 merger하여 loader firmware을 생성.

 - ini file(RK3568MINIALL.ini)
```bash
[CHIP_NAME]
NAME=RK3568		// chip name
[VERSION]
MAJOR=1		
MINOR=1
[CODE471_OPTION]		// code471, Path1경로의 파일을 ddr bin으로 설정
NUM=1
Path1=bin/rk35/rk3568_ddr_1560MHz_v1.13.bin
Sleep=1
[CODE472_OPTION]		// code472, Path1경로의 파일을 usbplug bin으로 설정
NUM=1
Path1=bin/rk35/rk356x_usbplug_v1.14.bin
[LOADER_OPTION]			// FlashData; 현재 ddr bin 으로 설정 , FlashBoot; miniLoader bin 으로 설정
NUM=2
LOADER1=FlashData
LOADER2=FlashBoot
FlashData=bin/rk35/rk3568_ddr_1560MHz_v1.13.bin
FlashBoot=bin/rk35/rk356x_spl_v1.12.bin
[OUTPUT]		// 출력되는 파일 이름
PATH=rk356x_spl_loader_v1.13.112.bin
[SYSTEM]
NEWIDB=true
[FLAG]
471_RC4_OFF=true
RC4_OFF=true
```
