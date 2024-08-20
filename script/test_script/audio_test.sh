#!/bin/bash

progress_bar()
{
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

values=("default" "door_call" "door_ring" "door_subp_call" "pstn_call" "pstn_dial" "pstn_subp_call" "voip_door_call" "voip_gurd_call" "voip_gurd_subp_call" "voip_home_call" "voip_home_subp_call" "voip_loby_call" "voip_loby_subp_call")
maxwait=30

while [ true ]
do 
	random_index=$(($RANDOM % ${#values[@]}))

	echo "Create patch value: ${values[$random_index]}"
	adb shell "cmd wall_service set_audio_route ${values[$random_index]}"
	
	delay=$((RANDOM%$maxwait))
	progress_bar $delay


done
