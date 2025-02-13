from colorama import init, Fore
from datetime import datetime
import serial
import time
import random
import subprocess
import os

# test trigger 
log_test_static_string = "10.1.0.0/16 dev eth0 proto kernel scope link src 10.1.7.1"
log_test_hnnova_static_string = "192.168.0.0/24 dev eth0 proto kernel scope link src 192.168.0.200"
log_test_hnnova_dhcp_string = "192.168.0.0/24 dev eth0 proto kernel scope link src 192.168.0.111"
log_bootvcc3v3_string = "vcc3v3_pcie: disabling"

log_boot_complete = "init: processing action (sys.boot_completed=1 && sys.logbootcomplete=1) from (/system/etc/init/bootstat.rc:66)"
log_ota_prepare_complete = "rebooted a few minutes"

# set serial port 
ser = serial.Serial(port='/dev/ttyUSB1', baudrate=115200, timeout=1, xonxoff=False, rtscts=False, dsrdtr=False)
ser.flushInput()
ser.flushOutput()

count = 0
count_succ = 0
count_fail = 0
filename = "serial_test.log"

# for smartthings
# ref : https://developer.smartthings.com/docs/sdks/cli/introduction
# if need debug
#     SMARTTHINGS_DEBUG=true smartthings <command>
token=""
deviceid="55884626-685e-4090-a05c-8fc223611992"
token_new=""
deviceid_new="cb8ebc4d-d527-436b-844b-5a4c030fe68c"


# function
def ota_update_cmd():
	print(Fore.RED + f"(ota_update_cmd begin)" + Fore.RESET)
	ser.write(b'dumpsys wall_service cmd update_system_image /storage/emulated/0/update.zip;\r\n')
	print(Fore.RED + f"(ota_update_cmd end)" + Fore.RESET)

def random_task(delay):
	print(Fore.GREEN + f"random delay task() : {delay}" + Fore.GREEN)

def reboot():
	ser.write(b'reboot\r\n')
	print(Fore.RED + f"(reboot)" + Fore.RESET)

def poweroff():
	command = f"./smartthings devices:commands {deviceid} switch:off --token={token}"
	result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
	print(result.stdout)
	print(Fore.RED + f"(power off)" + Fore.RESET)

def poweron():
	command = f"./smartthings devices:commands {deviceid} switch:on --token={token}"
	result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
	print(result.stdout)
	print(Fore.RED + f"(power on)" + Fore.RESET)


init(autoreset=True) 

print("begin serial interface. if input 'exit' to exit")

while True:
	received_data = ser.readline().decode().strip() #read serial data
	if received_data:
		print(received_data)

	date = datetime.now()

	if log_boot_complete in received_data:
		count_succ += 1
		print(Fore.BLUE + f"-----------------------------------------" + Fore.RESET)
		print(Fore.BLUE + f"[BOOT_COMPLETED] [{date}] [{count_succ}] " + Fore.RESET)
		print(Fore.BLUE + f"-----------------------------------------" + Fore.RESET)
		#time.sleep(10)

		ser.write(b'kdu\n')
		time.sleep(1)
		ser.write(b'123\n')
		ser.write(b'whoami\n')
		time.sleep(1)
		ota_update_cmd()

	if log_ota_prepare_complete in received_data:
		print(Fore.BLUE + f"-----------------------------------------" + Fore.RESET)
		print(Fore.BLUE + f"[Preparing OTA update] [{date}]          " + Fore.RESET)
		print(Fore.BLUE + f"-----------------------------------------" + Fore.RESET)




#    user_input = input(">> ")  # 사용자 입력 받기
#
#    if user_input.lower() == 'exit':
#        ser.close()
#        break
#    else:
#        # 입력한 문자열을 시리얼 장치로 전송 (CR/LF 추가)
#        ser.write(user_input.encode() + b'\r\n')
#
#        # 장치의 응답을 기다리기 위해 1초 대기
#        time.sleep(1)
#
#        # 시리얼 버퍼에서 데이터 읽기
#		#response = ser.read_all().decode()
#        response = ser.read_until().decode()
#
#        if response:
#            print(f"응답: {response.strip()}")
#
