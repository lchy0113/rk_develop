# WIFI

<br/>
<br/>
<br/>
<br/>
<hr>

[Fn-Link 6222B-SRC](#fn-link-6222b-src)

<br/>
<br/>
<br/>
<br/>
<hr>

## Fn-Link 6222B-SRC 

 FN-Link 사에서 제공하는 6222B-SRC(WiFi 모듈) 
 **Realtek RTL8822CS** IC을 기반으로 함.

 - wifi표준 : IEEE 802.11 a/b/g/n/ac
 - 데이터전송률 : 최대 867Mbps
 - 인터페이스 : SDIO V3.0(wifi), uart/pcm 인터페이스 사용
 - bluetooth : bt5.0, bt4.2 지원
 - datasheet : https://downloads.codico.com/misc/AEH/FN-Link/?dir=USB%5C6222D-UUC#


```bash
+----------------------+             +-----------------+
|(host)                |             |(combomodule)    |
| GPIO0_B4 BT_WAKE_HOST+-------------+BT_WAKE_HOST     |
| GPIO0_B5 HOST_WAKE_BT+-------------+HOST_WAKE_BT     |
| GPIO1_D6 HOST_WAKE_WL+-------------+HOST_WAKE_WL     |
| GPIO1_D5 WL_WAKE_HOST+-------------+WL_WAKE_HOST     |
|                      |             |                 |
| GPIO0_B3        RESET+-------------+RESET            |
|                      |             |                 |
| USB2_HOST2_DP    HSDP+-------------+WL_DP+           |
|         HSDM+-------------+WL_DM-           |
|             |             |                 |
|        GPIO0+-------------+GPIO0            |
|        GPIO1+-------------+GPIO1            |
|     GPIO WPS+-------------+GPIO3_WPS        |
|     GPIO LED+-------------+GPIO8_LED        |
|             |             |                 |
+-------------+             +-----------------+

```
