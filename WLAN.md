# WLAN
Debugging and analyzing WLAN devices

<br/>
<br/>
<br/>
<hr>

## Analysis Android wlan interface
 Android 는 다음을 포함하여 다양한 wifi 프로토콜 및 모드를 지원하는 default Android Framework 구현를 제공함.   
 - Wi-Fi infrastructure (STA)
 - Wi-Fi hotspot (Soft AP) in either tethered or local-only modes
 - Wi-Fi Direct (p2p)
 - Wi-Fi Aware (NAN)
 - Wi-Fi RTT (IEEE 802.11 mc FTM)

 layer 별로 설명
 - Wi-Fi services
 - Wi-Fi HALs : 3개의 Wi-FI HAL surfaces가 있음. (Vendor HAL, Supplicant HAL, Hostapd HAL)

 Android 14버전 이상에서는 AIDL 패키지로 인터페이스가 제공되고, 이전에는 HIDL 인터페이스를 사용하여 정의.  
 - Vendor HAL : AIDL 파일(hardware/interfaces/aidl), HIDL(hardware/interfaces/wifi/1.x)
 - Supplicant HAL : AIDL 파일(hardware/interfaces/supplicant/aidl), HIDL 파일(hardware/interfaces/supplicant/1.x)
 - Hostapd HAL : AIDL 파일(hardware/interfaces/hostapd/aidl), HIDL 파일(hardware/interfaces/hostapd/1.x)
 

<br/>
<br/>
<br/>
<hr>

## Debug 

<br/>
<br/>
<hr>

### iw command

iw 명령어를 사용하여 WiFi AP에 접속하는 방법.

```bash
# 무선 네트워크 인터페이스 확인
iw dev

# AP에 연결
ip link set wlan0 up

# 주변 AP 스캔
iw wlan0 scan

# AP에 연결
iw wlan0 connect myWIFI

# 보안 설정(옵션)

# IP 주소 설정(수동)
ifconfig wlan0 192.168.1.100 netmask 255.255.255.0

# 연결확인
iw wlan0 link
```

<br/>
<br/>
<hr>

### signal 검색

```bash
wlan0 scan | grep -E "SSID|signal" | sed '/SSID/!s/^/signal: /' | paste -d" " - -
```

<br/>
<br/>
<br/>
<br/>
<hr>

# Log 

```css

12-28 22:39:58.240  2203  2203 I wpa_supplicant: wlan0: CTRL-EVENT-REGDOM-CHANGE init=DRIVER type=WORLD
    +-> CTRL-EVENT-REGDOM-CHANGE : wpa_supplicant 가 무선 LAN 인터페이스 wlan0 의 지역 도메인(regulatory domain)이 변경됨을 알리고 있음. 
12-28 22:39:58.240   381   381 I wificond: 2.4Ghz frequencies: 2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467 2472
12-28 22:39:58.240   381   381 I wificond: 5Ghz non-DFS frequencies: 5180 5200 5220 5240 5745 5765 5785 5805
12-28 22:39:58.240   381   381 I wificond: 5Ghz DFS frequencies: 5260 5280 5300 5320 5500 5520 5540 5560 5580 5600 5620 5640 5660 5680 5700 5720 5825
12-28 22:39:58.240   381   381 I wificond: 6Ghz frequencies:
12-28 22:39:58.240   381   381 I wificond: 60Ghz frequencies:
    +-> wificond 가 사용가능한 주파수 대역을 나열함. 
12-28 22:39:58.260   435   553 W IE_Capabilities: Unknown RSN cipher suite: 6ac0f00
12-28 22:39:58.268   435   553 W IE_Capabilities: Unknown RSN cipher suite: 6ac0f00
12-28 22:39:58.284   435   553 W IE_Capabilities: Unknown RSN cipher suite: 6ac0f00
12-28 22:39:58.287   435   553 W IE_Capabilities: Unknown RSN cipher suite: 6ac0f00
12-28 22:39:58.305   435   553 W IE_Capabilities: Unknown RSN cipher suite: 6ac0f00
    +-> IE_Capabilities 에서 알 수 없는 RSN(Robust Security Network) 암호화 스위트가 감지됨.
        이는 지원되지 않는 암호화 방식이 사용되고 잇음을 나타냄. 
12-28 22:39:58.360   435   549 D PasspointManager: ANQP entry not found for: b0:38:6c:09:fa:5e:<danielkim>
12-28 22:39:58.362   435   549 D PasspointManager: ANQP entry not found for: 58:86:94:2c:76:06:<matterdemo>
12-28 22:39:58.367   435   549 D PasspointManager: ANQP entry not found for: c4:41:1e:bf:47:f7:<sqe-linksys5G>
12-28 22:39:58.367   435   549 D PasspointManager: ANQP entry not found for: 58:86:94:2c:76:04:<matterdemo5g>
12-28 22:39:58.371   435   549 D PasspointManager: ANQP entry not found for: 70:5d:cc:b8:40:cf:<WIKI_5G>
12-28 22:39:58.372   435   549 D PasspointManager: ANQP entry not found for: b0:38:6c:09:fa:5c:<danielkim_5G>
    +-> PasspointManager 가 특정 AP(Access Point)에 대한 ANQP(Access Network Query Protocol)항목을 찾지 못함. 
12-28 22:39:58.377   435   549 E WifiVendorHal: getWifiLinkLayerStats_1_5_Internal(l.1191) failed {.code = ERROR_UNKNOWN, .description = unknown error}
    +-> WifiVendorHal 에서 WiFi 링크레이어 통계정보를 가져오는데 실패함. 오류 코드 : ERROR_UNKNOWN
12-28 22:39:58.555   291  1982 D BufferPoolAccessor2.0: bufferpool2 0xea580c88 : 66(13214 size) total buffers - 1(220 size) used buffers - 688/2505 (recycle/alloc) - 1824/2504 (fetch/transfer)
12-28 22:39:58.621   435   435 W NotificationHistory: Attempted to add notif for locked/gone/disabled user 0
12-28 22:39:58.658   649   649 D InterruptionStateProvider: No bubble up: not allowed to bubble: 0|android|17303299|com.android.wifi|1000
12-28 22:39:58.660   649   649 D InterruptionStateProvider: No heads up: unimportant notification: 0|android|17303299|com.android.wifi|1000
12-28 22:39:58.661   649   911 D PeopleSpaceWidgetMgr: Sbn doesn't contain valid PeopleTileKey: null/0/android
12-28 22:39:58.930   291  1982 D BufferPoolAccessor2.0: bufferpool2 0xea580c88 : 66(12717 size) total buffers - 1(92 size) used buffers - 692/2526 (recycle/alloc) - 1841/2525 (fetch/transfer)
12-28 22:39:59.269   291  1982 D BufferPoolAccessor2.0: bufferpool2 0xea580c88 : 66(13773 size) total buffers - 1(273 size) used buffers - 694/2545 (recycle/alloc) - 1858/2544 (fetch/transfer)
12-28 22:39:59.608   291  1982 D BufferPoolAccessor2.0: bufferpool2 0xea580c88 : 66(23118 size) total buffers - 1(261 size) used buffers - 696/2564 (recycle/alloc) - 1875/2563 (fetch/transfer)
12-28 22:39:59.965   291  1982 D BufferPoolAccessor2.0: bufferpool2 0xea580c88 : 66(22586 size) total buffers - 1(119 size) used buffers - 699/2584 (recycle/alloc) - 1892/2583 (fetch/transfer)
12-28 22:40:00.340   291  1982 D BufferPoolAccessor2.0: bufferpool2 0xea580c88 : 66(21136 size) total buffers - 1(191 size) used buffers - 703/2605 (recycle/alloc) - 1909/2604 (fetch/transfer)
12-28 22:40:00.805   291  1982 D BufferPoolAccessor2.0: bufferpool2 0xea580c88 : 66(19859 size) total buffers - 1(314 size) used buffers - 712/2631 (recycle/alloc) - 1926/2630 (fetch/transfer)
12-28 22:40:03.950   435   753 I WifiService: startScan uid=1000
12-28 22:40:04.119     0     0 D random mac_addr: 00000000: 76 04 0f 32 7e 24                                v..2~$
12-28 22:40:04.750     0     0 W         : start_addr=(0x20000), end_addr=(0x40000), buffer_size=(0x20000), smp_number_max=(16384)
12-28 22:40:06.329     0     0 W healthd : battery l=50 v=3 t=2.6 h=2 st=3 fc=100 chg=au
12-28 22:40:09.853   435   753 D WifiNl80211Manager: Scan result ready event
12-28 22:40:09.853   435   753 D WifiNative: Scan result ready event
    +-> WiFi 스캔이 시작되고, 스캔 결과가 준비되었음을 나타냄.
12-28 22:40:09.876   435   553 W IE_Capabilities: Unknown RSN cipher suite: 6ac0f00
12-28 22:40:09.884   435   553 W IE_Capabilities: Unknown RSN cipher suite: 6ac0f00
12-28 22:40:09.903   435   553 W IE_Capabilities: Unknown RSN cipher suite: 6ac0f00
12-28 22:40:09.905   435   553 W IE_Capabilities: Unknown RSN cipher suite: 6ac0f00
12-28 22:40:09.918   435   553 W IE_Capabilities: Unknown RSN cipher suite: 6ac0f00
12-28 22:40:09.957   435   549 D PasspointManager: ANQP entry not found for: b0:38:6c:09:fa:5e:<danielkim>
12-28 22:40:09.958   435   549 D PasspointManager: ANQP entry not found for: 58:86:94:2c:76:06:<matterdemo>
12-28 22:40:09.961   435   549 D PasspointManager: ANQP entry not found for: c4:41:1e:bf:47:f7:<sqe-linksys5G>
12-28 22:40:09.962   435   549 D PasspointManager: ANQP entry not found for: 58:86:94:2c:76:04:<matterdemo5g>
12-28 22:40:09.963   435   549 D PasspointManager: ANQP entry not found for: 70:5d:cc:b8:40:cf:<WIKI_5G>
12-28 22:40:09.963   435   549 D PasspointManager: ANQP entry not found for: b0:38:6c:09:fa:5c:<danielkim_5G>
12-28 22:40:09.969   435   549 E WifiVendorHal: getWifiLinkLayerStats_1_5_Internal(l.1191) failed {.code = ERROR_UNKNOWN, .description = unknown error}

```
