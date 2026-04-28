 Android 15 (VanilaIceCream)
====

>> Android 15 SDK를 사용하여 RK3568 SoC 개발

<br/>
<br/>
<br/>
<br/>
<hr>

# Output Image

컴파일 이후 생성되는 파일 리스트.  
```bash
rockdev/Image-rk3568_u/
    +-> boot-debug.img
boot.img
config.cfg
dtbo.img
MiniLoaderAll.bin
misc.img
parameter.txt
pcba_small_misc.img
pcba_whole_misc.img


```



<br/>
<br/>
<br/>
<br/>
<hr>

# GKI 

<br/>
<br/>
<br/>
<hr>

## Download sources and build tools

```
mkdir android-kernel && cd android-kernel
repo init -u https://android.googlesource.com/kernel/manifest -b common-android14-6.1-2025-01
repo sync
```

<br/>
<br/>
<br/>
<br/>
<hr>

# Develop with dlkm strucutre

<br/>
<br/>
<br/>
<hr>

## mkcombinedroot

 Rockchip 전용 이미지 툴. 
 GKI 환경에서 vendor_boot.img 를 재패키징 하는 도구. 

<br/>
<br/>
<hr>

### 역할 
```
1. kernel 에서 .ko 생성
2. .ko를 mkcombinedroot로 복사
3. 기존 vendor_boot.img 복사 
4. mkgki4.sh 실행 -> ko 추가해서 vendor_boot.img 재생성.
5. flash
```

> 👉 driver를 kernel에 넣는 게 아니라 .ko로 분리해야 해서 사용된 기법? 

<br/>
<br/>
<hr>

### 내부 역할

```
// KO 파일 관리
mkcombinedroot/vendor_ramdisk/lib/modules/
// 로딩 순서 관리
mkcombinedroot/res/vendor_modules.load
mkcombinedroot/res/vendor_ramdisk_modules.load
```

<br/>
<br/>
<hr>

### code tree

```
mkcombinedroot$ tree 
.
├── bin
│   ├── blk_alloc_to_base_fs
│   ├── build_image
│   ├── depmod
│   ├── e2fsdroid
│   ├── minigzip
│   ├── mkbootfs
│   ├── mkbootimg
│   ├── mke2fs
│   ├── mke2fs.conf
│   ├── mkf2fsuserimg.sh
│   ├── mkuserimg_mke2fs
│   ├── repack_bootimg
│   ├── simg2img
│   └── unpack_bootimg
├── copy_moduls.sh
├── lib64
│   ├── libbase.so
│   ├── libc++.so
│   ├── libcutils.so
│   ├── libext4_utils.so
│   ├── liblog.so
│   └── libz.so
├── mkgki4.sh
├── modular_kernel.mk
├── patches
│   └── system_tools_mkbootimg.diff
├── prebuilts    // Google boot.img path
│   └── boot-6.1.img
├── README
├── recovery_modules.load
├── res
│   ├── bootconfig
│   ├── debug_list.load
│   ├── file_contexts.bin
│   ├── ramdisk_modules.load
│   ├── recovery_gki.mk
│   ├── system_gki.mk
│   ├── vendor_gki.mk
│   ├── vendor_image_info.txt
│   ├── vendor_modules.load
│   ├── vendor_ramdisk_gki.mk
│   └── vendor_ramdisk_modules.load
├── tools
│   ├── DepSort.java
│   ├── gki_load_check.sh
│   └── search_3.sh
├── vendor_boot.img
└── vendor_ramdisk
    └── first_stage_ramdisk
        └── fstab.rk30board

8 directories, 43 files
```
  
 - copy_modules.sh 
   * vendor/_ramdisk/lib/modules : 

<br/>
<br/>
<br/>
<br/>
<hr>

# repo management

```bash
Normal download steps
Create new project folder.
$ mkdir nova; cd nova
Initialize repo project with specifiying the url of this repository.
$ repo init -u ssh://git@git.kdiwin.com:7999/hnnov/nova-manifests -m target/rk3576_v.xml
Synchronize repositories (-j option can be used in specifying count of jobs)
$ repo sync
```

 legacy structure
```bash
target/rk3576_v.xml
    |
    +-> aosp/android-15.0.9_r9.xml
    +-> socs/a15_rkr3.xml
    +-> nova/nova_device.xml
    +-> nova/nova_device_rockchip.xml
    +-> nova/nova_vendor.xml
```

 new structure
```bash
target/rk3576_v_rkr4.xml
target/rk3568_v_rkr4.xml
    |
    +-> target/android_v_rkr4.xml
        |
        +-> aosp/android-15.0.0_r17.xml    // revision이 r9 에서 업데이트
        +-> aosp/a15_rkr4.xml              // revision이 rkr3 에서 업데이트
        +-> nova/nova_device.xml
        +-> nova/nova_device_rockchip.xml
        +-> nova/nova_vendor.xml
```


<br/>
<br/>
<br/>
<br/>
<hr/>

# Note

<br/>
<br/>
<br/>
<hr>

## rkr3 vs rkr4 
 
 아래 tag 에서 파생되었음.  
 - rkr4 : android-15.0.0_r17
 - rkr3 : android-15.0.0_r9

<br/>
<br/>
<br/>
<hr>

## build rk3576_evb

```bash
lunch rk3576_u-ap4a-userdebug
```

<br/>
<br/>
<br/>
<hr>

## Android build chain

 Product Chain : 무엇을 넣을 지 결정. (AndroidProduct.mk, rk3568_evb)   
 BoardConfig Chain : 어떻게 빌드할지 결정. (rk3568_evb.mk, device.mk, vendor.mk)   
 AndroidBoard Chain : 어떤 산출물을 어떻게 생성할지 규칙 정의. (device.mk, device_v.mk)  

 1. Product Chain
   - lunch 대상과 실제 product 파일을 연결.  
   - PRODCUT_NAME, MODEL, BRAND 같은 제품 정체성을 기술.  
  
 2. BoardConfig Chain
   - 제품 공통 구성와 벤더 전용 구성. 
   - system/vendor 로 들어갈 패키지, property, copy file 정책을 구성.  


 3. AndroidBoard Chain 
   - PLATFORM_SDK_VERSION 에 따라 버전별 설정파일을 선택  


<br/>
<br/>
<br/>
<hr>

## build bootimage with GKI

make bootimage → boot.img
make vendorbootimage → vendor_boot.img
make initbootimage → init_boot.img

 - GKI 관련 이미지 설명

 1) boot.img
  - 핵심 커널 부팅 이미지
  - GKI에선 이전보다 역할이 단순해져서 "generi kernel + 최소 부팅 정보" 
  - 이전 처럼 벤더별 Ramdisk 를 넣는 구조는 줄어들었음

 2) init_boot.img
  - Android 13+ 추가된 파티션.
  - generic ramdisk(초기 init 환경) 이 저장되어 있음. 
  - 즉, 초기 부팅 공통 ramdisk 를 boot에서 분리한 개념. 

 3) vendor_boot.img
  - SoC/보드 벤더 의존 부팅 구성(벤더 ramdisk, DTB/부트 설정 일부)정보가 저장
  - GKI에서 벤더 커스텀 부팅 요소가 저장되어있음
  - 결과적으로 공통 커널(boot) 과 벤더 의존부(vendor_boot)가 분리

 4) A/B 슬롯
  - 무중단 업데이트(seamless Update)를 의한 이중 슬롯 구조. 
  - 예: boot_a/boot_b, vendor_boot_a/vendor_boot_b, init_boot_a/init_boot_b
  - 현재 실행 중인 슬롯과 다음 부팅 슬롯을 번갈아 관리해 OTA 실패 복구가 쉬워짐. 

 5) Header v4
  - Android 최신 부트 이미지 포맷 버전
  - GKI/분리된 ramdisk 구조(init_boot, vendor_boot)와 함께 동작

 6) Vendor Ramdisk
 - 벤더 전용 초기 사용자 공간 파일 집합
 - 드라이버 초기화, 벤더 init.rc, 펌웨어 로딩 경로 등 보드 종속 초기 부팅 로직이 포함
 -


<br/>
<br/>
<br/>
<hr>

## Android15 Command Strucuture

1. 진입점 : lunch rk3568_evb-ap4a-userdebug
Android 빌드 시스템이 아래 순서로 파일 로딩

```
device/kdiwin/nova/rk3568_evb/AndroidProducts.mk
  → PRODUCT_MAKEFILES = rk3568_evb.mk
  → COMMON_LUNCH_CHOICES = rk3568_evb-ap4a-userdebug

device/kdiwin/nova/rk3568_evb/BoardConfig.mk     ← Board 변수 설정
device/kdiwin/nova/rk3568_evb/AndroidBoard.mk    ← make rule 정의
device/kdiwin/nova/rk3568_evb/rk3568_evb.mk     ← Product 변수 설정
```

2. Board 변수 체인(컴파일 조건 결정)
BoardConfig.mk -> config.mk -> config_v.mk 순서로 include
```
BoardConfig.mk (rk3568_evb/)
  BOARD_BUILD_GKI := true
  BOARD_BOOT_HEADER_VERSION := 4
  include device/kdiwin/nova/rk3568/config.mk
    ├─ ifeq SDK_VERSION==35 → include config_v.mk
    │     include device/kdiwin/nova/common/config.mk (NOVA 공통 변수)
    │     include device/rockchip/rk356x/BoardConfig.mk (Rockchip 공통 Board 설정)
    │     PRODUCT_BOOT_DEVICE := fe2b0000.dwmmc  ← 부팅 장치 override
    │     TARGET_KERNEL_VERSION := 6.1
    │     TARGET_KERNEL_DEFCONFIG := gki_defconfig
    │     ...
    └─ TARGET_KERNEL_CONFIGS += pcie_wifi.config  (rk3568_evb 전용 추가)
```

3. Product 변수 체인(이미지 빌드 내용 결정)
rk3568_evb.mk -> device.mk -> device_v.mk 순서.

```
rk3568_evb.mk
  PRODUCT_DTBO_TEMPLATE := $(LOCAL_PATH)/dt-overlay.in  ← dtbo 생성 입력
  BOARD_BUILD_GKI := true
  inherit-product device/kdiwin/nova/rk3568/device.mk
    ├─ ifeq SDK_VERSION==35 → inherit device_v.mk
    │     PRODUCT_DTBO_TEMPLATE := dt-overlay.v.in
    │     PRODUCT_SDMMC_DEVICE := fe2b0000.dwmmc
    │     include DynamicPartitions.mk
    │     include config.mk (→ config_v.mk, Board 변수도 여기서 추가 로딩)
    │     include device/rockchip/common/BoardConfig.mk
    │     inherit device/kdiwin/nova/common/device.mk
    │     inherit device/rockchip/rk356x/device.mk
    │     inherit device/rockchip/common/device.mk
  PRODUCT_NAME := rk3568_evb
  PRODUCT_DEVICE := rk3568_evb
  NOVA_DISPLAY_* 변수들
```

4. Make Rule 체인 (실제 빌드 동작 결정)
AndroidBoard.mk -> board.mk 순서

```
AndroidBoard.mk (rk3568_evb/)
  └─ include device/kdiwin/nova/rk3568/board.mk
       ├─ include RebuildFstab.mk    → fstab.rk30board 자동 생성
       ├─ include RebuildDtboImg.mk  → PRODUCT_DTBO_TEMPLATE으로 rebuild-dtbo.img 생성
       ├─ include RebuildParameter.mk → parameter.txt 자동 생성
       ├─ include uboot.mk           → uboot 빌드 rule
       ├─ include kernel.mk          → 커널 빌드 rule
       ├─ rockdev: rule              → mkimage.sh 호출 (이미지 스테이징)
       └─ pack: rule                 → update.img 생성
```

<br/>
<br/>
<br/>
<hr>

## dirty kernel

```
git clean -fdx 
```
