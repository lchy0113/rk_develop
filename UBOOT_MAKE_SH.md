# uboot make.sh 

- sequence :   
  01. process_args  
  02. prepare  
  03. select_toolchain  
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
  06. select_ini_file  
  07. handle,args_late  
  08. sub_commands  
  09. clearn files  
  10. make PYTHON=python2 CROSS_COMPILE=${toolchain} all --jobs=${JOB}  
  11. pack_images  
  12. finish  
  13. echo "${TOOLCHAIN}  
  14. date  
  
## process_args
 make defconfig

## prepare


