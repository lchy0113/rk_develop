# NETWORK

-----

> network command 관련 정리.

## network tool

### ip command

```bash
 ip
Usage: ip [ OPTIONS ] OBJECT { COMMAND | help }
       ip [ -force ] -batch filename
where  OBJECT := { link | address | addrlabel | route | rule | neigh | ntable |
                   tunnel | tuntap | maddress | mroute | mrule | monitor | xfrm |
                   netns | l2tp | fou | macsec | tcp_metrics | token | netconf | ila |
                   vrf | sr }
       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |
                    -h[uman-readable] | -iec |
                    -f[amily] { inet | inet6 | ipx | dnet | mpls | bridge | link } |
                    -4 | -6 | -I | -D | -B | -0 |
                    -l[oops] { maximum-addr-flush-attempts } | -br[ief] |
                    -o[neline] | -t[imestamp] | -ts[hort] | -b[atch] [filename] |
                    -rc[vbuf] [size] | -n[etns] name | -a[ll] | -c[olor]}

```

 - ip link 명령어
 linux에서 네트워크 인터페이스의 세부 정보를 확인.   
 네트워크 인터페이스의 상태, 링크속도, MAC주소, MTU(maximum transmission unit) 확인. 


```bash
$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eno2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 04:d4:c4:e0:c7:77 brd ff:ff:ff:ff:ff:ff
    altname enp3s0
3: wlo1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DORMANT group default qlen 1000
    link/ether dc:71:96:f7:cc:13 brd ff:ff:ff:ff:ff:ff
    altname wlp0s20f3
4: br-78b810c32733: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
    link/ether 02:42:72:1c:e6:27 brd ff:ff:ff:ff:ff:ff
5: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default
    link/ether 02:42:8c:23:1c:ca brd ff:ff:ff:ff:ff:ff
7: vetha5e4fab@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-78b810c32733 state UP mode DEFAULT group default
    link/ether 76:f8:61:64:20:c3 brd ff:ff:ff:ff:ff:ff link-netnsid 0

```

 - ip address 명령어
 linux 에서 네트워크 인터페이스의 세부 정보를 확인하고 관리.  

```bash
// ip 주소 할당 및 제거 
$ ip address add 172.16.0.13/8 dev eth0
$ ip address del 172.16.0.13/8 dev eth0

```


 - ip route 명령어 
 linux에서 네트워크 라우팅 정보를 확인하고, 관리.   
 추가/삭제 가능  
```bash
// routing table 출력
$ ip route
default via 192.168.0.1 dev eno2 proto dhcp metric 100
default via 172.16.0.1 dev wlo1 proto static metric 20600
169.254.0.0/16 dev wlo1 scope link metric 1000
172.16.0.0/24 dev wlo1 proto kernel scope link src 172.16.0.7 metric 600
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown
172.22.0.0/16 dev br-78b810c32733 proto kernel scope link src 172.22.0.1
192.168.0.0/24 dev eno2 proto kernel scope link src 192.168.0.12 metric 100


// route 추가(기본 게이트웨이 설정)
$ ip route add default via 172.16.0.1 dev eth0
// 특정 네트워크의 라우팅 정보 추가
$ ip route add 172.16.0.0/8 via 172.16.0.1 dev eth0
// 라우팅 정보 삭제
$ ip route del default via 172.16.0.1 dev eth0
```



## rockchip platform

```bash
/ 단일 네트워크 인터페이스 정보 출력
$ ip addr show dev eth0

```

### rockchip ethernet device


```basg
/sys/devices/platform/fe2a0000.ethernet
```


###  rockchip phy register read/write

 드라이버는 레지스터를 읽고 쓰기 위한 인터페이스를 제공.  
 현재 서로 다른 커널 버전에는 두 가지 인터페이스 세트가 있다.  
 경로: /sys/bus/mdio_bus/devices/stmmac-0:00, 여기서 stmmac-0:00은 PHY 주소가 0임을 의미.

```bash
// write, ex. reg0에 0xabcd 값 을write
echo 0x00 0xabcd > /sys/bus/mdio_bus/devices/stmmac-0:00/phy_registers


// read
cat /sys/bus/mdio_bus/devices/stmmac-0\:00/phy_registers                                                                                                     <
 0: 0x3100
 1: 0x786d
 2: 0x1c
 3: 0xc816
 4: 0x1e1
 5: 0x4de1
 6: 0x5
 7: 0x0
 8: 0x0
 9: 0x0
10: 0x0
11: 0x0
12: 0x0
13: 0x0
14: 0x0
15: 0x0
16: 0x31f
17: 0x1f10
18: 0x12
19: 0xde21
20: 0x3e3e
21: 0x2c5
22: 0x5b85
23: 0x1
24: 0x8310
25: 0x0
26: 0x4000
27: 0x4fcf
28: 0x40c6
29: 0x8888
30: 0x10
31: 0x0

// 0~31 까지의 레지스터의 값을 덤프.

```



### mac 주소
 
  - 우선 순위로 DTB에 있는 MAC 주소 값을 사용.(uboot에서도 이를 사용)  
  - IDB에 저장된 주소가 유효한 값인 경우 기록된 MAC 주소를 사용  
  - 저장된 MAC주소가 없는경우, 랜덤으로 사용.

### RGMII Delayline
 RGMII 타이밍을 조정하기 위해 tx/rx delayline을 세팅할수있다. 
