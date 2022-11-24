#!/bin/bash
#su
count=0
#device=$(adb devices | awk 'NR == 2 {print $1}')
cpu_temp="/sys/devices/virtual/thermal/thermal_zone0/temp"
gpu_temp="/sys/devices/virtual/thermal/thermal_zone1/temp"
cpu_temp_val=0
gpu_temp_val=0
delay=1

function progress_bar() {
	local PROG_BAR_MAX=${1:-30}
	local PROG_BAR_DELAY=${2:-1}
	local PROG_BAR_TODO=${3:-"."}
	local PROG_BAR_DONE=${4:-"|"}
	local i

	echo -en "["
	for i in `seq 1 $PROG_BAR_MAX`
	do
		echo -en "$PROG_BAR_TODO"
	done
	echo -en "]\0015["
	for i in `seq 1 $PROG_BAR_MAX`
	do
		echo -en "$PROG_BAR_DONE"
		sleep ${PROG_BAR_DELAY}
	done
	echo
}


function count_fn(){
	((count++))
}


function event_fn(){
	cpu_temp_val=`adb shell "cat /sys/devices/virtual/thermal/thermal_zone0/temp"`
	gpu_temp_val=`adb shell "cat /sys/devices/virtual/thermal/thermal_zone1/temp"`
	echo "🟡 [$count]__[$(date +"%m-%d %T")]_cpu_temp_val: $cpu_temp_val), gpu_temp_val: $gpu_temp_val"
	echo "🟡 [$count]__[$(date +"%m-%d %T")]_cpu_temp_val: $cpu_temp_val), gpu_temp_val: $gpu_temp_val" >> get_temperature_endecod.log
}

while [ true ];
do
	progress_bar $delay
	event_fn
	count_fn
done

