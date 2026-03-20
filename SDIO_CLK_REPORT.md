# SDIO CLK Drive Strength 변경에 따른 Wi-Fi 성능 시험 결과 보고

SWP5204B P02

<br/>
<br/>
<br/>
<hr>

## 1. 시험 목적

SDIO 인터페이스의 CLK Drive Strength(Level 0~2) 변경에 따른  
Wi-Fi 통신 성능 및 안정성 영향을 확인하고 최적 설정값을 도출.

<br/>
<br/>
<br/>
<hr>

## 2. 시험 환경

- 시험 대상: DUT (Wi-Fi SDIO 인터페이스 사용)
- 시험 도구: iperf3
- 시험 방식:
  - TCP 기반 성능 측정
  - 4 parallel stream 사용
- 시험 항목:
  - TX (DUT → Server)
  - RX (Server → DUT, `-R` 옵션)
- 시험 시간:
  - 30초 (단기 성능 확인)
  - 300초 (장기 안정성 확인)
- Wi-Fi 통신 거리: **1m (근거리, 장애물 없음)**

<br/>
<br/>
<br/>
<hr>


## 3. 시험 조건

| 항목 | 값 |
|------|----|
| SDIO CLK | 50MHz |
| Strength Level | 0 / 1 / 2 |
| Stream 수 | 4 |
| 측정 지표 | Throughput, Retransmission |
| 거리 | 1m |

<br/>
<br/>
<br/>
<hr>

## 4. 시험 결과

<br/>
<br/>

### 4.1 30초 시험 결과

<br/>

#### TX (Upload)

| Strength | Throughput | Retrans |
|----------|------------|---------|
| Level 0 | 약 31 Mbps | 1 |
| Level 1 | 약 33 Mbps | 4 |
| Level 2 | 약 30 Mbps | 4 |

<br/>

#### RX (Download)

| Strength | Throughput | Retrans |
|----------|------------|---------|
| Level 0 | 약 12 Mbps | 23 |
| Level 1 | 약 13 Mbps | 0 |
| Level 2 | 약 14 Mbps | 0 |

<br/>
<br/>

### 4.2 300초 시험 결과

<br/>

#### TX (Upload)

| Strength | Throughput | Retrans |
|----------|------------|---------|
| Level 0 | 약 33 Mbps | 704 |
| Level 1 | 약 34 Mbps | 13 |
| Level 2 | 약 26 Mbps | 96 |

#### RX (Download)

| Strength | Throughput | Retrans |
|----------|------------|---------|
| Level 0 | 약 15 Mbps | 10 |
| Level 1 | 약 13 Mbps | 0 |
| Level 2 | 약 14 Mbps | 50 |

<br/>
<br/>
<br/>
<hr>

## 5. 핵심 분석 (거리 1m 기준)

<br/>
<br/>

### 5.1 RF 영향 배제

- 시험 거리가 1m로 매우 짧기 때문에 RF 환경 영향은 거의 없음
- 성능 저하 원인은 무선 환경이 아닌 **디지털 인터페이스(SDIO)**로 판단

<br/>
<br/>

### 5.2 로그 기반 이상 현상

- throughput이 0bps로 떨어지는 구간 존재
- 일부 stream만 동작하는 현상 발생
- retrans 없이도 전송 정지 발생

→ 패킷 손실이 아닌 **전송 자체가 멈추는 현상**

<br/>
<br/>
<br/>
<hr>

## 6. Level별 분석

<br/>
<br/>

### Level 0 (낮은 Drive Strength)

- 300초 시험에서 retrans 급증 (704)
- 신호 amplitude 부족 가능성

**해석:**
- 신호 margin 부족
- 데이터 인식 오류 증가 → TCP retrans 증가

→ **Under-driving 상태**

<br/>
<br/>

### Level 2 (높은 Drive Strength)

- 장기 시험에서 throughput 저하
- retrans 증가

**해석:**
- overshoot / ringing 발생 가능
- timing violation 가능성

→ **Over-driving 상태**

<br/>
<br/>

### Level 1 (중간 Drive Strength)

- retrans 거의 없음
- 장기 시험에서도 안정적인 throughput 유지

**해석:**
- 신호 무결성(Signal Integrity)이 가장 안정적인 상태

→ **최적 구간**

<br/>
<br/>
<br/>
<hr>

## 7. 종합 결론

- RF 환경(1m) 영향은 배제 가능
- Wi-Fi 성능은 SDIO 인터페이스 신호 품질에 직접적으로 영향받음
- Drive Strength에 따라 성능과 안정성이 크게 변동됨

<br/>
<br/>
<br/>
<hr>

## 8. 최종 권장 설정
SDIO CLK Drive Strength: Level 1

<br/>
<br/>
<br/>
<hr>

## 9. etc.

> 본 시험결과를 통해 RF 환경이 아닌 SDIO 신호 품질이 Wi-Fi 성능을 결정한다는 것을 보여줌.