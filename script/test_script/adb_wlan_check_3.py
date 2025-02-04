import subprocess
import time
from datetime import datetime
import random

token = "902e5885-6258-495e-af89-2f53c7c0f4cb"
deviceid = "cb8ebc4d-d527-436b-844b-5a4c030fe68c"

# 초기 index 값 설정
index = 1
# 반복 횟수, 성공 횟수, 실패 횟수 초기화
total_runs = 0
success_count = 0
failure_count = 0
adb_reboot_count = 0
plug_reboot_count = 0

def adb_reboot():
    subprocess.run(["adb", "reboot"])
    subprocess.run(["adb", "wait-for-device"])

def plug_reboot():
    command_off = f"./smartthings devices:commands {deviceid} switch:off --token={token}"
    command_on = f"./smartthings devices:commands {deviceid} switch:on --token={token}"
    subprocess.run(command_off, shell=True)
    time.sleep(5)  # 디바이스가 꺼지는 시간을 기다림
    subprocess.run(command_on, shell=True)
    time.sleep(30)  # 디바이스가 켜지는 시간을 기다림

while True:
    print(f"------------------------------")
    # 랜덤으로 재부팅 방법 선택
    reboot_method = random.choice(["adb", "plug"])
    if reboot_method == "adb":
        print("Using adb to reboot the device.")
        adb_reboot()
        adb_reboot_count += 1
    else:
        print("Using plug to reboot the device.")
        plug_reboot()
        plug_reboot_count += 1


    subprocess.run(["adb", "wait-for-device"])
    
    # mmc0 인터페이스 초기화 로그 확인
    mmc0_log = subprocess.run(["adb", "shell", "dmesg | grep mmc0"], capture_output=True, text=True).stdout

    # wlan0 인터페이스 확인
    wlan0_status = subprocess.run(["adb", "shell", "ifconfig wlan0"], capture_output=True, text=True).stdout

    # 반복 횟수 증가
    total_runs += 1

    # wlan0 인터페이스가 초기화되지 않은 경우 로그 저장
    if not wlan0_status:
        current_date_time = datetime.now().strftime("%Y%m%d_%H%M%S")
        log_file = f"/home/lchy0113/Develop/Rockchip/rk_develop/script/test_script/dev_mmc_{index}_{current_date_time}.log"
        with open(log_file, "w") as file:
            file.write(mmc0_log)
        print(f"mmc0 인터페이스 초기화 실패. 로그가 {log_file} 파일에 저장되었습니다.")
        index += 1
        failure_count += 1
        
        # 대기 상태로 전환
        print("실패 상태로 대기 중입니다. 재부팅하지 않습니다.")
        break
    else:
        print("wlan0 인터페이스가 성공적으로 초기화되었습니다.")
        success_count += 1

    # 현재 상태 출력
    print(f"전체 반복 횟수: {total_runs}")
    print(f"성공 횟수: {success_count}")
    print(f"실패 횟수: {failure_count}")
    print(f"마지막 재부팅 방법: {reboot_method}")
    print(f"ADB 재부팅 횟수: {adb_reboot_count}")
    print(f"PLUG CLI 재부팅 횟수: {plug_reboot_count}")

    # 1초 대기 후 반복
    time.sleep(1)