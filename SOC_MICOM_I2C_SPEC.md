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
| 주소 | 이름     | R/W | 크기 | 설명                            |
| ----:|---------|:---:|:---:|-----------------------------------|
| 0x00 | WHOAMI  | RO  | 1B  | 장치 식별자 (예: 0xA5)            |
| 0x01 | FW_VER  | RO  | 2B  | 펌웨어 버전 (BCD, Little-Endian)  |
| 0x20 | STATUS  | RO  | 1B  | b0=BUSY, b1=ERR, b3=EVENT_PENDING |
| 0x21 | ERROR   | RO  | 1B  | 최근 오류 코드                    |

<br/>
<br/>
<hr>

### REG: STATUS (0x20)
| 비트   | 이름            | 의미                                     |
|-------:|-----------------|------------------------------------------|
| b7..b4 | Reserved        | 항상 0                                   |
| b3     | EVENT_PENDING   | 이벤트 FIFO 데이터 존재                  |
| b2     | Reserved        | —                                        |
| b1     | ERR             | 오류 발생 (ERROR 레지스터 읽으면 클리어) |
| b0     | BUSY            | Micom 내부 처리 중                       |

**STATUS 값 해석 예시**
 - 0x00 (0000b) : 정상 상태, 이벤트 없음, 에러 없음, Micom 대기 상태
 - 0x08 (1000b) : EVENT_PENDING=1 → FIFO에 이벤트 존재 (IRQ Low 유지)
 - 0x02 (0010b) : ERR=1 → 직전 명령 오류 발생, ERROR(0x21) 읽어 원인 확인 필요
 - 0x01 (0001b) : BUSY=1 → Micom 내부 처리 중 (짧은 윈도우), 명령 재시도 필요

<br/>
<br/>
<hr>

### REG: ERROR (0x21)
| 코드 | 이름  | 의미                                    |
|------|-------|-----------------------------------------|
| 0x00 | OK    | 오류 없음                               |
| 0x01 | INVAL | 잘못된 인자/범위                        |
| 0x02 | BUSY  | busy 로 인해 명령 거부                  |
| 0x03 | I²C   | 내부 I²C 오류                           |
| 0x04 | HW    | 하드웨어 이상 (내부 디바이스 응답 없음) |

 - 동작 규칙: SoC가 0x21 레지스터를 읽으면 Micom은 위 코드 중 하나를 반환.
 - 클리어 규칙: 0x21을 읽는 순간 STATUS(0x20).ERR이 자동으로 0으로 클리어 (read-to-clear).
 - 초기값: 전원 인가 후 정상 상태에서는 기본값 0x00(OK).
 - 우선순위: 여러 오류가 겹칠 경우 Micom은 치명도 순으로 대표 코드 하나를 출력. (HW > I²C > BUSY > INVAL > OK)
> 클리어 규칙: ERROR(0x21)을 읽으면 STATUS.ERR가 0으로 자동 클리어됨 (read-to-clear).

<br/>
<br/>
<br/>
<hr>

## 4.2 터치 이벤트 레지스터
> Micom이 조명,대기 ON/OFF 를 직접 제어.  
> 따라서 Micom은 입력 엣지(PRESS/RELEASE)가 아니라, **논리 상태 변화(ON/OFF)**가 발생할 때만 이벤트를 report. 
> SoC는 Micom이 report한 상태를 그대로 반영  

| 주소 | 이름         | R/W | 크기 | 설명                                           |
| ----:|--------------|:---:|:---:|-------------------------------------------------|
| 0x22 | EVENT_COUNT  | RO  | 1B  | FIFO에 대기 중인 이벤트 개수                    |
| 0x52 | EVENT_POP    | RO  | 3B  | 읽을 때마다 이벤트 1건 POP → [CODE][STATE][SEQ] |

<br/>
<br/>
<hr>

### REG: EVENT_POP(0x22)
- **CODE**: 키 종류
  * 0x00 = LIGHT_ALL, 0x01..0x06 = LIGHT_1..6
  * 0x10 = STANDBY_ALL, 0x11..0x12 = STANDBY_1..2
- **STATE**: 0x01=ON (켜짐), 0x00=OFF (떨어짐)
- **SEQ**: 0x00~0xFF 순환 증가 (유실/중복 검출용)

**EVENT_COUNT/EVENT_POP 사용 시나리오**
- **0x22(EVENT_COUNT)=0x00** : FIFO 비어 있음, IRQ High 유지
- **0x22(EVENT_COUNT)>0** : FIFO에 이벤트 존재, IRQ Low 유지, 해당 개수 만큼 EVENT_POP읽기 필요
- **0x52(EVENT_POP)** : 읽을 때마다 FIFO에서 1건 제거, [CODE][STATE][SEQ] 반환

시나리오 예시

 - 사용자가 버튼 짧게 누름 → Micom 내부 토글 정책 적용 → 조명 상태 ON
   * EVENT_POP: CODE=조명채널, STATE=ON, SEQ=증가

 - 다시 누름 → Micom 토글 → 조명 상태 OFF
   * EVENT_POP: CODE=조명채널, STATE=OFF, SEQ=증가

**IRQ 동작**:
- MCU_INT = Low → FIFO 데이터 존재
- FIFO=0 → MCU_INT 자동 High 복귀

<br/>
<br/>
<hr>

## 4.3 밝기 제어 레지스터
| 주소 | 이름                   | R/W | 크기| 범위  | 설명                                                                    |
| ----:|------------------------|:---:|:---:|:-----:|-------------------------------------------------------------------------|
| 0x15 | MIN_BRIGHTNESS_GLOBAL  | RW  | 1B  | 1..20 | 전체 LED 최저 밝기. 쓰기 즉시 적용.                                     |
| 0x10 | TARGET_BRIGHTNESS_GROUP| RW  | 1B  | —     | 예약 (향후용)                                                           |
| 0x11 | TARGET_BRIGHTNESS_INDEX| RW  | 1B  | —     | 예약 (향후용)                                                           |
| 0x59 | LED_STATE_BITMAP       | RO  | N   | 0..20 | 예약 (향후용) LED별 유효 밝기 배열 (0=꺼짐, 1..20=밝기). 권장 N=8 채널. |

<br/>
<br/>
<hr>

### REG: MIN_BRIGHTNESS_GLOBAL(0x15) 
 - 유효 값 범위 : 1~20
 - 잘못된 값 (0, 21 이상) 쓰기 시, ERROR=0x01(INVAL)
 - 읽으면 현재 설정도니 MIN_BRIGHTNESS_GLOBAL 값 반환

### REG: LED_STATE_BITMAP(0x59) 
 TBD


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
<hr>

## 6.1 STATUS↔ERROR 동작 규칙

 - STATUS(0x20): 즉시 상태 확인용 **플래그 비트맵**
   * b1=ERR 이 1이면 직전 명령에서 Error 발생 
 - ERROR(0x21): 상세 오류 코드 제공(단일 코드)


 **규칙**
 1. STATUS.ERR=1 → ERROR(0x21) 읽어 원인 확인
 2. 클리어: ERROR(0x21) 읽기 시 STATUS.ERR 자동 클리어

<br/>
<br/>
<hr>

### 6.1.1 오류 처리 플로우

```bash
if (read8(STATUS) & ERR) {
    code = read8(ERROR); // 대표 코드 확인 + STATUS.ERR=0
    switch (code) {
    case 0x00: /* OK */ break;
    case 0x01: /* INVAL */ log_warn("INVAL"); break; // 재시도 금지, 인자 보정
    case 0x02: /* BUSY */ retry_with_backoff(3); break; // 10→20→40ms 등
    case 0x03: /* I2C */ i2c_recover_once_then_fail(); break; // 1회 리커버리
    case 0x04: /* HW */ enter_degraded_and_notify(); break; // 장애 모드
    default: log_error("UNKNOWN ERROR CODE");
    }
}
```

<br/>
<br/>
<hr>

### 6.1.2 오류별 기본 액션 표

| ERROR 코드 | 의미                     | 기본 액션                                           |
| ----------:|--------------------------|:----------------------------------------------------|
| 0x00       | OK                       | 추가 조치 없음                                      |
| 0x01       | INVAL(잘못된 인자/범위)  | **재시도 금지.** 인자 보정/검증 로직 강화, 로그 남김|
| 0x02       | BUSY(바쁨)               | **지수 백오프 재시도(최대 3회)**                    |
| 0x03       | I2C 오류                 | I²C 리커버리 1회 → 실패 시 상위 보고                |
| 0x04       | HW(하드웨어 이상)        | **장애 모드 진입**, 사용자 알림/서비스 요청         |



<br/>
<br/>
<br/>
<br/>
<hr>

# 7. 향후 확장 계획
- LED 개별/그룹 밝기 제어 지원
- 추가 이벤트 타임(롱프레스, 프레스, 릴리즈)

