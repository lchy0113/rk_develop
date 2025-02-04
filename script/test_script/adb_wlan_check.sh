#!/bin/bash

# 재부팅 후 WLAN 인터페이스 초기화를 확인하는 스크립트

DEVICE_SERIAL="$1"  # 기기 고유 식별자 (선택 사항)
TIMEOUT=300          # 최대 대기 시간 (초)
INTERVAL=5           # 확인 주기 (초)
WAIT_BEFORE_CHECK=30 # 부팅 후 대기 시간 (초)
REBOOT_DELAY=60      # 재부팅 후 재시도 대기 시간 (초)
INTERFACE="wlan0"    # 확인할 네트워크 인터페이스
OUTPUT_FILE="wlan_check_output.txt" # 결과 저장 파일

# 시험 통계 변수
TOTAL_COUNT=0
SUCCESS_COUNT=0
FAIL_COUNT=0

# adb 명령에 -s 옵션 추가 (DEVICE_SERIAL이 제공된 경우)
ADB_CMD="adb"
if [ -n "$DEVICE_SERIAL" ]; then
    ADB_CMD="adb -s $DEVICE_SERIAL"
fi

# 반복 테스트 루프
while true; do
    TOTAL_COUNT=$((TOTAL_COUNT + 1))

    # 기기 재부팅
    echo "[INFO] Rebooting device..." | tee -a "$OUTPUT_FILE"
    $ADB_CMD reboot
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to send reboot command. Ensure the device is connected and adb is configured properly." | tee -a "$OUTPUT_FILE"
        exit 1
    fi

    # 재부팅 완료 대기
    echo "[INFO] Waiting for device to reconnect..." | tee -a "$OUTPUT_FILE"
    $ADB_CMD wait-for-device
    if [ $? -ne 0 ]; then
        echo "[ERROR] Device did not reconnect." | tee -a "$OUTPUT_FILE"
        exit 1
    fi

    # 부팅 후 대기
    echo "[INFO] Waiting $WAIT_BEFORE_CHECK seconds before checking interface..." | tee -a "$OUTPUT_FILE"
    sleep $WAIT_BEFORE_CHECK

    # wlan0 인터페이스 확인
    echo "[INFO] Checking for interface '$INTERFACE'..." | tee -a "$OUTPUT_FILE"
    START_TIME=$(date +%s)
    SUCCESS=0
    while true; do
        # 현재 시간과 경과 시간 계산
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

        # 타임아웃 검사
        if [ $ELAPSED_TIME -ge $TIMEOUT ]; then
            echo "[ERROR] Timeout: Interface '$INTERFACE' not found within $TIMEOUT seconds." | tee -a "$OUTPUT_FILE"
            break
        fi

        # wlan0 인터페이스 확인
        OUTPUT=$($ADB_CMD shell ifconfig $INTERFACE 2>/dev/null)
        if echo "$OUTPUT" | grep -q "$INTERFACE"; then
            echo "[INFO] Interface '$INTERFACE' initialized successfully." | tee -a "$OUTPUT_FILE"
            echo "$OUTPUT" >> "$OUTPUT_FILE"
            SUCCESS=1
            break
        fi

        # 대기 후 재시도
        echo "[INFO] Interface '$INTERFACE' not found. Retrying in $INTERVAL seconds..." | tee -a "$OUTPUT_FILE"
        sleep $INTERVAL
    done

    if [ $SUCCESS -eq 1 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo "[INFO] Test completed successfully. Proceeding to next iteration." | tee -a "$OUTPUT_FILE"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "[INFO] Test failed. Proceeding to next iteration." | tee -a "$OUTPUT_FILE"
    fi

    # 통계 출력
    echo "[INFO] Total tests: $TOTAL_COUNT, Successes: $SUCCESS_COUNT, Failures: $FAIL_COUNT" | tee -a "$OUTPUT_FILE"

    # 다음 재부팅 시도 전 대기
    echo "[INFO] Retrying after $REBOOT_DELAY seconds..." | tee -a "$OUTPUT_FILE"
    sleep $REBOOT_DELAY

done
