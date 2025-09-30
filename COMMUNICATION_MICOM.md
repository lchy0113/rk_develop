SoC↔Micom I²C 통신 
=====

<br/>
<br/>
<br/>
<br/>
<hr>

# 요약  

 - 버스: SoC(I²C1 Master, 10 kHz) ↔ Micom STM32F030C8T (Slave @ ~~0x28~~, 7-bit)  
 - 핀(Net): MCU_SCL, MCU_SDA, MCU_INT(Active-Low, Open-Drain, Level)  
 - 핵심 기능: **(1) 터치키 이벤트(IRQ + FIFO)** **(2) LED 최저 밝기 적용 + 밝기 설정/적용**  

<br/>
<br/>
<br/>
<br/>
<hr>

# 시스템 구성

 - SoC I²C1 ──(MCU_SCL/MCU_SDA)── Micom(STM32F030C8T, Slave@~~0x28~~)  
 - Micom INT ──(MCU_INT)── SoC GPIO(IRQ: Level-Low, OD, Pull-up)  
 - Micom I²C Master ──(LT_KEY_SCL/LT_KEY_SDA)── BS83BXXC(키/LED 컨트롤러, 0x50)  
> Micom은 BS83B와 키/LED를 직접 제어. SoC는 Micom과만 통신.  

<br/>
<br/>
<br/>
<br/>
<hr>

# BUS/TIMING 규칙

 - 주소 규칙 : 7-bit(~~0x28~~)  
 - 속도 : 10 kHz  
 - 멀티바이트 : Little-Endian  
 - 명령 간 최소 간격 : 10 ms  
 - 단건 작업 타임아웃 : 100 ms   
 - Micom Ready 시간 : 전원 인가 후 ≤ 200 ms 내 WHOAMI/FW_VER 응답  

<br/>
<br/>
<br/>
<br/>
<hr>

# Register

<br/>
<br/>
<br/>
<hr>


## Core Register (필수만)

| Addr | 이름                    | R/W | Size | 설명                                                                                              |
| ---: | --------------------- | :-: | :--: | ----------------------------------------------------------------------------------------------- |
| 0x00 | WHOAMI                |  RO |   1  | 장치 식별(예: 0xA5)                                                                                  |
| 0x01 | FW_VER                |  RO |   2  | 펌웨어 버전(BCD, LE)                                                                                 |
| 0x20 | STATUS                |  RO |   1  | **b0 BUSY**, **b1 ERR**, **b2 APPLIED**, **b3 EVENT_PENDING**, **b4 최저 밝기 적용됨** *(내부명 CLAMPED)* |
| 0x21 | ERROR                 |  RO |   1  | 0x00 OK / 0x01 INVAL / 0x02 BUSY / 0x03 I2C / 0x04 HW                                           |
| **0x22** | EVENT_COUNT           |  RO |   1  | 이벤트 FIFO 잔량(개수)                                                                                 |
| **0x52** | EVENT_POP             |  RO |   3  | **읽을 때마다 1건 POP** → `[CODE][TYPE][SEQ]`                                                         |
| 0x10 | TARGET_GROUP          |  RW |   1  | b0=light, b1=standby, (b0|b1=both)                                                              |
| 0x11 | TARGET_INDEX          |  RW |   1  | 0=all, 1~6=light1~6, 7~8=standby1~2                                                             |
| 0x12 | BRIGHTNESS            |  RW |   1  | 밝기 1~20 단계                                                                                      |
| 0x13 | TRANSITION_MS         |  RW |   2  | 페이드(ms, LE)                                                                                     |
| 0x14 | APPLY                 |  WO |   1  | 0x01=적용 시작                                                                                      |
| 0x15 | MIN_BRIGHTNESS_GLOBAL |  RW |   1  | **LED 최저 밝기(1~20)**                                                                             |
| 0x1A | BRIGHTNESS_EFFECTIVE  |  RO |   1  | 실제 적용 밝기(**최저 밝기 적용** 반영)                                                                       |

<br/>
<br/>
<br/>
<hr>

## Core Register (선택/옵션)

| Addr | 이름                     | R/W | Size | 설명            |
| ---: | ---------------------- | :-: | :--: | ------------- |
| 0x16 | MIN_BRIGHTNESS_LIGHT   |  RW |   1  | 조명 그룹 최저 밝기   |
| 0x17 | MIN_BRIGHTNESS_STANDBY |  RW |   1  | 대기 그룹 최저 밝기   |
| 0x18 | STORE_SETTINGS         |  WO |   1  | `0xA5`=NVM 저장 |
| 0x58 | KEY_STATE_BITMAP       |  RO |   2  | 현재 눌림 비트맵(LE) |

<br/>
<br/>
<br/>
<br/>
<hr>

# 터치키 이벤트 (IRQ 기반)

 - IRQ Trigger 설정
   * MCU_INT: ACtive-Low, Level, Open-Drain
 Micom의 이벤트 FIFO에 데이터가 하나라도 있으면 라인이 **Low 유지**(연속 IRQ보장).  
 FIFO를 모두 비우면 **High 복귀**.  

<br/>
<br/>
<br/>
<hr>

## 하드웨어 동작

 - Micom이 이벤트를 FIFO에 넣으면 **MCU_INT = Low** (레벨 유지)  
 - SoC가 FIFO를 모두 읽으면 **High로 자동 복귀**  

<br/>
<br/>
<br/>
<hr>

## 소프트웨어 시퀀스

 1. 사용자 터치 → Micom 디바운스 → 상태 변화 시 이벤트 push → MCU_INT=Low  
 2. SoC  
   cnt = EVENT_COUNT(0x22) 읽기 → 0이면 종료  
   cnt 만큼 EVENT_POP(0x52) 3바이트 반복 읽기 → [CODE][STATE][SEQ] 처리  
 3. FIFO=0이 되면, Micom이 MCU_INT=High로 자동 복귀

<br/>
<br/>
<br/>
<hr>

## EVENT_POP(0x52) 3바이트 포맷

 - 형식: [CODE][TYPE][SEQ] (각 1바이트)  
   * **CODE**  : 키 종류  
         0x00 = LIGHT_ALL, 0x01..0x06 = LIGHT_1..6,   
         0x10 = STANDBY_ALL, 0x11..0x12 = STANDBY_1..2  
   * **STATE** : 0x01=ON  (활성화/켜짐)   
                 0x00=OFF (비활성/꺼짐)  
   * **SEQ**   : 0x00 ~ 0xFF 순환 증가(유실/중복 검출용)  

 > PRESS/RELEASE/LONG 타입은 사용하지 않음.   Micom은 상태가 바뀔때만 ON(0x1) 또는 OFF(0x0) 이벤트를 FIFO에 넣음.  

<br/>
<br/>
<br/>
<hr>

## 터치키 이벤트 예시

 - A) 조명2 (LIGHT_2) 버튼 : 켜짐 → 꺼짐  

| 회차 | EVENT_POP 3B (HEX) | 의미                                               |
| -: | ------------------ | ------------------------------------------------ |
|  1 | `02 01 37`         | CODE=0x02(LIGHT_2), **STATE=활성화(켜짐)**, SEQ=0x37  |
|  2 | `02 00 38`         | CODE=0x02(LIGHT_2), **STATE=비활성화(꺼짐)**, SEQ=0x38 |



 - B) 조명5 (LIGHT_5) 버튼을 길게 눌렀다가 뗌(길이 무시, 상태만 보고)  
 
| 회차 | EVENT_POP  | 의미                   |
| -: | ---------- | -------------------- |
|  1 | `05 01 09` | LIGHT_5 **활성화(켜짐)**  |
|  2 | `05 00 0A` | LIGHT_5 **비활성화(꺼짐)** |


 - C) 대기1 (STANDBY_1) 짧게 토글  
 
| 회차 | EVENT_POP  | 의미                     |
| -: | ---------- | ---------------------- |
|  1 | `11 01 A1` | STANDBY_1 **활성화(켜짐)**  |
|  2 | `11 00 A2` | STANDBY_1 **비활성화(꺼짐)** |


