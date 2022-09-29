# DDR 

## DDR Verification 과정 

DDR 메모리에 대한 검증에 대한 내용을 설명합니다.

### 조건 

1. 32 bit 또는 64 bit ARM 아키텍처 타겟으로 합니다.
2. 타겟 장치의 total ddr memory size 를 타겟으로 합니다.
3. ddr frequency 가 고정된 상태인 경우, 최대 frequency 로 세팅해야 합니다.

### 준비 과정 

1. test 파일 복사 

  [memtester test](./attachment/DDR/ddr_test_tools/ddr_particle_verification_test_resource/static_memtester/)    
  [stress test](./attachment/DDR/ddr_test_tools/ddr_particle_verification_test_resource/static_stressapptest/)   
  [ddr_freq_scan.sh](./attachment/DDR/ddr_test_tools/ddr_particle_verification_test_resource/linux4.xx_ddr_test_files/ddr_freq_scan.sh)

  memtester : https://github.com/jnavila/memtester  
  stressapptest : https://github.com/stressapptest

```bash
$ adb push memtester_64bit /data/memtester
$ adb push stressapptest_64bit /data/stressapptest
$ adb push ddr_freq_scan.sh /data/ddr_freq_scan.sh

$ adb shell chmod 0777 /data/memtester
$ adb shell chmod 0777 /data/stressapptest
$ adb shell chmod 0777 /data/ddr_freq_scan.sh

```


2. wake lock 세팅

 wake_lock 을 활성화 하여, 항상 켜짐 상태를 유지 합니다.
```bash
$ adb shell echo 1 > /sys/power/wake_lock
```


### Verify DDR Capacity

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

### DDR Frequency Test

su 권한으로 동작합니다.

- fix DDR frequency

```bash
// run 1560 MHz
$ /data/ddr_freq_scan.sh 1560000000

// run 928 MHz
$ /data/ddr_freq_scan.sh 933000000
```

- 결과 확인

```bash
// 로그 예제
rk3568_poc:/ # /data/ddr_freq_scan.sh 933000000
DMC_PATH:/sys/class/devfreq/dmc
already change to 1560000000Hz done.
change frequency to available max frequency done.

rk3568_poc:/ # /data/ddr_freq_scan.sh 800000000
DMC_PATH:/sys/class/devfreq/dmc
already change to 1560000000Hz done.
change frequency to available max frequency done.

rk3568_poc:/ # /data/ddr_freq_scan.sh 1560000000
DMC_PATH:/sys/class/devfreq/dmc
already change to 1560000000Hz done.
change frequency to available max frequency done.
```

### DDR google stressapptest test 

su 권한으로 동작합니다.
시간을 정하여 시험을 진행합니다.

- stressapptest 

```bash
// total capacity is 2GB, apply 256 MB for stressapptest. 10초
rk3568_poc:/ # /data/stressapptest -s 10 -i 4 -C 4 -W --stop_on_errors -M 128
2022/09/22-13:22:10(UTC) Log: Commandline - /data/stressapptest -s 10 -i 4 -C 4 -W --stop_on_errors -M 128
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
rk3568_poc:/# /data/stressapptest -s 43200 -i 4 -C 4 -W --stop_on_errors -M 512
(...)
```
- 결과 확인

테스트가 종료되면 stressapptest 의 결과를 통해 PASS 또는 FAIL 인지 확인 할 수 있습니다.
실패인 경우, Status: FAIL 이 노출됩니다.
stressapptest 는 10초마다 로그를 출력하고, 로그는 남은 테스트 시간을 표시 합니다.

### memtester test 

su 권한으로 동작합니다.
시험 시간을 12시간 이상 입니다.

- memtester test

```bash
// total capacity is 2GB, apply 256 MB for memtester

130|rk3568_poc:/ # /data/memtester 256m
memtester version 4.3.0_20200721 (32-bit)
Copyright (C) 2001-2012 Charles Cazabon.
Licensed under the GNU General Public License version 2 (only).

pagesize is 4096
pagesizemask is 0xfffffffffffff000
want 256MB (268435456 bytes)
got  256MB (268435456 bytes), trying mlock ...locked.
testing from phyaddress:0xe2e8000
no available chip info, using default maping
Loop 1:
  Stuck Address       : setting   3^C
  *************************************************************
  memtester result:
  Log: had found 0 failures.

  Status: PASS.

  *************************************************************
  rk3568_poc:/ #
```

- 결과 확인

memtester 도중 오류가 발견되면 중지됩니다. 
memtester 시험이 12 시간 이상 실행되면 memtester에서 오류가 발견되지 않았다는 결과를 노출합니다.

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

### DDR Frequency Scaling

su 권한으로 동작합니다.
시험 시간은 12시간 이상 소요되며, 로그를 통해 scaling이 동작 되는지 확인 할 수 있습니다.

- DDR Frequency Scaling 

```bash
130|rk3568_poc:/ # /data/ddr_freq_scan.sh
DMC_PATH:/sys/class/devfreq/dmc
available_frequencies:
324000000
528000000
780000000
1560000000
DDR freq will change to 528000000 0
already change to 1560000000 done
DDR freq will change to 1560000000 1
already change to 1560000000 done
DDR freq will change to 780000000 2
already change to 1560000000 done
DDR freq will change to 1560000000 3
(...)
```

### Reboot Test
(작성 예정)

### Sleep Test
(작성 예정)



-----

reference : 
https://intrepidgeeks.com/tutorial/stressappst-user-guide 
