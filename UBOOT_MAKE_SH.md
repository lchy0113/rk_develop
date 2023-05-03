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
RKBIN=
PLAY_TYPE="FIT'	// if CONFIG_ROCKCHIP_FIT_IMAGE=y from .config
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
```
  12. **finish**  
  13. **echo ${TOOLCHAIN}**  
  14. **date**  
 
