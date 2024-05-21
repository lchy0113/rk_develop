#!/bin/bash

token="61ed264a-248f-4685-86a4-a155d3b469df"
deviceid="a33c21d8-bd0f-4004-8353-14660902510c"
cmd_switchoff="switch:off"
cmd_switchon="switch:off"

# ./smartthings devices:commands --token=61ed264a-248f-4685-86a4-a155d3b469df
# ─────────────────────────────────────────────────────────────────────────────────────────────
#  #  Label                Name                     Type  Device Id
# ─────────────────────────────────────────────────────────────────────────────────────────────
# 1  SmartThings Station  Wireless-Charging-Hub    MQTT  dda6a1a3-6670-4035-a551-289d581ab781
# 2  SmartThings Station  SmartThings Station      HUB   41a24a49-2f0d-40e0-a07e-75c6faa4507b
# 3  Wi-Fi Smart Plug 1   Samjin Wi-Fi Smart Plug  MQTT  a33c21d8-bd0f-4004-8353-14660902510c
# ─────────────────────────────────────────────────────────────────────────────────────────────
# ? Select a device.

# ./smartthings devices:commands $deviceid switch:off --token=61ed264a-248f-4685-86a4-a155d3b469df
# ./smartthings devices:commands $deviceid switch:on --token=61ed264a-248f-4685-86a4-a155d3b469df

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


adb_device="F10024032709592502BE"

fail_log="cx2070x_download_firmware():.download.firmware.failed,.Error"
succ_log="cx2070x_download_firmware():.download.firmware.successfully"
test_log="cx2070x_download_firmware():"

test_cont=1
test_cnt=0
test_file=test_$(date '+%Y-%m-%d').log 

while [ true ]
do
	echo "prepare for test"
	token="61ed264a-248f-4685-86a4-a155d3b469df"
	deviceid="a33c21d8-bd0f-4004-8353-14660902510c"

	maxwait=20
	delay=$((RANDOM%$maxwait))
	progress_bar $delay

	echo "power off"
	./smartthings devices:commands $deviceid switch:off --token=$token
	maxwait=10
	delay=$((RANDOM%$maxwait))
	progress_bar $delay
	echo "power on"
	./smartthings devices:commands $deviceid switch:on --token=$token

	echo "wait-for-device"
	adb -s $adb_device wait-for-device

	if [ $(adb -s $adb_device shell dmesg | grep -c $succ_log) -ge 1 ]
	then
		echo "[`date`] [$test_cnt] [$delay] success"
		echo "[`date`] [$test_cnt] [$delay] success -> `adb -s $adb_device shell dmesg | grep $test_log `" >> $test_file
	elif [ $(adb -s $adb_device shell dmesg | grep -c $fail_log) -ge 1 ]
	then
		echo "[`date`] [$test_cnt] [$delay] fail" >> $test_file
		echo "[`date`] [$test_cnt] [$delay] fail -> `adb -s $adb_device shell dmesg | grep $test_log `" >> $test_file
		adb -s $adb_device root ; adb -s $adb_device remount ; adb -s $adb_device shell system_dump.sh
		adb -s $adb_device pull /storage/emulated/0/temp/
	fi
	test_cnt=$((test_cnt+1))
done


echo "[`date`] test finish test_cnt($test_cnt)"
