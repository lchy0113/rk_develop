# uboot make.sh 

- sequence :   
```bash
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
  01. process_args  
  02. prepare  
```bash
RKBIN=
```
  03. select_toolchain  
```bash
TOOLCHAIN=
TOOLCHAIN_NM=
TOOLCHAIN_OBJDUMP=
TOOLCHAIN_ADDR2LINE=
```
  04. select_chip_info  
```bash
RKCHIP=
RKCHIP_LABEL=
RKCHIP_LOADER=
RKCHIP_TRUST=
INI_TRUST=
INI_LOADER=
```
  05. fixup_platform_configure  
```bash
PLAT_RSA=
PLAT_SHA=
PLAT_UBOOT_SIZE=
PLAT_TRUST_SIZE=
PLAT_TYPE="RKFW" # default
```
  06. select_ini_file  
  07. handle,args_late  
  08. sub_commands  
  09. clearn files  
  10. make PYTHON=python2 CROSS_COMPILE=${toolchain} all --jobs=${JOB}  
  11. pack_images  
```bash
pack_uboot_image()
pack_trust_image()
pack_loader_image()
```
  12. finish  
  13. echo "${TOOLCHAIN}  
  14. date  
  
## process_args
 make defconfig

## prepare


