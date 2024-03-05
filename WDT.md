# WATCHDOG

관련 자료 :https://gitlab.com/kdiwin/wdt_control

## 사용법

 wdt_control 명령어 실행 시, timeout 값을 22 sec으로 설정하며, 
 10 sec에 한번씩 **feed the dog** 를 수행.

```bash
[0.191] console:/ #                                                                                                                                           
console:/ # wdt_control
[1.632] timeout = 22
[0.000] feed the dog
[9.996] feed the dog
[9.996] feed the dog
[4.829] [   67.020147] healthd: battery l=50 v=3 t=2.6 h=2 st=3 fc=100 chg=au
[5.166] feed the dog
[10.012] feed the dog 
[9.996] feed the dog
[9.996] feed the dog
[9.996] feed the dog
[2.431] ^C[  114.621115] watchdog: watchdog0: watchdog did not stop!
[0.015]
[0.000] 130|console:/ # [  127.019518] healthd: battery l=50 v=3 t=2.6 h=2 st=3 fc=100
[22.421] DDR V1.18 f366f69a7d typ 23/07/17-15:48:58
[0.000] In
[0.000] LP4/4x derate en, other dram:1x trefi
[0.000] ddrconfig:0
[0.000] LP4 MR14:0x4d
[0.052] LPDDR4, 324MHz
[0.000] BW=32 Col=10 Bk=8 CS0 Row=16 CS=1 Die BW=16 Size=2048MB
[0.000] tdqss: cs0 dqs0: -24ps, dqs1: -96ps, dqs2: -72ps, dqs3: -168ps,
[0.000]                                                                                                                                                       
[0.000] change to: 324MHz
[0.000] clk skew:0x63
```

