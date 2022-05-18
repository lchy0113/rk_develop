#!/bin/bash

if [ -z "${ANDROID_BUILD_PATHS}" ]
then
	echo "Check environment variables..."
	exit 1
#else
#	KD_DEVICE=`sed -e 's/full_//g' <<< ${TARGET_PRODUCT}`
#	figlet -ct "${KD_DEVICE}: Build kernel."
fi

real_core=`cat /proc/cpuinfo | grep cores | wc -l`
let best_num=$real_core+$(printf %.0f `echo "$real_core*0.2"|bc`)

BUILD_PATH=${OUT}/obj/KERNEL_OBJ
DEFCONFIG="rockchip_defconfig rk356x_evb.config android-11.config"


if [ "$1" = "clean" ]; then
	echo "-------------"
	echo "|clean code |"
	echo "-------------"
	#make O=${BUILD_PATH} distclean
	make distclean
	if [ -f .config ]; then
		rm .config
	fi

fi

if [ ! -f .config ]; then
	#make arm=ARM O=${BUILD_PATH} ${DEFCONFIG} -j${best_num}
	make ARCH=arm64 ${DEFCONFIG} -j${best_num}
fi

if [ "$1" = menuconfig ]; then
	make ARCH=arm64 $1
	exit
fi

if [ "$1" = "dtb" ]; then
	make   dtbs -j${best_num} 
fi



make ARCH=arm64 rk3568-evb7-ddr4-v10.img -j${best_num} $1
