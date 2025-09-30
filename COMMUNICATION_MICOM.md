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
 - 핵심 기능: **(1) 터치키 이벤트 처리(켜짐/꺼짐)** **(2) LED 최저 밝기 적용 + 상태 조회**  

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
 - IRQ 조건 : LEVEL_LOW(FIFO에 1건 이상이면, LOW유지)  
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

 - Core Register

| Addr | 이름                    | R/W | Size | 설명                                                           |
| ---: | --------------------- | :-: | :--: | ---------------------------------------------------------------- |
| 0x00 | WHOAMI                |  RO |   1  | 장치 식별(예: 0xA5)                                              |
| 0x01 | FW_VER                |  RO |   2  | 펌웨어 버전(BCD, LE)                                             |
| 0x20 | STATUS                |  RO |   1  | **b0 BUSY**, **b1 ERR**, **b3 EVENT_PENDING**, 그 외 reserved(0) |
| 0x21 | ERROR                 |  RO |   1  | 0x00 OK / 0x01 INVAL / 0x02 BUSY / 0x03 I2C / 0x04 HW            |

 - Key-Event Register

> IRQ(Level-Low) : Micom 이 이벤트를 FIFO에 넣으면 MCU_INT=low. 
> Soc 가 모두 읽어 FIFO=0 이 되면 High

| Addr     | 이름                  | R/W | Size | 설명                                                    |
| -------: | --------------------- | :-: | :--: | ------------------------------------------------------- |
| **0x22** | EVENT_COUNT           |  RO |   1  | 이벤트 FIFO 에 대기중인 개수                            |
| **0x52** | EVENT_POP             |  RO |   3  | **읽을 때마다 1건 POP** → `[CODE][STATE][SEQ]`           |

 - Brightness-Set Register  

레벨 1~20 지원

> 현 단계 정책 : SoC 는 최저 밝기(MIN_BRIGHTNESS_GLOBAL) 만 설정 → 명령 수신 즉시 적용.
> TARGET_*는 RW로 남겨두되(향후용), 현재 동작에는 영향 없음.

|     Addr | 이름                        |   R/W  |  Size |         값 범위        | 설명                                                    |
| -------: | ------------------------- | :----: | :---: | :-----------------: | ------------------------------------------------------------ |
| **0x15** | **MIN_BRIGHTNESS_GLOBAL** | **RW** | **1** |      **1..20**      | **LED 최저 밝기**. **쓰기 즉시 적용**. 읽기 시 현재 MIN 반환.|
|     0x10 | TARGET_BRIGHTNESS_GROUP   |   RW   |   1   |          —          | **미사용(향후용)** — b0=light, b1=standby, (b0|b1=both)      |
|     0x11 | TARGET_BRIGHTNESS_INDEX   |   RW   |   1   |          —          | **미사용(향후용)** — 0=all, 1..6=light1..6, 7..8=standby1..2 |
| **0x59** | **LED_STATE_BITMAP**      | **RO** | **N** | **각 채널 0 또는 1..20** | 전체 LED의 **유효 밝기 배열**(블록 리드). `0=꺼짐`, `1..20=밝기`. 권장 N=8 채널. |

<br/>
<br/>
<br/>
<br/>
<hr>

# Core Register 

| Addr | 이름     | R/W | Size | 설명                                                                 |
| ---: | ------ | :-: | :--: | ------------------------------------------------------------------ |
| 0x00 | WHOAMI |  RO |   1  | 장치 식별(예: 0xA5)                                                     |
| 0x01 | FW_VER |  RO |   2  | 펌웨어 버전(BCD, Little-Endian)                                         |
| 0x20 | STATUS |  RO |   1  | **b0=BUSY**, **b1=ERR**, **b3=EVENT_PENDING**, 그 외 **Reserved(0)** |
| 0x21 | ERROR  |  RO |   1  | 최근 오류 코드: `0x00 OK / 0x01 INVAL / 0x02 BUSY / 0x03 I2C / 0x04 HW`  |

<br/>
<br/>
<hr>

### STATUS (0x20) 비트맵

|    Bit | 이름                | 의미                    | 세트/클리어 규칙(권장)                        |
| -----: | ----------------- | --------------------- | ------------------------------------ |
| b7..b4 | Reserved          | 항상 0                  | —                                    |
|     b3 | **EVENT_PENDING** | 이벤트 FIFO에 데이터 존재      | FIFO가 0이면 0                          |
|     b2 | Reserved          | (미사용)                 | 0                                    |
|     b1 | **ERR**           | 직전 명령에서 오류 발생         | **ERROR(0x21) 읽기 시 0으로 클리어**(sticky) |
|     b0 | **BUSY**          | Micom 내부 처리 중(짧은 윈도우) | 처리 종료 시 0                            |

> 메모: 현재 스펙은 “즉시 적용형(MIN만 설정)”이라 BUSY가 1이 될 일은 희소.

<br/>
<br/>
<hr>

### ERROR (0x21) 코드

 - 0x00 OK : 오류 없음
 - 0x01 INVAL : 잘못된 인자/범위(예: 0x15에 0 또는 21↑)
 - 0x02 BUSY : 바쁜 상태에서 들어온 명령 거부
 - 0x03 I2C : 내부 I²C 실패
 - 0x04 HW : 하드웨어 이상(내부 디바이스 응답 없음 등)

 부팅/프로브 시퀀스

```bash
i2c get 0x00 # WHOAMI
i2c get 0x01 # FW_VER
```

<br/>
<br/>
<br/>
<br/>
<hr>

# Key-Event Register (터치키 이벤트)

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

 - 형식: [CODE][STATE][SEQ] (각 1바이트)  
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

<br/>
<br/>
<br/>
<br/>
<hr>

# Brightness-Set Register (밝기 조절 제어 명령)

> 요약: SoC는 최저 밝기(1~20) 만 0x15에 Write. 쓰기 즉시 적용되며, 개별 밝기/APPLY 명령은 사용하지 않음.

|     Addr | 이름                        |   R/W  |  Size |         값 범위        | 설명                                                          |
| -------: | ------------------------- | :----: | :---: | :-----------------: | ----------------------------------------------------------- |
| **0x15** | **MIN_BRIGHTNESS_GLOBAL** | **RW** | **1** |      **1..20**      | **LED 최저 밝기**. **쓰기 즉시 적용**. 읽으면 현재 MIN 반환.                 |
|     0x10 | TARGET_BRIGHTNESS_GROUP   |   RW   |   1   |          —          | **미사용(향후용)** — b0=light, b1=standby, (b0|b1=both)           |
|     0x11 | TARGET_BRIGHTNESS_INDEX   |   RW   |   1   |          —          | **미사용(향후용)** — 0=all, 1..6=light1..6, 7..8=standby1..2      |
| **0x59** | **LED_STATE_BITMAP**      | **RO** | **N** | **각 채널 0 또는 1..20** | 전체 LED의 **유효 밝기 배열**(블록 리드). `0=꺼짐`, `1..20=밝기`. 권장 N=8 채널. |


소프트웨어 시퀀스

```bash
i2c set 0x15 0x06 

```
