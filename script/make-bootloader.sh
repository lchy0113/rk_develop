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

./make.sh $DEFCONFIG
