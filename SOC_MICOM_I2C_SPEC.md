 SoC ↔ Micom I²C 프로토콜 스펙
====

<br/>
<br/>
<br/>
<br/>
<hr>

# 1. 개요
- **버스**: SoC (I²C1 Master, 10 kHz) ↔ Micom STM32F030C8T (I²C Slave)  
- **슬레이브 주소**: 0x28 (7-bit, 임시)  
- **핀 구성**: MCU_SCL, MCU_SDA, MCU_INT (Active-Low, Open-Drain, Level)  
- **목적**: 터치 키 이벤트 처리 및 LED 밝기 제어를 위한 SoC–Micom 간 통신  

<br/>
<br/>
<br/>
<br/>
<hr>

# 2. 시스템 구성
- SoC I²C ──(MCU_SCL/MCU_SDA)── Micom (STM32F030C8T, Slave@0x28)  
- Micom INT ──(MCU_INT)── SoC GPIO (IRQ: Low-Level, OD, Pull-up)  
- Micom I²C Master ──(LT_KEY_SCL/LT_KEY_SDA)── BS83BXXC (키/LED 컨트롤러, 0x50)  
> Micom은 BS83B 및 LED를 직접 제어하며, SoC는 Micom과만 통신.  

<br/>
<br/>
<br/>
<br/>
<hr>

# 3. 버스/타이밍 규칙
- **주소 규칙**: 7-bit (0x28 임시)  
- **클록 속도**: 10 kHz  
- **멀티바이트**: Little-Endian  
- **IRQ 조건**: FIFO에 이벤트 ≥1건 존재 시 Low 유지, FIFO가 0이면 High 복귀  
- **명령 간 최소 간격**: 10 ms  
- **단일 작업 타임아웃**: 100 ms  
- **Micom Ready 시간**: 전원 인가 후 200 ms 이내 WHOAMI/FW_VER 응답  

<br/>
<br/>
<br/>
<br/>
<hr>

# 4. 레지스터 맵

<br/>
<br/>
<br/>
<hr>

## 4.1 코어 레지스터
| 주소 | 이름     | R/W | 크기 | 설명 |
| ----:|---------|:---:|:---:|-----|
| 0x00 | WHOAMI  | RO  | 1B  | 장치 식별자 (예: 0xA5) |
| 0x01 | FW_VER  | RO  | 2B  | 펌웨어 버전 (BCD, Little-Endian) |
| 0x20 | STATUS  | RO  | 1B  | b0=BUSY, b1=ERR, b3=EVENT_PENDING |
| 0x21 | ERROR   | RO  | 1B  | 최근 오류 코드 (0x00 OK, 0x01 INVAL, 0x02 BUSY, 0x03 I2C, 0x04 HW) |

<br/>
<br/>
<hr>

### STATUS (0x20) 비트맵
| 비트 | 이름            | 의미 |
|----:|-----------------|------|
| b7..b4 | Reserved      | 항상 0 |
| b3 | EVENT_PENDING   | 이벤트 FIFO 데이터 존재 |
| b2 | Reserved        | — |
| b1 | ERR             | 오류 발생 (ERROR 레지스터 읽으면 클리어) |
| b0 | BUSY            | Micom 내부 처리 중 |

<br/>
<br/>
<hr>

### ERROR (0x21) 코드 정의
- 0x00 OK : 오류 없음
- 0x01 INVAL : 잘못된 인자/범위
- 0x02 BUSY : 바쁨으로 인해 명령 거부
- 0x03 I²C : 내부 I²C 오류
- 0x04 HW : 하드웨어 이상 (내부 디바이스 응답 없음)

<br/>
<br/>
<br/>
<hr>

## 4.2 터치 이벤트 레지스터
| 주소 | 이름         | R/W | 크기 | 설명 |
| ----:|--------------|:---:|:---:|-----|
| 0x22 | EVENT_COUNT  | RO  | 1B  | FIFO에 대기 중인 이벤트 개수 |
| 0x52 | EVENT_POP    | RO  | 3B  | 읽을 때마다 이벤트 1건 POP → [CODE][STATE][SEQ] |

<br/>
<br/>
<hr>

### EVENT_POP 포맷
- **CODE**: 키 종류
  - 0x00 = LIGHT_ALL, 0x01..0x06 = LIGHT_1..6
  - 0x10 = STANDBY_ALL, 0x11..0x12 = STANDBY_1..2
- **STATE**: 0x01=ON (켜짐), 0x00=OFF (꺼짐)
- **SEQ**: 0x00~0xFF 순환 증가 (유실/중복 검출용)

**IRQ 동작**:
- MCU_INT = Low → FIFO 데이터 존재
- FIFO=0 → MCU_INT 자동 High 복귀

**이벤트 예시**:
- LIGHT_2 토글 ON→OFF:
  - `02 01 37` → ON
  - `02 00 38` → OFF

<br/>
<br/>
<hr>

## 4.3 밝기 제어 레지스터
| 주소 | 이름                   | R/W | 크기 | 범위   | 설명 |
| ----:|------------------------|:---:|:---:|:-----:|-----|
| 0x15 | MIN_BRIGHTNESS_GLOBAL  | RW  | 1B  | 1..20 | 전체 LED 최저 밝기. 쓰기 즉시 적용. |
| 0x10 | TARGET_BRIGHTNESS_GROUP| RW  | 1B  | —     | 예약 (향후용) |
| 0x11 | TARGET_BRIGHTNESS_INDEX| RW  | 1B  | —     | 예약 (향후용) |
| 0x59 | LED_STATE_BITMAP       | RO  | N   | 0..20 | LED별 유효 밝기 배열 (0=꺼짐, 1..20=밝기). 권장 N=8 채널. |

<br/>
<br/>
<br/>
<br/>
<hr>

# 5. 동작 시퀀스

<br/>
<br/>
<br/>
<hr>

## 5.1 초기화
```bash
i2c get 0x00  # WHOAMI 읽기
i2c get 0x01  # FW_VER 읽기
```

<br/>
<br/>
<br/>
<hr>

## 5.2 터치 이벤트 처리
1. 사용자 터치 발생 → Micom 디바운스 처리 후 FIFO에 이벤트 push → MCU_INT Low 유지
2. SoC가 EVENT_COUNT(0x22) 읽음
3. cnt>0이면 EVENT_POP(0x52) 반복 읽기 → [CODE][STATE][SEQ] 획득
4. FIFO=0이 되면 MCU_INT High 복귀

<br/>
<br/>
<br/>
<hr>

## 5.3 밝기 제어
```bash
i2c set 0x15 0x06   # 전체 LED 최저 밝기 = 6 으로 설정
```

<br/>
<br/>
<br/>
<br/>
<hr>

# 6. 타이밍 및 오류 처리
- **I²C 클록**: 10 kHz
- **IRQ 응답 시간**: SoC는 50 ms 이내 처리 필요
- **NACK 응답**: 최대 3회 재시도
- **잘못된 명령/범위 초과 값**: ERROR=0x01 설정
- **타임아웃**: 100 ms 응답 없으면 SoC 로그 기록

<br/>
<br/>
<br/>
<br/>
<hr>

# 7. 향후 확장 계획
- LED 개별 밝기 제어 지원
- 추가 이벤트 타입 (롱프레스, 멀티키)
- 그룹 밝기 설정 지원


