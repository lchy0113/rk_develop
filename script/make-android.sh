#!/bin/bash

if [ -z "${ANDROID_BUILD_PATHS}" ]
then
	echo "Check environment variables..."
	source build/envsetup.sh
	lunch rk3568_r-userdebug
#else
#	KD_DEVICE=`sed -e 's/full_//g' <<< ${TARGET_PRODUCT}`
#	figlet -ct "${KD_DEVICE}: Build kernel."
fi

real_core=`cat /proc/cpuinfo | grep cores | wc -l`
let best_num=$real_core+$(printf %.0f `echo "$real_core*0.2"|bc`)

DEFCONFIG="rk3568"


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


make -j${best_num}

#
# one key compiling
#
# ./build.sh -AUCKu
#
#	./build.sh -UKAup
#	( WHERE: -U = build uboot
#		-C = build kernel with Clang
#		-K = build kernel
#		-A = build android
#		-p = will build packaging in IMAGE
#		-o = build OTA package
#		-u = build update.img
#		-v = build android with 'user' or 'userdebug'
#		-d = huild kernel dts name
#		-V = build version
#		-J = build jobs
#	------------you can use according to the requirement, no need to record uboot/kernel compiling commands------------------
#	)
#	============================================================
#	Please remember to set the environment variable before using the one key
#	compiling command, and select the platform to be compiled, for example:
#	source build/envsetup.sh
#	lunch rk3566_rgo-userdebug
#	============================================================
#	
#

