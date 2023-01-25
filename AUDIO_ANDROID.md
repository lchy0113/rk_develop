AUDIO ANDROID
=====
> Android의 Audio에 대한 문서.




 ![](./images/AUDIO_ANDROID_01.png)

 - APPLICATION FRAMEWORK : android.media API를 사용하여 오디오 하드웨어와 상호작용하는 앱 코드가 존재.  
 - JNI : android.media와 연결된 JNI코드는 오디오 하드웨어에 액세스 하기 위해 하위 수준의 기본 코드를 호출.  
	 JNI는 frameworks/base/core/jni/ 및 framewworks/base/media/jni 에 존재.  
 - NATIVE FRAMEWORK : 기본 프레임워크는 android.media 패키지와 동일한 기본 기능을 제공하며,   
     바인더 IPC 프록시를 호출하여 미디어 서버의 오디오 관련 서비스에 액세스한다.  
	 기본 프레임워크 코드는 frameworks/av/media/libmedia에 존재.  
 - BINDER IPC : 바인더 IPC 프록시는 프로세스 경계를 통한 통신을 용이하게 한다.  
	 frameworks/av/media/libmedia에 존재하며 I로 시작한다.  
 - MEDIA SERVER : 미디어 서버는 HAL 구현과 상호작용하는 실제 코드인 오디오 서비스가 포함되어 있다.  
     frameworks/av/services/audioflinger에 존재  
 - HAL : HAL은 오디오 서비스가 호출하고 오디오 하드웨어가 올바르게 작동하기 위해 구현해야 하는 표준 인터페이스를 정의  
  [audio HAL interface](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/audio/) 
 - LINUX KERNEL : 오디오 드라이버는 하드웨어 및 HAL 구현과 상호 작용한다.  
    ALSA, OSS 또는 사용자 지정 드라이버를 사용할 수 있다.


# Implementation

 ## Policy Configuration

 Android 7.0 버전에서 audio topology 를 기술하기 위해 audio policy configuration file format(XML)이 도입되었다.
 이전의 Android 버전에서는 device/<company>/<device>/audio/audio_policy.conf 파일을 사용하여 제품의 오디오 장치를 선언해야 했습니다.
 > Galaxy Nexus 오디오 하드웨어에 대한 예제는 device/samsung/tuna/audio/audio_policy.conf 에서 볼 수 있다. 
 그러나 audio_policy.conf 파일은 TV, automobiles와 같은 복잡한 topology를 기술하기에는 제한이 있다.
 Android 7.0은 audio_policy.conf를 사용하지 않으며, audio topology를 더 쉽고 광범위하게 적용할 수 있는 XML 파일 형식이 도입되었다.  
 Android 7.0은 USE_XML_AUDIO_POLICY_CONF build flag를 사용하여 configuration file의 XML 형식을 선택한다.
 > Android 10 에서 conf 형식은 제거되고, USE_XML_AUDIO_POLICY_CONF 빌드 플래그를 지원한다.

 ### Advantages of the XML format
 
 conf 파일에서와 마찬가지로 XML파일을 사용하면 output 및 input Stream profiles 의 수와 유형, play, capture에서 사용할 수 있는  
 device, audio attributes 을 정의 할 수 있다. 
 또한 XML파일은 아래와 같은 향상된 기능을 제공.

 - 동시에 멀티 recording app 동작을 지원. 
 - client는 무음 오디오 샘플을 지원한다. 
 - Audio format에 따라서 각 각 서로 다른 sampling rate/ channel 을 사용할 수 있다.
 - device와 streams간  연결 가능한 모든 연결에 대해 정의를 시킬 수 있다.  (controlling connections requested with audio patch APIs)
	 XML 파일을 통해 topology 에 대해 기술한다.
 - include에 대한 지원은 표준 A2DP, USB 또는 reroute 제출 정의의 반복을 방지한다.
 - 볼륨 곡선은 사용자 정의할 수 있습니다. 이전에는 볼륨 테이블이 하드코딩되었습니다. XML 형식으로 볼륨 테이블이 설명되고 사용자 정의될 수 있다.
 - template 은 frameworks/av/services/audiopolicy/config/audio_policy_configuration.xml 에 정의 되어 있다.

 ### File format and location

 새로운 audio policy configuration file은 audio_policy_configuration.xml파일이며, /system/etc/에 존재한다.
 아래 샘플은 Android12 및 Android12 이하 버전에서 XML 파일 형식의 간단한 audio policy configuration을  보여준다.

 ```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<audioPolicyConfiguration version="7.0" xmlns:xi="http://www.w3.org/2001/XInclude">
    <globalConfiguration speaker_drc_enabled="true"/>
    <modules>
        <module name="primary" halVersion="3.0">
            <attachedDevices>
                <item>Speaker</item>
                <item>Earpiece</item>
                <item>Built-In Mic</item>
            </attachedDevices>
            <defaultOutputDevice>Speaker</defaultOutputDevice>
            <mixPorts>
                <mixPort name="primary output" role="source" flags="AUDIO_OUTPUT_FLAG_PRIMARY">
                    <profile name="" format="AUDIO_FORMAT_PCM_16_BIT"
                             samplingRates="48000" channelMasks="AUDIO_CHANNEL_OUT_STEREO"/>
                </mixPort>
                <mixPort name="primary input" role="sink">
                    <profile name="" format="AUDIO_FORMAT_PCM_16_BIT"
                             samplingRates="8000 16000 48000"
                             channelMasks="AUDIO_CHANNEL_IN_MONO"/>
                </mixPort>
            </mixPorts>
            <devicePorts>
                <devicePort tagName="Earpiece" type="AUDIO_DEVICE_OUT_EARPIECE" role="sink">
                   <profile name="" format="AUDIO_FORMAT_PCM_16_BIT"
                            samplingRates="48000" channelMasks="AUDIO_CHANNEL_IN_MONO"/>
                </devicePort>
                <devicePort tagName="Speaker" role="sink" type="AUDIO_DEVICE_OUT_SPEAKER" address="">
                    <profile name="" format="AUDIO_FORMAT_PCM_16_BIT"
                             samplingRates="48000" channelMasks="AUDIO_CHANNEL_OUT_STEREO"/>
                </devicePort>
                <devicePort tagName="Wired Headset" type="AUDIO_DEVICE_OUT_WIRED_HEADSET" role="sink">
                    <profile name="" format="AUDIO_FORMAT_PCM_16_BIT"
                             samplingRates="48000" channelMasks="AUDIO_CHANNEL_OUT_STEREO"/>
                </devicePort>
                <devicePort tagName="Built-In Mic" type="AUDIO_DEVICE_IN_BUILTIN_MIC" role="source">
                    <profile name="" format="AUDIO_FORMAT_PCM_16_BIT"
                             samplingRates="8000 16000 48000"
                             channelMasks="AUDIO_CHANNEL_IN_MONO"/>
                </devicePort>
                <devicePort tagName="Wired Headset Mic" type="AUDIO_DEVICE_IN_WIRED_HEADSET" role="source">
                    <profile name="" format="AUDIO_FORMAT_PCM_16_BIT"
                             samplingRates="8000 16000 48000"
                             channelMasks="AUDIO_CHANNEL_IN_MONO"/>
                </devicePort>
            </devicePorts>
            <routes>
                <route type="mix" sink="Earpiece" sources="primary output"/>
                <route type="mix" sink="Speaker" sources="primary output"/>
                <route type="mix" sink="Wired Headset" sources="primary output"/>
                <route type="mix" sink="primary input" sources="Built-In Mic,Wired Headset Mic"/>
            </routes>
        </module>
        <xi:include href="a2dp_audio_policy_configuration.xml"/>
    </modules>

    <xi:include href="audio_policy_volumes.xml"/>
    <xi:include href="default_volume_tables.xml"/>
</audioPolicyConfiguration>

 ```

 top-level structure 는 각 audio HAL hardware module에 해당하는 module 이 포함되어 있으며, 
 각 module은 mix port, device port, and route 가 포함되어 있습니다. 

 - mixPorts : Mix ports는 play, capture를 위해 Audio HAL에서 열수 있는 stream의 가능한 config profiles을 기술한다. 
 - devicePorts : Device ports는 연결할 수 있는 type 을 기술한다.
 - reoutes : Routes는 device에서 device로 또는 stream 에서 device 의 route 를 기술한다.

 Volume table은 UI 인덱스에서 volume(dB)로 변환하는데 사용되는 curve 을 정의하는 간단한 리스트 이다.

 volume table sample
 ```
 <?xml version="1.0" encoding="UTF-8"?>
<volumes>
    <reference name="FULL_SCALE_VOLUME_CURVE">
        <point>0,0</point>
        <point>100,0</point>
    </reference>
    <reference name="SILENT_VOLUME_CURVE">
        <point>0,-9600</point>
        <point>100,-9600</point>
    </reference>
    <reference name="DEFAULT_VOLUME_CURVE">
        <point>1,-4950</point>
        <point>33,-3350</point>
        <point>66,-1700</point>
        <point>100,0</point>
    </reference>
</volumes>
 ```

 ### File inclusions

 XML include(XINclude) method는 다른 XML 파일에 있는 audio policy configuration information을 include할 수 있다. 
 include 된 XML파일은 위에 설명된 구조를 따라야 하며 아래 제한 사항이 적용 된다.

 - File에는 최상위 요소만 포함될 수 있다.
 - File은 XInclude 요소를 포함할 수 없다.

 ### Audio policy code organization

 AudioPolicyManager.cpp는 유지 관리 및 configure을 쉽게 하기 위해 여러 module로 분할한다.
 frameworks/av/services/audiopolicy의 구성에는 다음 모듈이 포함된다.

 - /managerdefault
 - /common
 - /engine
 - /engineconfigurable
 - /enginedefault
 - /service

 ### Configuration using Parameter Framework

 Audio policy code는 configuration files에 의해 정의된 audio policy 를 지원하면서 쉽게 이해하고 유지 할 수 있도록 구성된다. 
 organization and audio policy 설계는 Intel's Parameter Framework 베이스로 한다.


 ### Audio policy routing APIs

 Android 6.0 버전에서는 Audio patch/audio port infra 상위에 있는 public Enumeration 과 Selection API를 통해, App 개발자가 연결된 audio records 또는 tracks에 대한 특정 device output or input에 대한 설정을 나타냈다. 
 
 Android 7.0에서 Enumeration and Selection API는 CTS 테스트를 통해 확인되었으며 네이티브 C/C++(OpenSL ES) 오디오 스트림에 대한 라우팅을 포함하도록 확장되었습니다.
 네이티브 스트림의 라우팅은 AudioTrack 및 AudioRecord 클래스에 고유한 명시적 라우팅 메서드를 대체, 결합 및 폐기하는 AudioRouting 인터페이스를 추가하여 Java에서 계속 수행됩니다.
 Enumeration and Selection API에 대한 자세한 내용은 Android 구성 인터페이스 및 OpenSLES_AndroidConfiguration.h를 참조하세요.
 오디오 라우팅에 대한 자세한 내용은 AudioRouting을 참조하십시오.


# Audio on Android

## Mixer configuration
 > Android Audio HAL이 ALSA mixer 를 configuration하는 방법에 대해 설명.
 Android 기기에는 headphone, speaker, mic 와 같은 다양한 mixer configuration이 있다.
 audio route configuration은 mixer_paths.xml에 정의되어 있다. 

 Android audio HAL은 tinyalsa 및 audio_route를 사용한다.

 tinyalsa는 linux 커널에서 ALSA와 interface하는 standalone library이다. 
 audio HAL은 XML에서 audio path를 load하고, tinyalsa를 통해 mixer를 제어하는 audio_route library를 호출한다. 

## Format of mixer_paths.xml
 - ALSA 제어는 *ctl* elements로 정의한다.
 - Audio route는 *path* elements로 정의한다.
   *path* element에는 *ctl* elements와 other *path* elements 를 포함한다.
 - path *name* attribute 는 audio route를 선택하는데 사용된다.

  경로 요소에는 ctl 요소와 기타 경로 요소의 컬렉션이 포함됩니다.



# Audio HAL

## 1. Analysis of important interface files
  
> HAL 인터페이스 파일을 통하여 HAL Layer  분석.   
  
*DeviceHalInterface.h* (frameworks/av/media/libaudiohal/include/media/audiohal/DeviceHalInterface.h)  
*AudioHwDevice.h* (frameworks/av/services/audioflinger/AudioHwDevice.h)  
  
DeviceHalInterface.h는 HAL layer를 연결하는 Interface 이고,   
AudioHwDevice.h 는 hw Dev의 packaging 입니다.  
  
✅ 이 두 인터페이스 파일에서 관련 메서드의 기능을 분석.  
  
[->DeviceHalInterface.h]
```cpp
namespace android {

class StreamInHalInterface;
class StreamOutHalInterface;

class DeviceHalInterface : public RefBase
{
```




-----

# Analyse

device/kdiwin/test/rk3568_poc/rk3568_poc.mk
device/kdiwin/nova/rk3568/device.mk
device/rockchip/common/BoardConfig.mk
```
TARGET_BOARD_HARDWARE ?= rk30board
```
device/rockchip/common/device.mk
```
	PRODUCT_COPY_FILES += \
		$(LOCAL_PATH)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
		$(LOCAL_PATH)/audio_policy_volumes_drc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes_drc.xml \
		frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
		frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration_7_0.xml \
		frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
		frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
		frameworks/av/media/libeffects/data/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml

	(...)

	$(call inherit-product-if-exists, hardware/rockchip/audio/tinyalsa_hal/codec_config/rk_audio.mk)

	(...)

	# audio lib
	PRODUCT_PACKAGES += \
		audio_policy.$(TARGET_BOARD_HARDWARE) \
		audio.primary.$(TARGET_BOARD_HARDWARE) \
		audio.alsa_usb.$(TARGET_BOARD_HARDWARE) \
		audio.a2dp.default\
		audio.r_submix.default\
		libaudioroute\
		audio.usb.default\
		libanr

	PRODUCT_PACKAGES += \
		android.hardware.audio@2.0-service \
		android.hardware.audio@7.0-impl \
		android.hardware.audio.effect@7.0-impl

	(...)
		
	# audio lib
	PRODUCT_PACKAGES += \
		libasound \
		alsa.default \
		acoustics.default \
		libtinyalsa \
		tinymix \
		tinyplay \
		tinycap \
		tinypcminfo

	PRODUCT_PACKAGES += \
		alsa.audio.primary.$(TARGET_BOARD_HARDWARE)\
		alsa.audio_policy.$(TARGET_BOARD_HARDWARE)

	(...)

	USE_XML_AUDIO_POLICY_CONF := 1

	(...)

	# add AudioSetting
	PRODUCT_PACKAGES += \
		rockchip.hardware.rkaudiosetting@1.0-service \
		rockchip.hardware.rkaudiosetting@1.0-impl \
		rockchip.hardware.rkaudiosetting@1.0

	PRODUCT_COPY_FILES += \
		$(LOCAL_PATH)/rt_audio_config.xml:/system/etc/rt_audio_config.xml

```
device/rockchip/common/BoardConfig.mk
```
	(...)
	# Audio
	BOARD_USES_GENERIC_AUDIO ?= true

```
hardware/rockchip/audio/tinyalsa_hal/codec_config/rk_audio.mk
```
PRODUCT_COPY_FILES += \
    hardware/rockchip/audio/tinyalsa_hal/codec_config/mixer_paths.xml:system/etc/mixer_paths.xml 
```


## AudioFlinger -> HAL

 HAL layer initialization is done during AF initialization.
 When AF is initialized, use the DeviceFactoryHalInterface static method to create a Hal factory object

 [->AudioFlinger.cpp]
```cpp
AudioFlinger::AudioFlinger()	{
	(...)
    mDevicesFactoryHal = DevicesFactoryHalInterface::create();
	(...)
}
```
 [->DeviceFactoryHalInterface.cpp]
```cpp

```

## audio_route 분석
 audio_route.c 는 /system/media/audio_route 디렉토리에 있는 android에서 제공하는 audio path library(libaudioroute.so) 이다.
 1. /system/etc/mixer_paths.xml 구성 파일을 파싱한다.
 2. audio ctl access 방법을 capsulate 하여, audio_hw(hal) 호출을 편리하게 한다.

 안드로이드 시스템에서는 mixer_paths.xml에 정의된 ctl nodes 를 사용하여 코덱을 제어한다.
```bash
ROCKCHIP_ANDROID12$ rg mixer_paths
system/media/audio_route/audio_route.c
32:#define MIXER_XML_PATH "/system/etc/mixer_paths.xml"

hardware/qcom/audio/hal/msm8916/platform.c
38:#define MIXER_XML_PATH "mixer_paths.xml"

hardware/qcom/audio/hal/msm8974/platform.c
41:#define MIXER_XML_DEFAULT_PATH "mixer_paths.xml"
1762:     * <iii> mixer_paths.xml

hardware/qcom/audio/hal/msm8960/platform.c
41:#define MIXER_XML_PATH "/system/etc/mixer_paths.xml"

hardware/rockchip/audio/tinyalsa_hal/codec_config/rk_audio.mk
2:    hardware/rockchip/audio/tinyalsa_hal/codec_config/mixer_paths.xml:system/etc/mixer_paths.xml 

hardware/rockchip/audio/tinyalsa_hal/cscope.out
45998:/mixer_paths.xml

```


### temp
```c
struct audio_device {
    struct audio_hw_device hw_device;

    pthread_mutex_t lock; /* see note below on mutex acquisition order */
    audio_devices_t out_device; /* "or" of stream_out.device for all active output streams */
    audio_devices_t in_device;
    bool mic_mute;
    struct audio_route *ar;
    audio_source_t input_source;
    audio_channel_mask_t in_channel_mask;

    struct stream_out *outputs[OUTPUT_TOTAL];
    pthread_mutex_t lock_outputs; /* see note below on mutex acquisition order */
    unsigned int mode;
    bool   screenOff;
#ifdef AUDIO_3A
    rk_process_api* voice_api;
#endif

    /*
     * hh@rock-chips.com
     * this is for HDMI/SPDIF bitstream
     * when HDMI/SPDIF bistream AC3/EAC3/DTS/TRUEHD/DTS-HD, some key tone or other pcm
     * datas may come(play a Ac3 audio and seek the file to play). It is not allow to open sound card
     * as pcm format and not allow to write pcm datas to HDMI/SPDIF sound cards when open it
     * with config.flag = 1.
     */
    int*  owner[2];

    struct dev_info dev_out[SND_OUT_SOUND_CARD_MAX];
    struct dev_info dev_in[SND_IN_SOUND_CARD_MAX];
};
```


```c
static int adev_open(const hw_module_t* module, const char* name,
                     hw_device_t** device)
{
    struct audio_device *adev;
    int ret;

    ALOGD(AUDIO_HAL_VERSION);

    if (strcmp(name, AUDIO_HARDWARE_INTERFACE) != 0)
        return -EINVAL;

    adev = calloc(1, sizeof(struct audio_device));
    if (!adev)
        return -ENOMEM;

    adev->hw_device.common.tag = HARDWARE_DEVICE_TAG;
    adev->hw_device.common.version = AUDIO_DEVICE_API_VERSION_2_0;
    adev->hw_device.common.module = (struct hw_module_t *) module;
    adev->hw_device.common.close = adev_close;

    adev->hw_device.init_check = adev_init_check;
    adev->hw_device.set_voice_volume = adev_set_voice_volume;
    adev->hw_device.set_master_volume = adev_set_master_volume;
    adev->hw_device.set_mode = adev_set_mode;
    adev->hw_device.set_mic_mute = adev_set_mic_mute;
    adev->hw_device.get_mic_mute = adev_get_mic_mute;
    adev->hw_device.set_parameters = adev_set_parameters;
    adev->hw_device.get_parameters = adev_get_parameters;
    adev->hw_device.get_input_buffer_size = adev_get_input_buffer_size;
    adev->hw_device.open_output_stream = adev_open_output_stream;
    adev->hw_device.close_output_stream = adev_close_output_stream;
    adev->hw_device.open_input_stream = adev_open_input_stream;
    adev->hw_device.close_input_stream = adev_close_input_stream;
    adev->hw_device.dump = adev_dump;
    adev->hw_device.get_microphones = adev_get_microphones;
    //adev->ar = audio_route_init(MIXER_CARD, NULL);
    //route_init();
    /* adev->cur_route_id initial value is 0 and such that first device
     * selection is always applied by select_devices() */
    *device = &adev->hw_device.common;

    adev_open_init(adev);
    return 0;
}
```


### route_init

 route_init() (hardware/rockchip/audio/tinyalsa_hal/alsa_route.c) : sound_card_config_list의 데이터 config
 adev_open() (hardware/rockchip/audio/tinyalsa_hal/audio_hw.c)에 의해 부팅 시 호출.



# reference 

 ## site 
 - AOSP : https://source.android.com/docs/core/audio

 ## code
 
 - rk817 mixer info
```
rk3568_evb:/ # tinymix
Mixer name: 'rockchip,rk809-codec'
Number of controls: 2
ctl     type    num     name                                     value

0       ENUM    1       Playback Path                            OFF
1       ENUM    1       Capture MIC Path                         MIC OFF
rk3568_evb:/ # tinymix  'Playback Path'
Playback Path: >OFF RCV SPK HP HP_NO_MIC BT SPK_HP RING_SPK RING_HP RING_HP_NO_MIC RING_SPK_HP
rk3568_evb:/ #
rk3568_evb:/ # tinymix  'Capture MIC Path'
Capture MIC Path: >MIC OFF Main Mic Hands Free Mic BT Sco Mic
```
