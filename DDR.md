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

```bash
adb push 

```
