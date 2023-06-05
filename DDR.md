# DDR verification

> DDR 메모리 대한 검증에 대한 내용을 설명합니다.

## 1. 조건 

- 32 bit 또는 64 bit ARM 아키텍처 타겟으로 합니다.
- 타겟 장치의 total ddr memory size 를 타겟으로 합니다.
- ddr frequency 가 고정된 상태인 경우, 최대 frequency 로 세팅해야 합니다.

-----

## 2. 준비 과정 

- test 파일 다운로드
	
  * [stress test](./attachment/DDR/ddr_test_tools/ddr_particle_verification_test_resource/static_stressapptest/)   
 	 *stressapptest* : https://github.com/stressapptest
  * [memtester test](./attachment/DDR/ddr_test_tools/ddr_particle_verification_test_resource/static_memtester/)    
	  *memtester* : https://pyropus.ca./software/memtester/, https://github.com/jnavila/memtester  
  * [ddr_freq_scan.sh](./attachment/DDR/ddr_test_tools/ddr_particle_verification_test_resource/linux4.xx_ddr_test_files/ddr_freq_scan.sh)



```bash
$ adb push memtester_64bit /data/local/tmp/memtester
$ adb push stressapptest_64bit /data/local/tmp/stressapptest
$ adb push ddr_freq_scan.sh /data/local/tmp/ddr_freq_scan.sh

$ adb shell chmod 0777 /data/local/tmp/memtester
$ adb shell chmod 0777 /data/local/tmp/stressapptest
$ adb shell chmod 0777 /data/local/tmp/ddr_freq_scan.sh

```


- wake lock 세팅
 wake_lock 을 활성화 하여, 항상 켜짐 상태를 유지 합니다.

```bash
$ adb shell echo 1 > /sys/power/wake_lock
```

-----

## 3. Verification


### 3.1 Verify DDR Capacity

타겟 보드의 MemTotal capacity는 아래 명령어를 통해 확인 할 수 있습니다.

> 시스템 메모리 할당 관리의 차이로 인해 약간의 편차는 정상입니다.

```bash
rk3568_poc:/ # cat /proc/meminfo
MemTotal:        2004320 kB
MemFree:          844620 kB
MemAvailable:    1293360 kB
Buffers:            2732 kB
Cached:           559976 kB
SwapCached:        23748 kB
Active:           230712 kB
Inactive:         447716 kB
Active(anon):     160552 kB
Inactive(anon):    74840 kB
Active(file):      70160 kB
Inactive(file):   372876 kB
Unevictable:      118532 kB
Mlocked:          116132 kB
SwapTotal:       1002156 kB
SwapFree:         787656 kB
Dirty:                48 kB
Writeback:             0 kB
AnonPages:        229900 kB
Mapped:           289504 kB
Shmem:              4492 kB
KReclaimable:      51856 kB
Slab:              99940 kB
SReclaimable:      39496 kB
SUnreclaim:        60444 kB
KernelStack:       14048 kB
PageTables:        27928 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     2004316 kB
Committed_AS:   22212320 kB
VmallocTotal:   263061440 kB
VmallocUsed:       26576 kB
VmallocChunk:          0 kB
Percpu:             3616 kB
CmaTotal:           8192 kB
CmaAllocated:        372 kB
CmaReleased:        7820 kB
CmaFree:               0 kB
```



### 3.2 DDR stress test 

su 권한으로 동작합니다.  

- stressapptest : stressful application test 이름이며, (stressapptest, Unix 이름) 메모리 인터페이스 테스트 툴 입니다. 프로세서 및 I/O 에서 random 트래픽을 생성하여 고부하 상황을 만들어 메모리를 시험합니다. 


```bash
// total capacity is 2GB, apply 256 MB for stressapptest. 10초
rk3568_poc:/ # /data/local/tmp/stressapptest -s 10 -i 4 -C 4 -W --stop_on_errors -M 128
2022/09/22-13:22:10(UTC) Log: Commandline - /data/local/tmp/stressapptest -s 10 -i 4 -C 4 -W --stop_on_errors -M 128
2022/09/22-13:22:10(UTC) Stats: SAT revision 1.0.7_autoconf, 64 bit binary
2022/09/22-13:22:10(UTC) Log: cym @ HP on Thu Jan 16 10:30:56 CST 2020 from open source release
2022/09/22-13:22:10(UTC) Log: 1 nodes, 4 cpus.
2022/09/22-13:22:10(UTC) Log: Defaulting to 4 copy threads
2022/09/22-13:22:10(UTC) Log: Prefer plain malloc memory allocation.
2022/09/22-13:22:10(UTC) Log: Using mmap() allocation at 0x7d6824a000.
2022/09/22-13:22:10(UTC) Stats: Starting SAT, 128M, 10 seconds
2022/09/22-13:22:10(UTC) Log: region number 1 exceeds region count 1
2022/09/22-13:22:10(UTC) Log: Region mask: 0x1
2022/09/22-13:22:23(UTC) Stats: Found 0 hardware incidents
2022/09/22-13:22:23(UTC) Stats: Completed: 26902.00M in 12.58s 2138.04MB/s, with 0 hardware incidents, 0 errors
2022/09/22-13:22:23(UTC) Stats: Memory Copy: 13886.00M at 1387.88MB/s
2022/09/22-13:22:23(UTC) Stats: File Copy: 0.00M at 0.00MB/s
2022/09/22-13:22:23(UTC) Stats: Net Copy: 0.00M at 0.00MB/s
2022/09/22-13:22:23(UTC) Stats: Data Check: 0.00M at 0.00MB/s
2022/09/22-13:22:23(UTC) Stats: Invert Data: 13016.00M at 1300.67MB/s
2022/09/22-13:22:23(UTC) Stats: Disk: 0.00M at 0.00MB/s
2022/09/22-13:22:23(UTC)
2022/09/22-13:22:23(UTC) Status: PASS - please verify no corrected errors
2022/09/22-13:22:23(UTC)
rk3568_poc:/ #

// total capacity is 2GB, apply 256 MB for stressapptest. 12시간 
rk3568_poc:/# /data/local/tmp/stressapptest -s 43200 -i 4 -C 4 -W --stop_on_errors -M 512
(...)

2022/09/23-01:46:31(UTC) Log: Seconds remaining: 90
2022/09/23-01:46:41(UTC) Log: Seconds remaining: 80
2022/09/23-01:46:51(UTC) Log: Seconds remaining: 70
2022/09/23-01:47:01(UTC) Log: Seconds remaining: 60
2022/09/23-01:47:11(UTC) Log: Seconds remaining: 50
2022/09/23-01:47:21(UTC) Log: Seconds remaining: 40
2022/09/23-01:47:31(UTC) Log: Seconds remaining: 30
2022/09/23-01:47:41(UTC) Log: Seconds remaining: 20
2022/09/23-01:47:51(UTC) Log: Seconds remaining: 10
2022/09/23-01:48:04(UTC) Stats: Found 0 hardware incidents
2022/09/23-01:48:04(UTC) Stats: Completed: 117827448.00M in 43202.96s 2727.30MB/s, with 0 hardware incidents, 0 errors
2022/09/23-01:48:04(UTC) Stats: Memory Copy: 61011528.00M at 1412.30MB/s
2022/09/23-01:48:04(UTC) Stats: File Copy: 0.00M at 0.00MB/s
2022/09/23-01:48:04(UTC) Stats: Net Copy: 0.00M at 0.00MB/s
2022/09/23-01:48:04(UTC) Stats: Data Check: 0.00M at 0.00MB/s
2022/09/23-01:48:04(UTC) Stats: Invert Data: 56815920.00M at 1315.18MB/s
2022/09/23-01:48:04(UTC) Stats: Disk: 0.00M at 0.00MB/s
2022/09/23-01:48:04(UTC)
2022/09/23-01:48:04(UTC) Status: PASS - please verify no corrected errors
2022/09/23-01:48:04(UTC)

```
- 결과 확인

테스트가 종료되면 stressapptest 의 결과를 통해 PASS 또는 FAIL 인지 확인 할 수 있습니다.  
실패인 경우, Status: FAIL 이 노출됩니다.  
stressapptest 는 10초마다 로그를 출력하고, 로그는 남은 테스트 시간을 표시 합니다.  


-----


### 3.3 memtester test 

su 권한으로 동작합니다.  

- memtester test : 메모리 서브시스템의 결합 여부를 시험하는 툴 입니다.

```bash
// help
Usage: ./memtester [-p physaddrbase [-d device]] [-e exit_when_error][-t test_pattern] [-c chip name]<mem>[B|K|M|G] [loops]
-p  testing phys address
-e  if not 0, exit immediately when test fail
-t  testing pattern mask, if null or 0 enable all test pattern
       bit0: Random Value
       bit1: Compare XOR
       bit2: Compare SUB
       bit3: Compare MUL
       bit4: Compare DIV
       bit5: Compare OR
       bit6: Compare AND
       bit7: Sequential Increment
       bit8: Solid Bits
       bit9: Block Sequential
       bit10: Checkerboard
       bit11: Bit Spread
       bit12: Bit Flip
       bit13: Walking Ones
       bit14: Walking Zeroes
       bit15: 8-bit Writes
       bit16: 16-bit Writes
       example: -t 0x1000,enable Bit Flip only

// total capacity is 2GB, apply 512 MB for memtester
rk3568_poc:/data/local/tmp # ./memtester 512M 1
memtester version 4.3.0_20200721 (32-bit)
Copyright (C) 2001-2012 Charles Cazabon.
Licensed under the GNU General Public License version 2 (only).

pagesize is 4096
pagesizemask is 0xfffffffffffff000
want 512MB (536870912 bytes)
got  512MB (536870912 bytes), trying mlock ...locked.
testing from phyaddress:0x319da000
no available chip info, using default maping
Loop 1/1:
  Stuck Address       : ok
  Random Value        : ok
  Compare XOR         : ok
  Compare SUB         : ok
  Compare MUL         : ok
  Compare DIV         : ok
  Compare OR          : ok
  Compare AND         : ok
  Sequential Increment: ok
  Solid Bits          : ok
  Block Sequential    : ok
  Checkerboard        : ok
  Bit Spread          : ok
  Bit Flip            : ok
  Walking Ones        : ok
  Walking Zeroes      : ok
  8-bit Writes        : ok
  16-bit Writes       : ok


*************************************************************
memtester result:
Log: had found 0 failures.

Status: PASS.

*************************************************************
rk3568_poc:/data/local/tmp #

```

- 결과 확인

memtester 도중 오류가 발견되면 중지됩니다.   
memtester 시험이 12 시간 이상 소요되며.  memtester에서 오류가 발견되지 않았다는 결과를 출력합니다.   

```bash
// 예제 입니다.
Loop 10:
Stuck Address: ok
Random Value: ok
Compare XOR: ok
Compare SUB: ok
Compare MUL: ok
Compare DIV: ok
Compare OR: ok
Compare AND: ok
Sequential Increment: ok
Solid Bits: ok
Block Sequential: ok
Checkerboard: ok
Bit Spread: ok
Bit Flip: ok
Walking Ones: ok
Walking Zeroes: ok

// 만약 에러가 발생되는 경우 아래와 같습니다.
FAILURE: 0xffffffff != 0xffffbfff at offset 0x03b7d9e4.
EXIT_FAIL_OTHERTEST

```


-----


### DDR Frequency Test
(작성 예정)


-----

reference : 
https://intrepidgeeks.com/tutorial/stressappst-user-guide 



-----

# DDR Log

```bash
[2023-06-05 10:41:43.466] DDR Version V1.13 20220218		// ddr 초기화 코드 버전 정보, ddr initialzation code 시작.
[2023-06-05 10:41:43.466] In
							SRX		// SRX가 출력되는 경우, hot restart 의미. SRX가 출력되지 않은경우, cold boot 을 의미(일부 칩만 지원)
[2023-06-05 10:41:43.523] ddrconfig:0
[2023-06-05 10:41:43.523] LP4 MR14:0x4d
[2023-06-05 10:41:43.523] LPDDR4, 324MHz
[2023-06-05 10:41:43.523] BW=32 Col=10 Bk=8 CS0 Row=16 CS=1 Die BW=16 Size=2048MB
[2023-06-05 10:41:43.523] tdqss: cs0 dqs0: 361ps, dqs1: 289ps, dqs2: 289ps, dqs3: 217ps, 
[2023-06-05 10:41:43.523] 
[2023-06-05 10:41:43.523] change to: 324MHz
[2023-06-05 10:41:43.523] PHY drv:clk:38,ca:38,DQ:30,odt:0
[2023-06-05 10:41:43.523] vrefinner:41%, vrefout:41%
[2023-06-05 10:41:43.523] dram drv:40,odt:0
[2023-06-05 10:41:43.524] clk skew:0x58
[2023-06-05 10:41:43.524] 
[2023-06-05 10:41:43.524] change to: 528MHz
[2023-06-05 10:41:43.524] PHY drv:clk:38,ca:38,DQ:30,odt:0
[2023-06-05 10:41:43.524] vrefinner:41%, vrefout:41%
[2023-06-05 10:41:43.524] dram drv:40,odt:0
[2023-06-05 10:41:43.524] clk skew:0x7a
[2023-06-05 10:41:43.524] 
[2023-06-05 10:41:43.524] change to: 780MHz
[2023-06-05 10:41:43.524] PHY drv:clk:38,ca:38,DQ:30,odt:0
[2023-06-05 10:41:43.524] vrefinner:41%, vrefout:41%
[2023-06-05 10:41:43.524] dram drv:40,odt:0
[2023-06-05 10:41:43.577] clk skew:0x5f
[2023-06-05 10:41:43.577] 
[2023-06-05 10:41:43.577] change to: 1560MHz(final freq)
[2023-06-05 10:41:43.577] PHY drv:clk:38,ca:38,DQ:30,odt:60
[2023-06-05 10:41:43.577] vrefinner:16%, vrefout:29%
[2023-06-05 10:41:43.577] dram drv:40,odt:80
[2023-06-05 10:41:43.577] vref_ca:00000068
[2023-06-05 10:41:43.577] clk skew:0xd
[2023-06-05 10:41:43.577] cs 0:
[2023-06-05 10:41:43.577] the read training result:
[2023-06-05 10:41:43.578] DQS0:0x2f, DQS1:0x2f, DQS2:0x34, DQS3:0x32, 
[2023-06-05 10:41:43.578] min  : 0xd  0xc 0x10  0xd  0x3  0x6  0xa  0x6 , 0xc  0x7  0x2  0x3 0x12  0xd  0xf  0xa ,
[2023-06-05 10:41:43.578]        0xf  0xf  0xb  0xa  0x5  0x1  0x1  0x3 , 0xc  0x8  0x7  0x1 0x13 0x13 0x10 0x11 ,
[2023-06-05 10:41:43.578] mid  :0x26 0x26 0x29 0x26 0x1d 0x20 0x23 0x1f ,0x23 0x1f 0x1b 0x1c 0x29 0x26 0x28 0x22 ,
[2023-06-05 10:41:43.629]       0x28 0x29 0x25 0x23 0x1e 0x1b 0x1b 0x1d ,0x26 0x22 0x21 0x1b 0x2d 0x2c 0x2a 0x2b ,
[2023-06-05 10:41:43.629] max  :0x3f 0x40 0x42 0x3f 0x37 0x3b 0x3d 0x38 ,0x3b 0x38 0x34 0x36 0x41 0x3f 0x42 0x3b ,
[2023-06-05 10:41:43.629]       0x42 0x44 0x3f 0x3c 0x38 0x36 0x36 0x38 ,0x41 0x3c 0x3b 0x36 0x47 0x46 0x45 0x46 ,
[2023-06-05 10:41:43.630] range:0x32 0x34 0x32 0x32 0x34 0x35 0x33 0x32 ,0x2f 0x31 0x32 0x33 0x2f 0x32 0x33 0x31 ,
[2023-06-05 10:41:43.630]       0x33 0x35 0x34 0x32 0x33 0x35 0x35 0x35 ,0x35 0x34 0x34 0x35 0x34 0x33 0x35 0x35 ,
[2023-06-05 10:41:43.630] the write training result:
[2023-06-05 10:41:43.681] DQS0:0x55, DQS1:0x46, DQS2:0x46, DQS3:0x38, 
[2023-06-05 10:41:43.681] min  :0x99 0x9d 0x9f 0x9b 0x90 0x92 0x96 0x97 0x94 ,0x89 0x88 0x83 0x83 0x8f 0x8d 0x8d 0x8c 0x85 ,
[2023-06-05 10:41:43.682]       0x90 0x92 0x89 0x88 0x83 0x7e 0x80 0x85 0x85 ,0x7e 0x7d 0x79 0x75 0x84 0x85 0x83 0x88 0x79 ,
[2023-06-05 10:41:43.682] mid  :0xb6 0xb8 0xbb 0xb6 0xaa 0xad 0xb1 0xb1 0xae ,0xa5 0xa2 0x9b 0x9c 0xa9 0xa6 0xa7 0xa5 0x9f ,
[2023-06-05 10:41:43.682]       0xab 0xad 0xa3 0xa2 0x9c 0x98 0x9a 0x9f 0xa0 ,0x9b 0x98 0x94 0x90 0x9f 0xa1 0x9d 0xa2 0x95 ,
[2023-06-05 10:41:43.682] max  :0xd3 0xd4 0xd7 0xd1 0xc4 0xc8 0xcd 0xcc 0xc9 ,0xc1 0xbd 0xb3 0xb6 0xc4 0xbf 0xc2 0xbe 0xb9 ,
[2023-06-05 10:41:43.734]       0xc7 0xc8 0xbd 0xbd 0xb6 0xb3 0xb4 0xba 0xbb ,0xb9 0xb3 0xb0 0xac 0xbb 0xbd 0xb8 0xbd 0xb1 ,
[2023-06-05 10:41:43.734] range:0x3a 0x37 0x38 0x36 0x34 0x36 0x37 0x35 0x35 ,0x38 0x35 0x30 0x33 0x35 0x32 0x35 0x32 0x34 ,
[2023-06-05 10:41:43.734]       0x37 0x36 0x34 0x35 0x33 0x35 0x34 0x35 0x36 ,0x3b 0x36 0x37 0x37 0x37 0x38 0x35 0x35 0x38 ,
[2023-06-05 10:41:43.734] CA Training result:
[2023-06-05 10:41:43.735] cs:0 min  :0x4d 0x41 0x46 0x39 0x43 0x37 0x4a ,0x51 0x41 0x4b 0x3c 0x45 0x37 0x4c ,
[2023-06-05 10:41:43.735] cs:0 mid  :0x85 0x84 0x7e 0x79 0x7b 0x77 0x73 ,0x88 0x84 0x80 0x7d 0x7d 0x7a 0x77 ,
[2023-06-05 10:41:43.769] cs:0 max  :0xbd 0xc8 0xb7 0xba 0xb4 0xb8 0x9c ,0xbf 0xc7 0xb6 0xbe 0xb6 0xbd 0xa2 ,
[2023-06-05 10:41:43.770] cs:0 range:0x70 0x87 0x71 0x81 0x71 0x81 0x52 ,0x6e 0x86 0x6b 0x82 0x71 0x86 0x56 ,
[2023-06-05 10:41:43.771] out	// ddr initialize code 종료를 의미
[2023-06-05 10:41:43.785] U-Boot SPL board init
[2023-06-05 10:41:43.801] U-Boot SPL 2017.09-gaaca6ffec1-211203 #zzz (Dec 03 2021 - 18:42:16)
[20
```



## rk3568 support ECC

- RK3568은 ECC를 지원합니다. DDR ECC DQ0-7에 연결된 component가 있으면 loader가 자동으로 ECC 기능을 활성화합니다.
- ECC Byte의 DRAM은 DQ0-31의 component와 동일한 row/bank/col을 가져야 합니다.


## selection of rk356x ddr frequency

- rk356x platform Loader의 경우, frequency 를 4 times 변경되고, 해당 frequency 의 traning result가 저장된다. 
- kernel에서 dmc에 의해 할당된 4개의 frequcncy 값은 loader의 freuqncy pin과 일치해야한다.  
  rk356x loader의 경우, 3가지 default frequency point 는 324M, 528M, 780M 이다. 
  가장 높은 frequency point는 rk3568_ddr_1560MHz_vxx.bin과 같은 ddr bin 으로 적용한다. 
  또한 loader 의 frequency point 적용도 debug console을 통해 확인 가능하다. 
  debug console 로그에서 xxxMHz으로 변경이 4번 반복되어 정보를 출력한다. 
- loader 의 frequency 는 rkbin directory 의 tools/ddrbin_tool을 통해 변경가능하다. 
  예를 들어 rk3568에서 가장 높은 frequency 를 1332M으로 변경해야 하는경우, RKBOOT/RK3568MINIALL.ini의 Path1 및 FrashData가 가리키는 ddr bin 을 rkbin 프로젝트 directory의  1332M으로 변경해야 하며, 
  dts의 frequency point는  324M으로 변경된다. 




## ddr DQ : eye diagram tool 

> DDR DQ : DDR SDRAM의 data line이다. 

 - ddr_dq_eye 의 qoroqustn <DDR frequency in MHz> 는 DQ eye diagram에서 확인해야하는 ddr clock frequency 이다. 
   * default 가장 높은 frequency 선택됨.
 - 아래와 같이 명령을 입력 

```bash
[2023-06-05 16:35:03.064] FIT: No FIT image
[2023-06-05 16:35:03.064]
[2023-06-05 16:35:03.064] ## Booting Rockchip Format Image
[2023-06-05 16:35:03.064] Could not find kernel partition, ret=-1
[2023-06-05 16:35:03.064] => ddr_dq_eye
[2023-06-05 16:35:07.411] Rockchip DDR DQ Eye Tool v0.0.6
[2023-06-05 16:35:07.411] DDR type: LPDDR4
[2023-06-05 16:35:07.412] CS0 1560MHz read DQ eye:
[2023-06-05 16:35:07.412]      0   8   16  24  32  40  48  56  64  72  80  88  96  104 112 120  Margin_L Sample Margin_R Width    DQS
[2023-06-05 16:35:07.413] DQ0  -----*************|*************--------------------------------    26      37      26      53      47
[2023-06-05 16:35:07.414] DQ1  ------*************|*************-------------------------------    26      38      27      54      47
[2023-06-05 16:35:07.415] DQ2  --------************|*************------------------------------    25      41      26      52      47
[2023-06-05 16:35:07.454] DQ3  ------*************|*************-------------------------------    26      38      26      53      47
[2023-06-05 16:35:07.455] DQ4  -*************|*************------------------------------------    26      28      27      54      47
[2023-06-05 16:35:07.455] DQ5  --**************|*************----------------------------------    27      32      27      55      47
[2023-06-05 16:35:07.456] DQ6  -----************|*************---------------------------------    25      35      26      52      47
[2023-06-05 16:35:07.457] DQ7  --*************|*************-----------------------------------    25      30      26      52      47
[2023-06-05 16:35:07.497] DQ8  -----************|************----------------------------------    24      35      24      49      48
[2023-06-05 16:35:07.498] DQ9  ---*************|*************----------------------------------    25      32      26      52      48
[2023-06-05 16:35:07.498] DQ10 *************|**************------------------------------------    26      27      27      54      48
[2023-06-05 16:35:07.499] DQ11 -*************|*************------------------------------------    26      29      26      53      48
[2023-06-05 16:35:07.540] DQ12 --------************|*************------------------------------    25      41      25      51      48
[2023-06-05 16:35:07.540] DQ13 ------*************|*************-------------------------------    25      38      26      52      48
[2023-06-05 16:35:07.541] DQ14 -------*************|*************------------------------------    26      41      26      53      48
[2023-06-05 16:35:07.541] DQ15 ----*************|************----------------------------------    25      34      25      51      48
[2023-06-05 16:35:07.542] DQ16 --------*************|*************-----------------------------    25      42      26      52      53
[2023-06-05 16:35:07.583] DQ17 --------*************|**************----------------------------    27      43      27      55      53
[2023-06-05 16:35:07.584] DQ18 ------*************|*************-------------------------------    26      38      26      53      53
[2023-06-05 16:35:07.584] DQ19 ------************|************---------------------------------    24      36      25      50      53
[2023-06-05 16:35:07.584] DQ20 --*************|*************-----------------------------------    26      31      26      53      53
[2023-06-05 16:35:07.585] DQ21 -*************|**************-----------------------------------    27      29      27      55      53
[2023-06-05 16:35:07.626] DQ22 -*************|*************------------------------------------    26      28      27      54      53
[2023-06-05 16:35:07.627] DQ23 --*************|**************----------------------------------    26      31      27      54      53
[2023-06-05 16:35:07.627] DQ24 ------*************|**************------------------------------    26      39      27      54      51
[2023-06-05 16:35:07.627] DQ25 ----*************|*************---------------------------------    26      34      27      54      51
[2023-06-05 16:35:07.669] DQ26 ----*************|*************---------------------------------    26      34      27      54      51
[2023-06-05 16:35:07.669] DQ27 -*************|**************-----------------------------------    27      29      27      55      51
[2023-06-05 16:35:07.670] DQ28 ---------*************|*************----------------------------    26      45      26      53      51
[2023-06-05 16:35:07.670] DQ29 ---------*************|*************----------------------------    26      45      26      53      51
[2023-06-05 16:35:07.670] DQ30 --------*************|**************----------------------------    27      43      27      55      51
[2023-06-05 16:35:07.712] DQ31 --------**************|*************----------------------------    27      44      27      55      51
[2023-06-05 16:35:07.713]
[2023-06-05 16:35:07.713] CS0 1560MHz write DQ eye:
[2023-06-05 16:35:07.713]      101 109 117 125 133 141 149 157 165 173 181 189 197 205 213 221  Margin_L Sample Margin_R Width    DQS
[2023-06-05 16:35:07.713] DQ0  --------------------------**************|***************--------    28     181      29      58      85
[2023-06-05 16:35:07.713] DQ1  ----------------------------**************|*************--------    27     184      27      55      85
[2023-06-05 16:35:07.755] DQ2  -----------------------------**************|**************------    28     186      29      58      85
[2023-06-05 16:35:07.755] DQ3  --------------------------**************|**************---------    27     180      28      56      85
[2023-06-05 16:35:07.756] DQ4  ---------------------*************|*************----------------    26     169      26      53      85
[2023-06-05 16:35:07.756] DQ5  -----------------------*************|*************--------------    26     172      27      54      85
[2023-06-05 16:35:07.798] DQ6  ------------------------**************|**************-----------    28     177      28      57      85
[2023-06-05 16:35:07.798] DQ7  -------------------------*************|**************-----------    27     177      27      55      85
[2023-06-05 16:35:07.799] DQ8  ------------------**************|**************-----------------    28     165      28      57      70
[2023-06-05 16:35:07.799] DQ9  ------------------*************|*************-------------------    26     162      27      54      70
[2023-06-05 16:35:07.799] DQ10 ---------------************|************------------------------    24     154      25      50      70
[2023-06-05 16:35:07.841] DQ11 ---------------*************|************-----------------------    25     156      25      51      70
[2023-06-05 16:35:07.841] DQ12 ---------------------*************|*************----------------    26     169      26      53      70
[2023-06-05 16:35:07.842] DQ13 --------------------************|************-------------------    24     164      25      50      70
[2023-06-05 16:35:07.842] DQ14 --------------------*************|*************-----------------    26     167      26      53      70
[2023-06-05 16:35:07.842] DQ15 --------------------************|*************------------------    25     165      25      51      70
[2023-06-05 16:35:07.884] DQ16 ---------------------**************|**************--------------    28     171      28      57      70
[2023-06-05 16:35:07.885] DQ17 ----------------------**************|*************--------------    27     172      27      55      70
[2023-06-05 16:35:07.885] DQ18 ------------------*************|*************-------------------    26     163      26      53      70
[2023-06-05 16:35:07.886] DQ19 ------------------*************|*************-------------------    26     162      27      54      70
[2023-06-05 16:35:07.927] DQ20 ---------------*************|*************----------------------    26     156      26      53      70
[2023-06-05 16:35:07.927] DQ21 -------------*************|*************------------------------    26     152      27      54      70
[2023-06-05 16:35:07.928] DQ22 --------------************|*************------------------------    25     153      26      52      70
[2023-06-05 16:35:07.928] DQ23 ----------------*************|*************---------------------    26     159      26      53      70
[2023-06-05 16:35:07.929] DQ24 -------------**************|***************---------------------    29     155      30      60      56
[2023-06-05 16:35:07.970] DQ25 ------------**************|*************------------------------    27     152      27      55      56
[2023-06-05 16:35:07.971] DQ26 ----------**************|*************--------------------------    27     148      27      55      56
[2023-06-05 16:35:07.971] DQ27 --------**************|**************---------------------------    28     144      28      57      56
[2023-06-05 16:35:07.971] DQ28 ---------------**************|*************---------------------    27     158      27      55      56
[2023-06-05 16:35:08.023] DQ29 ----------------**************|**************-------------------    27     160      28      56      56
[2023-06-05 16:35:08.023] DQ30 ---------------*************|**************---------------------    27     157      27      55      56
[2023-06-05 16:35:08.023] DQ31 ------------------*************|*************-------------------    26     162      27      54      56
[2023-06-05 16:35:08.024]
[2023-06-05 16:35:08.024] DQ eye width min: 49(read), 50(write)
[2023-06-05 16:35:08.024] DQ eye width reference: 25(read), 24(write) in 1560MHz
```


### 출력 분석
 - tool version, ddr type, frequency 및 기타 정보를 출력함.
 - CS의 read eye diagram과 write eye diagram을 각각 출력함.
 - 출력된 diagram에서 각 기호의 의미는 아래와 같음.
   * "-" 표시의 위치는 eye diagram 외부.
   * "*" 표시의 위치는 eye diagram 내부.
   * "|" 표시의 위치는 sampling point.
 - eye diagram 그래프의 오른쪽 사이드에는 margin(Margin_L, Margin_R; sampling width), sampling point  정보를 출력한다.
 - tool은 eye diagram을 읽어 eye diagram을 작성하기 위한 최소 eye width, width limit value을 작성할 수 있도록 한다.

#### eye diagram
 - eye diagram은 ddr sdram의 데이터 신호를 시각적으로 표현한 것.     
 - eye diagram을 데이터 신호의 진폭,위상,시간 오차 등을 나타낸다.
 - eye diagram을 통해 ddr sdram 데이터 신호의 품질을 평가할 수 있다.
 - eye diagram은 데이터 신호의 진폭이 클수록, 위상이 정확할 수록, 시간 오차가 적을 수록 품질이 좋다. 
 - eye diagram의 품질이 좋지 않으면 ddr sdram 데이터 신호가 유실되거나 오류가 발생할 수 있다.

#### ddr dq mininum eye width limitation
 - read, write eye width of DDR DQ에 대한 최소 값.
   * minimum read, write eye width 을 충족하지 못한 경우, DDR operation 이 불안해 짐. 
 - DDR DQ mininum read, wrtie eye width를 충족한다는 것은 현재 DDR DQ eye width이 상대적으로 안정적이라는 의미이며, 설계에 다른 문제가 없다는 의미는 아님.

| **DDR type** 	| **DDR clock frequency** 	| **minimum reading  eye width limit value** 	| **minimum write  eye width limit value** 	|
|:------------:	|:-----------------------:	|:------------------------------------------:	|:----------------------------------------:	|
| _LPDDR4_     	| _1560MHz_               	| 25                                         	| 24                                       	|
| _LPDDR4_     	| _1184MHz_               	| 30                                         	| 29                                       	|
| _DDR4_       	| _1560MHz_               	| 30                                         	| 22                                       	|
| _DDR4_       	| _1184MHz_               	| 32                                         	| 26                                       	|
| _LPDDR3_     	| _1184MHz_               	| 34                                         	| 25                                       	|
| _LPDDR3_     	| _1056MHz_               	| 39                                         	| 28                                       	|
| _DDR3_       	| _1184MHz_               	| 32                                         	| 31                                       	|
| _DDR3_       	| _1056MHz_               	| 39                                         	| 34                                       	|
