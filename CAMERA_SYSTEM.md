CAMERA_SYSTEM 
=====


<br/>
<br/>
<br/>
<br/>
<hr>

# analyse

<br/>
<br/>
<br/>
<hr>

## analyse 

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
