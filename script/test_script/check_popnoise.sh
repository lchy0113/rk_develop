#!/bin/bash

# 초기 상태 설정
prev_classd_state="off"

# 모니터링 주기 (초 단위)
SLEEP_INTERVAL=0.1

echo "Starting Pop Noise Detection with adb..."

# 무한 루프로 상태 모니터링
while true; do
    # 현재 LineOut Amp1 상태 읽기
    lineout_state=$(adb shell "tinymix 'LineOut Amp1'" | grep -o '>On\|>Off')

    # 현재 ClassD Amp Enable 상태 읽기
    current_classd_state=$(adb shell "tinymix 'ClassD Amp Enable'" | grep -o '>On\|>Off')

    # 조건: LineOut Amp1이 Off 상태이고, ClassD Amp Enable이 Off -> On으로 변경될 때 Pop Noise 발생
    if [[ "$lineout_state" == ">Off" && "$current_classd_state" == ">On" ]]; then
        echo "[Pop Noise Detected] Timestamp: $(date)"
        echo "LineOut Amp1 State: $lineout_state"
        echo "Previous ClassD Amp State: $prev_classd_state, Current ClassD Amp State: $current_classd_state"
        echo "-----------------------------------"
    fi

    # 이전 상태 업데이트
    prev_classd_state="$current_classd_state"

    # 주기적으로 상태 체크
    sleep $SLEEP_INTERVAL
done

