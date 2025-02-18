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
               + VIN2 MIPI-YUV-Sensor + >>> ISP
       FHD >>> + VIN3                 |
               + VIN4                 |
               +----------------------+
`   (develop)        (tp2860)
               +----------------------+
               + VIN1                 |
               + VIN2 MIPI-YUV-Sensor + >>> ISP
 NTSC& FHD >>> + VIN3                 |
               + VIN4                 |
               | fhd = 0x2c or (0x0c) |
               |  sd = 0x78           |
               +----------------------+
```

 - /dev/media1 topology

```plane

    +-----------------+     +-----------------------+     +-------------------+
    | Mipi YUV sensor | >>> | rockchip-mipi-dphy-rx | >>> | rkisp1-isp-subdev |
    |                 |     |                       |     | v01.08.00         |
    +-----------------+     +-----------------------+     +-------------------+

+-------------------------+
| "m00_b_tp2860 4-0044":0 |
| /dev/v4l-subdev3        |
+-------------------------+
          V              media-ctl -d /dev/media1  -l '"m00_b_tp2860 4-0044":0 -> "rockchip-csi2-dphy0":0[0]'
+-------------------------+
| "rockchip-csi2-dphy0":0 |
| "rockchip-csi2-dphy0":1 |
| /dev/v4l-subdev2        |
+-------------------------+
          V              media-ctl -d /dev/media1 -l '"rockchip-csi2-dphy0":1 -> "rkisp-csi-subdev":0[1]'
+----------------------+
| "rkisp-csi-subdev":0 |
| "rkisp-csi-subdev":1 |
| /dev/v4l-subdev1     |
+----------------------+
          V             media-ctl -d /dev/media1 -l '"rkisp-csi-subdev":1 -> "rkisp-isp-subdev":0[1]'
+----------------------+
| "rkisp-isp-subdev":0 |
| "rkisp-isp-subdev":2 |
| /dev/v4l-subdev0     |
+---------------------+
          V             media-ctl -d /dev/media1 -l '"rkisp-isp-subdev":2 -> "rkisp_mainpath":0[1]'
+--------------------+
| "rkisp_mainpath":0 |
| /dev/video5        |
+--------------------+

media-ctl -l "m00_b_tp2860 4-0044":0->"rockchip-csi2-dphy0":0[0]"

```

```bash
# V4l2 미디어 컨트롤러를 사용하여 특정 엔티티의 pad format(영상 포맷) 조회
rk3568_rgbp05:/ # media-ctl -d /dev/media1   --get-v4l2 '"m00_b_tp2860 4-0044":0'
                [fmt:UYVY2X8/720x240]


# media-ctl -V 옵션 : 특정 V4L2 엔티티의 pad format(영상 포맷)을 설정 명령어
rk3568_rgbp05:/ # media-ctl -d /dev/media1 -V '"m00_b_tp2860 4-0044":0 [fmt:UYVY2X8/720x240]'
rk3568_rgbp05:/ # media-ctl -d /dev/media1 -V '"m00_b_tp2860 4-0044":0 [fmt:UYVY2X8/1920x1080]'
```

 - dtb

```dtb

 [tp2860:tp2860_out] - [csi2_dphy0:dphy0_in] ------ [csi2_dphy0:dphy0_out] -- [rkisp_vir0:mipi_csi2_input]
 [ov5695:ov5695_out] - [csi2_dphy0:mipi_in_ucam2] - [csi2_dphy0:csiphy_out] - [rkisp_vir0:isp0_in]
```


 - dv_timings
   * struct v4l2_dv_timings_cap: 비디오 타이밍의 범위.
    비디오 장치가 지원하는 타이밍 범위를 설정하거나 쿼리할때 사용.
   * struct v4l2_dv_timings: 비디오 타이밍 정의.
    비디오 장치의 현재 타이밍을 설정하거나 쿼리할때 사용

```bash
struct v4l2_dv_timings_cap {
    __u32 type;                     // timing 유형(ex: V4L2_DV_BT_656_1120)
    __u32 reserved[3];              // 예약된 필드 (호환성을 위해 사용)
    struct v4l2_bt_timings_cap bt;  // BT.656/1120 타이밍 범위

// BT656/1120 타이밍의 최소 및 최대 값 정의
strcut v4l2_bt_timings_cap { 
    __u32 min_width;              // 최소 너비 (픽셀 단위)
    __u32 max_width;              // 최대 너비 (픽셀 단위)
    __u32 min_height;             // 최소 높이 (라인 단위)
    __u32 max_height;             // 최대 높이 (라인 단위)
    __u64 min_pixelclock;         // 최소 픽셀 클럭 (Hz 단위)
    __u64 max_pixelclock;         // 최대 픽셀 클럭 (Hz 단위)
    __u32 standards;              // 지원되는 표준 (예: V4L2_DV_BT_STD_CEA861)
    __u32 capabilities;           // 지원되는 기능 (예: V4L2_DV_BT_CAP_PROGRESSIVE)
    __u32 reserved[16];           // 예약된 필드 (호환성을 위해 사용)
};
```

```bash
struct v4l2_dv_timings {
    __u32 type;                   // 타이밍 유형 (예: V4L2_DV_BT_656_1120)
    union {
        struct v4l2_bt_timings bt; // BT.656/1120 타이밍
        __u32 reserved[32];       // 예약된 필드 (호환성을 위해 사용)
    };
};

struct v4l2_bt_timings {
    __u32 width;                  // 너비 (픽셀 단위)
    __u32 height;                 // 높이 (라인 단위)
    __u32 interlaced;             // 인터레이스 여부 (V4L2_DV_PROGRESSIVE 또는 V4L2_DV_INTERLACED)
    __u32 polarities;             // 신호 극성
    __u64 pixelclock;             // 픽셀 클럭 (Hz 단위)
    __u32 hfrontporch;            // 수평 프론트 포치
    __u32 hsync;                  // 수평 동기 신호
    __u32 hbackporch;             // 수평 백 포치
    __u32 vfrontporch;            // 수직 프론트 포치
    __u32 vsync;                  // 수직 동기 신호
    __u32 vbackporch;             // 수직 백 포치
    __u32 il_vfrontporch;         // 인터레이스 모드에서의 수직 프론트 포치
    __u32 il_vsync;               // 인터레이스 모드에서의 수직 동기 신호
    __u32 il_vbackporch;          // 인터레이스 모드에서의 수직 백 포치
    __u32 standards;              // 지원되는 표준 (예: V4L2_DV_BT_STD_CEA861)
    __u32 flags;                  // 추가 플래그
    __u32 reserved[14];           // 예약된 필드 (호환성을 위해 사용)
};
```
