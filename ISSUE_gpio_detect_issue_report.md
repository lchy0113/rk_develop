# GPIO Detect Instability Issue Report

## 1. 개요

- 대상 신호: EMERGENCYSIGNAL_0 (GPIO 122)
- 현재 구조: sysfs 기반 GPIO interrupt + HAL polling
- 문제: 이벤트 발생 시 신호가 안정적으로 검출되지 않음

---

## 2. 로그 분석

### 2.1 발생 로그
02-23 03:22:03.545131 D gpio edge detected!, EMERGENCYSIGNAL_0(122): 1
02-23 03:22:03.545595 D gpio value changed, EMERGENCYSIGNAL_0: 1
02-23 03:22:03.546381 D gpio edge detected!, EMERGENCYSIGNAL_0(122): 1
02-23 03:22:03.547619 D gpio edge detected!, EMERGENCYSIGNAL_0(122): 1
02-23 03:22:03.548850 D gpio edge detected!, EMERGENCYSIGNAL_0(122): 0
02-23 03:22:03.550079 D gpio edge detected!, EMERGENCYSIGNAL_0(122): 1
02-23 03:22:03.551315 D gpio edge detected!, EMERGENCYSIGNAL_0(122): 1
02-23 03:22:03.552557 D gpio edge detected!, EMERGENCYSIGNAL_0(122): 1
02-23 03:22:03.553881 D gpio edge detected!, EMERGENCYSIGNAL_0(122): 1
02-23 03:22:03.554234 D gpio value changed, EMERGENCYSIGNAL_0: 0
02-23 03:22:03.555152 D gpio edge detected!, EMERGENCYSIGNAL_0(122): 1
02-23 03:22:03.556386 D gpio edge detected!, EMERGENCYSIGNAL_0(122): 1
02-23 03:22:03.557608 D gpio edge detected!, EMERGENCYSIGNAL_0(122): 1
02-23 03:22:03.558011 D gpio value changed, EMERGENCYSIGNAL_0: 1

---

## 3. 문제 현상 정리

- 약 13ms(0.01288) 내 다수 edge 발생
- 값이 1 → 0 → 1로 반복 토글
- edge와 value 결과 불일치

---

## 4. 원인 분석

### 구조적 한계
GPIO IRQ → sysfs → HAL poll → value read

문제:
- IRQ 시점과 read 시점 불일치
- debounce 없음
- userspace 지연 존재

---

## 5. 개선 방안

### 1) 커널 처리
GPIO IRQ → debounce → stable check → validated event

### 2) HAL 역할
validated 상태만 소비

### 3) 인터페이스
/dev/detect0 (char device)

---

## 6. 결론

현재 구조에서는 정확한 detect 보장 불가  
커널 기반 필터링 구조로 변경 필요
