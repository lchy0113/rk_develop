# PARTITION

=====

## super 파티션이란?

Android 12에서는 **동적 파티션 (Dynamic Partitions)**이 도입되었습니다. 이는 기기의 저장 공간을 효율적으로 관리하고 업데이트를 용이하게 하기 위한 기술입니다. 이를 구현하기 위해 super 파티션이 사용됩니다.

*Super 파티션*

Super 파티션은 각 동적 파티션의 이름과 블록 범위가 나열된 메타데이터를 포함합니다.
이 메타데이터는 파싱되고 검증되며 각 동적 파티션을 나타내는 가상 블록 기기가 생성됩니다.
OTA 업데이트 시 동적 파티션이 필요에 따라 자동으로 생성, 크기 조정 및 삭제됩니다.
A/B 기기의 경우 두 가지 메타데이터 사본이 있으며 변경사항은 대상 슬롯을 나타내는 사본에만 적용됩니다.

파티션 크기 설정:

super 파티션의 크기를 설정해야 합니다.
A/B 기기의 경우 동적 파티션 이미지의 총 크기가 super 파티션 크기의 절반을 초과하지 않도록 해야 합니다.
파티션 정렬:

super 파티션은 블록 레이어에서 결정된 최소 I/O 요청 크기에 맞게 정렬되어야 합니다.
정렬 오프셋은 0이어야 합니다.

 - reference : https://source.android.com/docs/core/ota/dynamic_partitions/implement?hl=ko


<br/>
-----

## 디바이스 파티션 정보

```bash
brw------- 1 root   root   179,   0 2017-08-04 18:00 /dev/block/mmcblk2
brw------- 1 root   root   179,  32 2017-08-04 18:00 /dev/block/mmcblk2boot0
brw------- 1 root   root   179,  64 2017-08-04 18:00 /dev/block/mmcblk2boot1
brw------- 1 root   root   179,   1 2017-08-04 18:00 /dev/block/mmcblk2p1
brw------- 1 root   root   179,  10 2017-08-04 18:00 /dev/block/mmcblk2p10
brw------- 1 root   root   179,  11 2017-08-04 18:00 /dev/block/mmcblk2p11
brw-rw---- 1 system system 179,  12 2017-08-04 18:00 /dev/block/mmcblk2p12
brw------- 1 root   root   179,  13 2017-08-04 18:00 /dev/block/mmcblk2p13
brw------- 1 root   root   179,  14 2017-08-04 18:00 /dev/block/mmcblk2p14
brw------- 1 root   root   179,   2 2017-08-04 18:00 /dev/block/mmcblk2p2
brw------- 1 root   root   179,   3 2017-08-04 18:00 /dev/block/mmcblk2p3
brw------- 1 root   root   179,   4 2017-08-04 18:00 /dev/block/mmcblk2p4
brw------- 1 root   root   179,   5 2017-08-04 18:00 /dev/block/mmcblk2p5
brw------- 1 root   root   179,   6 2017-08-04 18:00 /dev/block/mmcblk2p6
brw------- 1 root   root   179,   7 2017-08-04 18:00 /dev/block/mmcblk2p7
brw------- 1 root   root   179,   8 2017-08-04 18:00 /dev/block/mmcblk2p8
brw------- 1 root   root   179,   9 2017-08-04 18:00 /dev/block/mmcblk2p9
```
  
 - bootloader 에 의해 요구되는 파티션을 제외하고는 동적 파티션으로 관리.  
   
| index |         device        |  name(mapper) | filesystem | size in 512-byte sectors(MB) |
|:-----:|:---------------------:|:-------------:|:----------:|:----------------------------:|
| 1     | /dev/block/mmcblk2p1  | security      | raw        | 8192(4MB)                    |
| 2     | /dev/block/mmcblk2p2  | uboot         | raw        | 8192(4MB)                    |
| 3     | /dev/block/mmcblk2p3  | trust         | raw        | 8192(4MB)                    |
| 4     | /dev/block/mmcblk2p4  | misc          | raw        | 8192(4MB)                    |
| 5     | /dev/block/mmcblk2p5  | dtbo          | raw        | 8192(4MB)                    |
| 6     | /dev/block/mmcblk2p6  | vbmeta        | raw        | 2048(1MB)                    |
| 7     | /dev/block/mmcblk2p7  | boot          | raw        | 81920(40MB)                  |
| 8     | /dev/block/mmcblk2p8  | recovery      | raw        | 196608(96MB)                 |
| 9     | /dev/block/mmcblk2p9  | backup        | raw        | 786432(384MB)                |
| 10    | /dev/block/mmcblk2p10 | cache         |            | 786432(384MB)                |
| 11    | /dev/block/mmcblk2p11 | metadata      |            | 32768(16MB)                  |
| 12    | /dev/block/mmcblk2p12 | baseparameter |            | 2048(1MB)                    |
| 13    | /dev/block/mmcblk2p13 | super         |            | 6373376(3112MB)              |
|       | /dev/block/dm-0       | (/system)     | ext4       | (logical)                    |
|       | /dev/block/dm-1       | (system_ext)  | ext4       | (logical)                    |
|       | /dev/block/dm-2       | (vendor)      | ext4       | (logical)                    |
|       | /dev/block/dm-3       | (vendor_dlkm) | ext4       | (logical)                    |
|       | /dev/block/dm-4       | (odm)         | ext4       | (logical)                    |
|       | /dev/block/dm-5       | (odm_dlkm)    | ext4       | (logical)                    |
|       | /dev/block/dm-6       | (product)     | ext4       | (logical)                    |
|       | /dev/block/dm-7       | (mnt/scratch) | f2fs       | (logical)                    |
|       | /dev/block/dm-8       | (data)        | f2fs       | (logical)                    |
| 14    | /dev/block/mmcblk2p14 | userdata      | f2fs       | (total)-(super partition)    | 


## logical partition

 - 기기 매퍼 저장 기기 정의

```bash
rk3568_edpp02:/vendor # getprop | grep dev.mnt.blk
[dev.mnt.blk.data]: [dm-8]
[dev.mnt.blk.data.user.0]: [dm-8]
[dev.mnt.blk.data_mirror.cur_profiles]: [dm-8]
[dev.mnt.blk.data_mirror.data_ce.null]: [dm-8]
[dev.mnt.blk.data_mirror.data_ce.null.0]: [dm-8]
[dev.mnt.blk.data_mirror.data_de.null]: [dm-8]
[dev.mnt.blk.data_mirror.ref_profiles]: [dm-8]
[dev.mnt.blk.mnt.scratch]: [dm-7]
[dev.mnt.blk.odm]: [dm-4]
[dev.mnt.blk.odm_dlkm]: [dm-5]
[dev.mnt.blk.product]: [dm-6]
[dev.mnt.blk.root]: [dm-0]
[dev.mnt.blk.system_ext]: [dm-1]
[dev.mnt.blk.vendor]: [dm-2]
[dev.mnt.blk.vendor_dlkm]: [dm-3]
```


 - logical partition 관리

| **partition-size info**                          | **partition-name** | **is-logical** | **length ** | **size(B)** | **size(MB)** |
|--------------------------------------------------|--------------------|----------------|-------------|-------------|--------------|
| (bootloader) partition-size:system:0x3B28D000    | dm(0)system        | (logical)      | 0x3b28d000  |   992530432 |       946.55 |
| (bootloader) partition-size:system_ext:0x91E2000 | dm(1)system_ext    | (logical)      | 0x091e2000  |   152969216 |       145.88 |
| (bootloader) partition-size:vendor:0x135F4000    | dm(2)vendor        | (logical)      | 0x135f4000  |   325009408 |       309.95 |
| (bootloader) partition-size:vendor_dlkm:0x16F000 | dm(3)vendor_dlkm   | (logical)      | 0x0016f000  |     1503232 |         1.43 |
| (bootloader) partition-size:odm_dlkm:0x40000     | dm(5)odm_dlkm      | (logical)      | 0x00040000  |      262144 |         0.25 |
| (bootloader) partition-size:product:0xEED7000    | dm(6)product       | (logical)      | 0x0eed7000  |   250441728 |       238.84 |


