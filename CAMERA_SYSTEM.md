CAMERA_SYSTEM 
=====


<br/>
<br/>
<br/>
<br/>
<hr>

# Analyse

<br/>
<br/>
<br/>
<hr>

## Build Code

> 사용되는 package 확인 필요

```bash
/hardware/rockchip/camera$ tree -L 1
.
├── AAL                   // 프레임워크와의 상호작용을 담당하는 Android 추상화 계층
├── Android.bp
├── Android.mk
├── Camera3HALModule.cpp
├── common                // 스레드, 메시지 처리, 로그 인쇄 등과 같은 일반적인 파일
├── COPYING
├── etc                   // 구성 파일 디렉토리
├── include               // 제어 루프 헤더 파일, buffer_manager 관련 헤더 파일
├── lib                   // 3a 엔진 관련 라이브러리
├── psl                   // 물리 계층, 물리적 구현 계층, 모든 구현 논리는 기본적으로 여기에 있습니다.
├── tools
└── VERSION

7 directories, 5 files
```

hardware/rockchip/camera/etc/camera_etc.mk
```bash
# sdk version
PLATFORM_SDK_VERSION = 32  (Android12L, API Level 32)


# camera hal : hardware hal path
 $(TOP)/hardware/rockchip/camera/etc


PRODUCT_COPY_FILES += \
    $(CUR_PATH)/camera/camera3_profiles_$(TARGET_BOARD_PLATFORM).xml:$(TARGET_COPY_OUT_SYSTEM)/etc/camera/camera3_profiles.xml \
    $(call find-copy-subdir-files,*,$(CUR_PATH)/firmware,$(TARGET_COPY_OUT_SYSTEM)/etc/firmware) \
    $(call find-copy-subdir-files,*,$(CUR_PATH)/camera,$(TARGET_COPY_OUT_SYSTEM)/etc/camera) \
    $(call find-copy-subdir-files,*,$(CUR_PATH)/tools,$(TARGET_COPY_OUT_SYSTEM)/bin)


# isp : isp path

IQ_FILES_PATH := $(TOP)/external/camera_engine_rkaiq/iqfiles/isp21
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(IQ_FILES_PATH)/,$(TARGET_COPY_OUT_VENDOR)/etc/camera/rkisp2/)


# camera external 
# Android 카메라 HAL서비스 일환, 외부 카메라 장치를 지원하는 서비스
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-external-service


# Camera HAL
# TARGET_BOARD_HARDWARE ?= rk30board
PRODUCT_PACKAGES += \
    camera.$(TARGET_BOARD_HARDWARE) \
    camera.device@1.0-impl \
    camera.device@3.2-impl \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.metadata@3.2 \
    librkisp_aec \
    librkisp_af \
    librkisp_awb
```

<br/>
<br/>
<br/>
<hr>

## EVBoard

 - dtb : rk3568-evb1-ddr4-v10.dtsi
   * ov5695
     + support resulution (in kernel)
       = 2592x1944
       = 1920x1080
       = 1296x972
       = 1280x720
       = 640x480
     + camera3_profile_rk356x.xml (in hal)
       = 2592x1944
       = 1920x1080
       = 1280x960
       = 1280x720
       = 640x480
       = 320x240
       = 176x144
     + dumpsys media.camera
       = picture-size-values: 2592x1944, 1920x1080, 1280x960, 1280x720, 640x480, 320x240, 176x144

<br/>
<br/>
<br/>
<hr>

## POC Board


<br/>
<br/>
<hr>

### gc2145

 안드로이드 카메라 앱 설정에서 아래 해상도 정보가 출력됨. 

```
 (camera settings)        (resolution)       hal            gc2145 module
 (4:3)  1.9 megapixels : 1600x1200 pixel    1600x1200      1600x1200 (10000,160000)
 (4:3)  0.5 megapixels : 800x600 pixel      800x600        800x600 (10000/160000), 800x600 (10000/300000)
 (4:3)  0.3 megapixels : 640x480 pixel      640x480
 (16:9) 0.9 megapixels : 1280x720 pixel     1280x720
                                      320x240
                                      176x144
```



<br/>
<br/>
<br/>
<hr>

## Function Flow

```
// device/rockchip/common/modules/camera.mk

#camera hal for structured light
ifeq ($(BOARD_CAMERA_SUPPORT_VIR),true)
$(call inherit-product-if-exists, hardware/rockchip/camera_vir/camera_etc.mk)

PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-virtual-service
endif

# Camera external
ifeq ($(BOARD_CAMERA_SUPPORT_EXT),true)

ifdef PRODUCT_USB_CAMERA_CONFIG
PRODUCT_COPY_FILES += \
    $(PRODUCT_USB_CAMERA_CONFIG):$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml
else
PRODUCT_COPY_FILES += \
    device/rockchip/common/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml
endif

PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-external-service
endif


(...)

# Camera Autofocus
ifeq ($(CAMERA_SUPPORT_AUTOFOCUS),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.autofocus.xml
endif

# Copy Camera Hardware define feature file

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml

# Camera HAL
PRODUCT_PACKAGES += \
    camera.$(TARGET_BOARD_HARDWARE) \
    camera.device@1.0-impl \
    camera.device@3.2-impl \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.metadata@3.2 \
    librkisp_aec \
    librkisp_af \
    librkisp_awb

ifeq ($(ROCKCHIP_USE_LAZY_HAL),true)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.camera.enableLazyHal=true
ifeq ($(TARGET_ARCH), $(filter $(TARGET_ARCH), arm64))
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-service-lazy_64
else
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-service-lazy
endif
else
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-service
endif

```

<br/>
<br/>
<hr>

### Camera HAL

```
# Camera HAL
PRODUCT_PACKAGES += \
    camera.$(TARGET_BOARD_HARDWARE) \
    camera.device@1.0-impl \                        -> hardware/interfaces/camera/device/1.0/default
    camera.device@3.2-impl \                        -> hardware/interfaces/camera/device/3.2/default
    android.hardware.camera.provider@2.4-impl \     -> hardware/interfaces/camera/provider/2.4/default
    android.hardware.camera.metadata@3.2 \          -> hardware/interfaces/camera/metadata/3.2
    librkisp_aec \    -> hardware/rockchip/camera_engine_rkisp/interface
    librkisp_af \     -> hardware/rockchip/camera_engine_rkisp/interface
    librkisp_awb      -> hardware/rockchip/camera_engine_rkisp/interface
```

<br/>
<br/>
<br/>
<hr>

## android.com

 - framework APIs in Camera2
 - Camera HAL
   HIDL interface 는 Camera HAL(hardware/interfaces/camera)에 정의 

      





<br/>
<br/>
<br/>
<br/>
<hr>

# Develop

```plane
    (current)         (tp2860)
               +----------------------+
      NTSC >>> + VIN1                 |
               + VIN2                 |
       FHD >>> + VIN3                 |
               + VIN4                 |
               +----------------------+
`   (develop)        (tp2860)
               +----------------------+
               + VIN1                 |
               + VIN2                 |
 NTSC& FHD >>> + VIN3                 |
               + VIN4                 |
               | fhd = 0x2c or (0x0c) |
               |  sd = 0x78           |
               +----------------------+
```
