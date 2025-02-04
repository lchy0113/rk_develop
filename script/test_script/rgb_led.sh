#!/bin/bash

RGB_ON=0x4c
W_ON=0x0f
R_ON=0x03
G_ON=0x05
B_ON=0x09
RGB_OFF=0x00

R_BRI=0x9a
G_BRI=0x9c
B_BRI=0x9e

# intensity
LED_01=0x01
LED_10=0x1a #  26
LED_20=0x33 #  51
LED_30=0x4d #  77
LED_40=0x66 # 102
LED_50=0x7f # 127
LED_60=0x99 # 153
LED_70=0xb2 # 178
LED_80=0xcc # 204
LED_90=0xe5 # 229

function process_hex_data() {
	local input_data="$1"
	hex_values=($(echo $input_data | tr ', ' '\n'))
#	echo "parsed hex value:"
#	for hex in "${hex_values[@]}"; do
#		echo "$hex"
#	done
	echo "First hex value: ${hex_values[0]}"
	echo "Second hex value: ${hex_values[1]}"
	adb shell "i2cset -f -y 5 0x08 ${hex_values[0]} ${hex_values[1]} b"
}


vars=(
	"$RGB_ON, $RGB_OFF"
	"$R_BRI, $LED_01"
	"$RGB_ON, $R_ON"
	"$R_BRI, $LED_10"
	"$R_BRI, $LED_20"
	"$R_BRI, $LED_30"
	"$R_BRI, $LED_40"
	"$R_BRI, $LED_50"
	"$R_BRI, $LED_60"
	"$R_BRI, $LED_70"
	"$R_BRI, $LED_80"
	"$R_BRI, $LED_90"
	"$R_BRI, $LED_80"
	"$R_BRI, $LED_70"
	"$R_BRI, $LED_60"
	"$R_BRI, $LED_50"
	"$R_BRI, $LED_40"
	"$R_BRI, $LED_30"
	"$R_BRI, $LED_20"
	"$R_BRI, $LED_10"
	"$R_BRI, $LED01"
	"$RGB_ON, $RGB_OFF"
	"$G_BRI, $LED_01"
	"$RGB_ON, $G_ON"
	"$G_BRI, $LED_10"
	"$G_BRI, $LED_20"
	"$G_BRI, $LED_30"
	"$G_BRI, $LED_40"
	"$G_BRI, $LED_50"
	"$G_BRI, $LED_60"
	"$G_BRI, $LED_70"
	"$G_BRI, $LED_80"
	"$G_BRI, $LED_90"
	"$G_BRI, $LED_80"
	"$G_BRI, $LED_70"
	"$G_BRI, $LED_60"
	"$G_BRI, $LED_50"
	"$G_BRI, $LED_40"
	"$G_BRI, $LED_30"
	"$G_BRI, $LED_20"
	"$G_BRI, $LED_10"
	"$G_BRI, $LED_01"
	"$RGB_ON, $RGB_OFF"
	"$B_BRI, $LED_01"
	"$RGB_ON, $B_ON"
	"$B_BRI, $LED_10"
	"$B_BRI, $LED_20"
	"$B_BRI, $LED_30"
	"$B_BRI, $LED_40"
	"$B_BRI, $LED_50"
	"$B_BRI, $LED_60"
	"$B_BRI, $LED_70"
	"$B_BRI, $LED_80"
	"$B_BRI, $LED_90"
	"$B_BRI, $LED_80"
	"$B_BRI, $LED_70"
	"$B_BRI, $LED_60"
	"$B_BRI, $LED_50"
	"$B_BRI, $LED_40"
	"$B_BRI, $LED_30"
	"$B_BRI, $LED_20"
	"$B_BRI, $LED_10"
	"$B_BRI, $LED_01"
	"$RGB_ON, $RGB_OFF"

	)

for var in "${vars[@]}"; do 
	process_hex_data "$var"
	sleep 0.001 #1ms
done
