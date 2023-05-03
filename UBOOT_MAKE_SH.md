# uboot make.sh 

sequence :   
	process_args  
	prepare  
	select_toolchain  
	select_chip_info  
	fixup_platform_configure  
	select_ini_file  
	handle,args_late  
	sub_commands  
	clearn files  
	make PYTHON=python2 CROSS_COMPILE=${toolchain} all --jobs=${JOB}  
	pack_images  
	finish  
	echo "${TOOLCHAIN}  
	date  
  
## process_args
 make defconfig

## prepare


