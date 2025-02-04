#!/bin/bash

# 초기 index 값 설정
index=1
# 반복 횟수, 성공 횟수, 실패 횟수 초기화
total_runs=0
success_count=0
failure_count=0

while true; do
    # 장치 재부팅 및 초기화 대기
    adb reboot
    adb wait-for-device

    # mmc0 인터페이스 초기화 로그 확인
    mmc0_log=$(adb shell dmesg | grep mmc0)

    # wlan0 인터페이스 확인
    wlan0_status=$(adb shell ifconfig wlan0)

    # 반복 횟수 증가
    ((total_runs++))

    # wlan0 인터페이스가 초기화되지 않은 경우 로그 저장
    if [[ -z "$wlan0_status" ]]; then
        current_date_time=$(date +"%Y%m%d_%H%M%S")
        log_file=~/HNDEV_PC/develop/Rockchip/ROCKCHIP_ANDROID12_DEV/private/dev_mmc_${index}_${current_date_time}.log
        echo "$mmc0_log" > "$log_file"
        echo "mmc0 인터페이스 초기화 실패. 로그가 $log_file 파일에 저장되었습니다."
        ((index++))
        ((failure_count++))
        
        # 대기 상태로 전환
        echo "실패 상태로 대기 중입니다. 재부팅하지 않습니다."
        break
    else
        echo "wlan0 인터페이스가 성공적으로 초기화되었습니다."
        ((success_count++))
    fi
    # 현재 상태 출력
    echo "전체 반복 횟수: $total_runs"
    echo "성공 횟수: $success_count"
    echo "실패 횟수: $failure_count"

    # 1초 대기 후 반복
    sleep 1
done