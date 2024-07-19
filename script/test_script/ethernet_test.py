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
token="61ed264a-248f-4685-86a4-a155d3b469df"
deviceid="55884626-685e-4090-a05c-8fc223611992"


# function
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
	date = datetime.now()
	received_data = ser.readline().decode().strip() #read serial data
	if received_data:
		print(f"[{date}][{count_succ}] " + received_data)

	if log_bootvcc3v3_string in received_data:
		count_succ += 1
		print(Fore.BLUE + f"-----------------------------------------" + Fore.RESET)
		print(Fore.BLUE + f"[BOOT_COMPLETED] [{date}] [{count_succ}] " + Fore.RESET)
		print(Fore.BLUE + f"-----------------------------------------" + Fore.RESET)
		time.sleep(10)
		ser.write(b'ip route\r\n')

	if log_test_static_string in received_data:
		print(Fore.GREEN + f"------------------------------------------" + Fore.RESET)
		print(Fore.GREEN + f"[NORMAL CASE] [{date}] '{log_test_static_string}'" + Fore.RESET)
		print(Fore.GREEN + f"------------------------------------------" + Fore.RESET)
		time.sleep(3)
#		poweroff()
#		time.sleep(10)
#		poweron()
		reboot()
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
