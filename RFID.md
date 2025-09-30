RFID 
=====
> RFID (Radio Frequency IDentification) : 무선 주파수 식별자 혹은 전자식별자

<br/>
<br/>
<br/>
<br/>
<hr>

# RF-Reader Module

<br/>
<br/>
<br/>
<hr>

## HW block Diagram

```bash
+----------------------------------------------------+
|                Android SoC (RK356x 등)             |
|                                                    |
|  I2C(SCL/SDA) ───────────────────────────────┐     |
|  GPIO RF_INT(PRESENT) ────────────────┐      │     |
|  GPIO RF_PWR_EN(EN/RESET) ───────────┐│      │     |
+--------------------------------------+│------+     |
                                        │            |
                                        │            v
                              +-------------------------------+
                              |       RF Reader Module        |
                              |-------------------------------|
                              |  STM32F030  (I2C 슬레이브)    |
                              |      │                        |
                              |      │ SPI                    |
                              |      v                        |
                              |   TRF7970A  ──── ANT(13.56MHz)|
                              |                               |
                              |  (옵션) BUZZER(PWM)           |
                              +-------------------------------+

신호 매핑:
- RF_SCL/RF_SDA  → Android SoC I2C#X  (400 kHz 권장)
- RF_INT(PRESENT)→ GPIO4_A5  (오픈드레인 Low-active 가정, 풀업 필요)
- RF_PWR_EN      → GPIO4_A6  (모듈 EN 또는 MCU nRESET)
```

<br/>
<br/>
<br/>
<hr>

## 구성

 - 13.56 MHz RFID 트랜시버(TI TRH033M-S)
 - MCU(STM32F030C8T)
 - ANTENA

<br/>
<br/>
<hr>

### MCU
 I²C 슬레이브로 동작하며 PRESENT 핀(SoC side Interrupt)으로 이벤트를 알려주는 구조. 
 안드로이드 표준 NFC(NCI) 스택 사용 대상이 아님.

<br/>
<br/>
<br/>
<br/>
<hr>

# Software Stack

```bash
+--------------------+        Binder(AIDL)        +-------------------------------------+
|  Privileged App    | ─────────────────────────> |  vendor.kdiwin.rfreader Service     |
| (테스트/서비스 UI) |                            |  (/vendor/bin/hw/rfreader_service)  |
+--------------------+                             +-------------------+----------------+
                                                                | open/read/ioctl/poll
                                                                v
                                                        +---------------+
                                                        | /dev/rf_reader|
                                                        |   (misc chdev)|
                                                        +-------+-------+
                                                                |
                                                                v
                                                        +---------------+
                                                        | Kernel Driver |
                                                        |  rf_reader    |
                                                        | (I2C+IRQ+PM)  |
                                                        +---+-------+---+
                                                            |       |
                                              I2C Tx/Rx ────+       +─── IRQ(PRESENT)
                                                            |       |
                                                            v       v
                                                     +--------------------+
                                                     |   STM32F030 (I2C)  |
                                                     |    └─SPI→ TRF7970A |
                                                     +--------------------+

선택사항:
- Framework System API: RfReaderManager (필요 시)
- 슬립/웨이크: device_init_wakeup + enable_irq_wake(irq)
```

<br/>
<br/>
<br/>
<br/>
<hr>

# Dection Sequence

```bash
(1) 태그 근접 → TRF7970A 감지 → STM32에 이벤트
(2) STM32 → PRESENT 낮춤(IRQ) ────────┐
(3) 커널 드라이버(rf_reader) IRQ 수신   │
(4) I2C로 상태/UID/프레임 읽기          │
(5) /dev/rf_reader에서 poll 해제        │
(6) rfreader_service가 콜백 발생  <─────┘
(7) App: onTagDetected(UID) 수신
(8) App → transceive(cmd) 요청
(9) Service → ioctl/write → Kernel → I2C → STM32 → SPI → TRF → (RF 교신)
(10) 응답 역방향 전달 → App 수신
```

<br/>
<br/>
<br/>
<br/>
<hr>

# Note

<br/>
<br/>
<br/>
<hr>

## 통신 방식
Active-Type : RFID 카드는 배터리가 내장되어 스스로 전파에 데이터를 실어서 전송.
Passive-Type : 배터리 없이 리더기에서 방사된 전파에 데이터를 얹어서 반송하는 방식

<br/>
<br/>
<br/>
<hr>

## 표준 NFC(NCI) 스택

> 안드로이드 표준 NFC = NCI : NFC Controller Interface

- HW: NFC 컨트롤러(13.56 MHz, 예: NXP PN71xx, ST ST21/54 등) ↔ I²C + IRQ + VEN/RESET ↔ AP(SoC)
- 커널: I²C 장치 노출(+ IRQ), 보통 전용 커널 드라이버 또는 표준 nci_i2c 드라이버
- HAL(벤더 서비스): android.hardware.nfc AIDL HAL(안드로이드 13+), 컨트롤러와 NCI 프레임을 주고받음
- NfcService(Framework): 태그 디스패치/Reader Mode/HCE/SE 관리
- 앱: NfcAdapter/Tag/IsoDep/Ndef 등 표준 API
요점: **NCI는 “AP ↔ NFC 컨트롤러 간 표준 메시지 프로토콜”**이고, 안드로이드 표준 NFC는 이 NCI를 전제로 굴러간다.
