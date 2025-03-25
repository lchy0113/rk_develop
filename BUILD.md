# BUILD


Rockchip rk3568의 build.sh에 의해 생성된 파일은 아래와 같습니다. 

```bash
▾ Image-rk3568_r/
    baseparameter.img*
    boot-debug.img*
    boot.img*
    config.cfg*
    dtbo.img*
    MiniLoaderAll.bin*
    misc.img*
    parameter.txt*
    pcba_small_misc.img*
    pcba_whole_misc.img*
    recovery.img*
    resource.img*
    super.img*
    uboot.img*
    vbmeta.img*
```

<br/>
<br/>
<br/>
<hr>

## dtbo.img

```bash
// dtbo image
BOARD_DTBO_IMG=$OUT/rebuild-dtbo.img
cp -a $BOARD_DTBO_IMG $IMAGE_PATH/dtbo.img
```

<br/>
<br/>
<hr>

### dtbo.img 생성 과정. 

```bash
ifdef PRODUCT_DTBO_TEMPLATE // PRODUCT_DTBO_TEMPLATE 이 정의된 경우, (device/rockchip/common/build/rockchip/RebuildDtboImg.mk)
|
+->	PRODUCT_DTBO_TEMPLATE := $(LOCAL_PATH)/dt-overlay.in // (device/rockchip/rk356x/rk3568_s/rk3568_s.mk)
|											|
|											+-> device/rockchip/rk356x/rk3568_s/dt-overlay.in
|												/dts-v1/;
|												/plugin/;
|
|												&chosen {
|													bootargs_ext = "androidboot.boot_devices=${_boot_device}";
|												};
|												
|												&reboot_mode {
|													mode-bootloader = <0x5242C309>;
|													mode-charge = <0x5242C30B>;
|													mode-fastboot = <0x5242C303>;
|													mode-loader = <0x5242C301>;
|													mode-normal = <0x5242C300>;
|													mode-recovery = <0x5242C303>;
|												};
|
+-> out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/device-tree-overlay.dts
|	|
|	+->	
|
+-> out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/rebuild-dtbo.img
	|
	| recipe : rebuild_dts AOSP_DTC_TOOL AOSP_MKDTIMG_TOOL
	+-> out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/device-tree-overlay.dts
	|	| recipe : ROCKCHIP_FSTAB_TOOLS PRODUCT_DTBO_TEMPLATE
	|	+-> out/soong/host/linux-x86/bin/fstab_tools -I dts -i device/rockchip/rk356x/rk3568_s/dt-overlay.in \
	|		-p fe310000.sdhci,fe330000.nandc -f wait -o rockdev/richgold/device-tree-overlay.dts
	|
	+-> $ out/soong/host/linux-x86/bin/dtc -O dtb \
	|	-o out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/device-dtbo.dtb \
	|	out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/device-tree-overlay.dts 
	|
	+-> $ out/soong/host/linux-x86/bin/mkdtimg	\
		create out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/rebuild-dtbo.img \
		out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/device-dtbo.dtb
```
 * fstab_tools
 	: fstab generator script
 	```bash
 	$ fstab_tools -h
 	fstab_generator.py -I <type: fstab/dts> -i <fstab_template> -p <block_prefix> -d <dynamic_part_list> -f <flags> -c <chained_flags> -s <sdmmc_device> -o <output_file>
 	```
 * dtc 
 : devicetree compiler 
 * mkdtimg
 : https://source.android.com/devices/architecture/dto/partitions?hl=ko#mkdtimg 

<br/>
<br/>
<br/>
<hr>

## parameter.txt

 README(device/rockchip/common/scripts/parameter_tools/README)에 의하면 parameter_tools에 의해 생성됩니다.
 device/rockchip/common/build/rockchip/RebuildParameter.mk 에 Makefile 정의 되어 있습니다.
```bash
$(rebuild_parameter) : $(PRODUCT_PARAMETER_TEMPLATE) $(ROCKCHIP_PARAMETER_TOOLS)
	@echo "Building parameter.txt $@."
	$(ROCKCHIP_PARAMETER_TOOLS) --input $(PRODUCT_PARAMETER_TEMPLATE) \
	--start-offset 8192 \
	--firmware-version $(BOARD_PLATFORM_VERSION) \
	--machine-model $(PRODUCT_MODEL) \
	--manufacturer $(PRODUCT_MANUFACTURER) \
	--machine $(PRODUCT_DEVICE) \
	--partition-list $(partition_list) \
	--output $(rebuild_parameter)


/*
sample
parameter_tools --input device/rockchip/common/scripts/parameter_tools/parameter.in \
	--firmware-version 12.0 \
	--machine-model rk3568_s \
	--manufacturer rockchip \
	--machine rk3568_s \
	--partition-list security:4M,uboot:4M,trust:4M,misc:4M,dtbo:8M,vbmeta:1M,boot:20M,recovery:64M,backup:384M,cache:384M,metadata:16M,super:3112M \
	--output out/target/product/rk3568_s/obj/FAKE/rockchip_parameter_intermediates/parameter.txt
*/
```

<br/>
<br/>
<br/>
<hr>

## 기타 이미지

```bash
// resource image
copy_images $KERNEL_PATH/resource.img $IMAGE_PATH/resource.img
// boot.img
copy_images_from_out boot.img
copy_images_from_out boot-debug.img
copy_images_from_out vendor_boot.img
copy_images_from_out vendor_boot-debug.img

// recovery image
copy_images_from_out recovery.img

// super image
copy_images_from_out super.img

/ userdata image
copy_images $OUT/userdata.img $IMAGE_PATH/data.img

// vbmeta image
cp -a device/rockchip/common/vbmeta.img $IMAGE_PATH/vbmeta.img

// misc image
cp -a rkst/Image/misc.img $IMAGE_PATH/misc.img


// u-boot image
cp -a $UBOOT_PATH/uboot.img $IMAGE_PATH/uboot.img

// miniloader image
cp -a $UBOOT_PATH/*_loader_*.bin $IMAGE_PATH/MiniLoaderAll.bin

// config image
cp -a ./rk356x/rk3568_s/config.cfg $IMAGE_PATH/config.cfg


// parameter image
cp -a $OUT/parameter.txt $IMAGE_PATH/parameter.txt


// baseparameter image
cp -a device/rockchip/common/baseparameter/v2.0/baseparameter.img $IMAGE_PATH/baseparameter.img
```

<br/>
<br/>
<br/>
<hr>

## update.img 이미지 생성

$ make -j32 rockdev
$ cd RKTools/linux/Linux_Pack_Firmware/rockdev
$ ./mkupdate.sh rk356x ../../../../rockdev/Image-rk3568_poc/

- TO DO LIST


- DONE LIST
 * SOONG_OST_OUT_EXECUTABLES := out/soong/host/linux-x86/bin
  android 이미지 빌드에 필요한 binary 저장 경로.
 * intermediates := out/target/product/rk3568_r/obj/FAKE/rockchip_dtbo_intermediates
  dtbo 관련 intermediates 이미지. 

<br/>
<br/>
<br/>
<br/>
<hr>

# build error 디버깅

<br/>
<br/>
<br/>
<hr>

## submodule error

아래 에러 발생시, submodule초기화

```bash
make 

(...)

fatal: Needed a single revision
```

<br/>
<br/>
<br/>
<br/>
<hr>

# Device configuration: include vs inherit-product
> Android 오픈소스 프로젝트에서 device/ 디렉토리에서 사용되는 include와 inherit 문법에 대해 정리

<br/>
<br/>
<br/>
<hr>

## include 문법

 다른 Makefile 을 현재 위치에 불러와서 포함 한다는 의미

```make
include $(CLEAR_VARS)
```

|            **명령어**           |                        **설명**                       |
|:-------------------------------:|:-----------------------------------------------------:|
| include $(CLEAR_VARS)           | 모든 로컬 변수 초기화 (새 모듈 정의할 때 항상 시작점) |
| include $(BUILD_PREBUILT)       | prebuilt binary (이미 빌드된 파일) 등록               |
| include $(BUILD_EXECUTABLE)     | 실행 가능한 바이너리 등록                             |
| include $(BUILD_SHARED_LIBRARY) | 공유 라이브러리 등록                                  |

```make
include $(CLEAR_VARS)

LOCAL_MODULE := richgold
LOCAL_SRC_FILES := richgold.c

include $(BUILD_EXECUTABLE)
```

<br/>
<br/>
<br/>
<hr>

## inherit-product (또는 inherit) 문법

 다른 Device 설정 파일(.mk)을 상속해서 재사용하겠다는 의미

 - 자주 사용되는 파일
   * device.mk
   * product.mk
   * device/<vendor>/<product>/이하 .mk파일


## example

 - 디렉토리 tree

```bash
device/
+-> myvendor/
    +-> mydevice/
        +-> Android.mk
        +-> BoardConfig.mk
        +-> device.mk
        +-> product.mk
        +-> init.mydevice.rc
```

 - Android.mk : 모듈 등록

```make
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)                    // 이전 모듈 설정 초기화
LOCAL_MODULE := init.mydevice.rc         // 등록할 모듈 이름
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT)/etc
LOCAL_SRC_FILES := init.mydevice.rc
include $(BUILD_PREBUILT)                // 실제 바이너리가 아닌 파일을 시스템 이미지에 복사
```

 - BoardConfig.mk : 보드/하드웨어 관련 설정

```make
// BOARD_ 로 시작하는 변수는 하드웨어 설정에 관련된 값
// 이 값들은 build/core/Makefile에서 참조되어 boot.img, recovery.img 등을 생성할때 참조

BOARD_KERNEL_CMDLINE := console=ttyS0,115200
BOARD_KERNEL_BASE := 0x10000000
BOARD_BOOTIMG_HEADER_VERSION := 2
```

 - device.mk : 기기 전용 설정

```make
// 시스템 이미지에 복사할 파일 지정
PRODUCT_COPY_FILES += \
    device/myvendor/mydevice/init.mydevice.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.mydevice.rc

// 함께 빌드할 PACKAGES 등록
PRODUCT_PACKAGES += \
    mydevice-app

// 다른 공통 설정 파일 포함(공통적으로 여러 기기에서 재사용 가능)
# 다른 설정을 포함 (여기서 include 사용)
include device/myvendor/common/common_settings.mk
```

 - product.mk : 제품 전체 구성 

```make
PRODUCT_NAME := mydevice
PRODUCT_DEVICE := mydevice
PRODUCT_BRAND := mybrand
PRODUCT_MODEL := My Device

// Android 에서 제공하는 기분 제품 구성 full_base.mk 상속
# 핵심: 제품 설정 상속
inherit-product $(SRC_TARGET_DIR)/product/full_base.mk

// 해당 기기의 구체적인 설정 include
# 이 기기의 설정 포함
include device/myvendor/mydevice/device.mk
```

 - 전체 연결 흐름

```make
product.mk
  └─ inherit-product (core/base 설정 상속)
    └─ include device.mk
       └─ include common_settings.mk
Android.mk → 개별 파일/모듈 정의
BoardConfig.mk → 부트 이미지 및 커널 관련 설정

```


<br/>
<br/>
<br/>
<br/>
<hr>

# refactoring build solution

<br/>
<br/>
<br/>
<hr>

## 250325

rk3568
 - login shell script
   
newjeans
 - base
   - configs
   - etc
   - media (boot logo)
     : 통합.
   - modules 
    : 디렉토리 추가. (camera, lights, pstn, sensors, touch)
     * camera: feature xml파일 복사
     * lights: feature xml파일 복사
     * pstn: feature xml파일 복사
     * sensors: feature xml파일 복사 
     * touch(keypad로 변경 예정): touchpad.kcm, outchpad.km 파일 복사(Key Character Map, Key Layout)
     * wireless: xml 파일복사, init.rc 파일복사, kconfig 파일 복사 (bluetooth 분리 필요).
   - overlays 
     * common : android resource overlay 제공
     * guard
     * lobby
     * wallpad
     * wallpad_lotte
   - pio_hal: gpio_hal 
   - config.mk: build device에 대한 설정
     * logo file: define.mk 에 선언된 변수들을 사용하여 파일 지정
   - define.mk: device base 정의(NOVA_BUILD_FLAVOR, NOVA_PRODUCT_TYPE, NOVA_BI_LOGO_TYPE, NOVA_MODULE_KCONFIGS)
   - device.mk: overlay 및 proverty, bootanimation scale등 정의. 
   - vendor.mk: NOVA_PRODUCT_TYPE 별 PACKAGE 추가 및 device를 위한 아래 PACKAGE 추가
     * fonts: font file(otf) 복사 
     * prebuilt: prebuilt apk 용도 
     * package:
     * wall: WallService, wall PACKAGE 추가
     * WallTest: WallTest PACKAGE 추가
     * loginshell: loginshell PACKAGE 추가
     * kdu: kdu DEBUG_PACKAGE 추가

