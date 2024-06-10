# WIFI

<br/>
<br/>
<br/>
<br/>
<hr>

[Fn-Link 6222D-UUC](#fn-link-6222d-uuc)

<br/>
<br/>
<br/>
<br/>
<hr>

## Fn-Link 6222D-UUC

 FN-Link 사에서 제공하는 6222D-UUC(WiFi BT combo module) 
 **Realtek RTL8822CU** IC을 기반으로 함.

> CU : "Combo", "USB"

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
| USB2_HOST2_DM    HSDM+-------------+WL_DM-           |
|                      |             |                 |
|                 GPIO0+-------------+GPIO0            |
|                 GPIO1+-------------+GPIO1            |
|              GPIO WPS+-------------+GPIO3_WPS        |
|              GPIO LED+-------------+GPIO8_LED        |
|                      |             |                 |
+----------------------+             +-----------------+

```

<br/>
<br/>
<br/>
<br/>
<hr>

## Develop


CONFIG_RTL8822CU

 WiFi 드라이버 로딩은 wifi chip type 노드에 의존하지 않으므로, board 수준 dts 를 구성할 필요 없다.

```dts

```
