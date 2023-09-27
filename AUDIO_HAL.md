AUDIO_HAL
=====
> Android의 Audio HAL에 대한 문서


Index
=====

```
▼ Audio HAL 구조 : section
    Audio HAL layer interface : section
    Audio HAL modules : section
  ▼ key class 및 structure : section
    ▼ Audio HAL의 연결 포인터 3그룹. : section
        1. module open시 일어나는 audio_hw_device 관련 연결 작업. : section
        2. openOutput에서 일어나는 audio_hw_output 관련 연결 작업 : section
        3. openInput에서 일어나는 audio_hw_input 관련 연결 작업 : section

▼ 분석 : section
    분석 : device directory : section
    분석 : audio_route : section

▼ 참고 : section
    참고 : rk817 mixer info : section

▼ 개발 : section
    develop command : section

▼ Note : section
    android_automotive : section
```


# Audio HAL 구조 

- blockdiagram

 ![](images/AUDIO_HAL_01.png)

## Audio HAL layer interface
 - audio HAL에는 audio_module과 audio_policy_module이 존재. 
 - HAL layer의 lowwer layer는 tinyalsa를 사용. 

 - audio.a2dp.default.so(bluetooth a2dp audio 관리), audio.usb.default.so(usb 외부 audio 관리)와 같은 독립적인 lib 파일로 구현. 
 - audio.primary.default.so(장치의 대부분의 audio 관리)
 - 일부 manufacturer 은 audio.primary.rk30board.so 와 같은 lib를 구현해 배포.

-----

## Audio HAL modules

 [-> */system/media/audio/include/system/audio.h* ]
```c
 * List of known audio HAL modules. This is the base name of the audio HAL
 * library composed of the "audio." prefix, one of the base names below and
 * a suffix specific to the device.
 * e.g: audio.primary.goldfish.so or audio.a2dp.default.so
 *
 * The same module names are used in audio policy configuration files.
 */

#define AUDIO_HARDWARE_MODULE_ID_PRIMARY "primary"
#define AUDIO_HARDWARE_MODULE_ID_A2DP "a2dp"
#define AUDIO_HARDWARE_MODULE_ID_USB "usb"
#define AUDIO_HARDWARE_MODULE_ID_REMOTE_SUBMIX "r_submix"
#define AUDIO_HARDWARE_MODULE_ID_CODEC_OFFLOAD "codec_offload"
#define AUDIO_HARDWARE_MODULE_ID_STUB "stub"
#define AUDIO_HARDWARE_MODULE_ID_HEARING_AID "hearing_aid"
#define AUDIO_HARDWARE_MODULE_ID_MSD "msd"
```

-----

## key class 및 structure
 - HAL은 upper layer에 hardware에 대한 인터페이스를 제공해야 한다.
   * **struct audio_hw_device** : struct audio_hw_device 를 통해 인터페이스를 제공한다.

 - AudioFlinger가 library를 호출하는 과정은 아래와 같다.

```bash
	AudioFlinger::loadHwModule
	->AudioFlinger::loadHwModule_l
	-->mDevicesFactoryHal->openDevice(name, &dev);
	--->load_audio_interface
	---->audio_hw_device_open(mod, dev);
	----->module->methods->open 
```
  
  * AudioFlinger에서 libhardware 함수 hw_get_module(hw_get_module_by_class)을 통해 struct hw_module_t정보를 획득합니다.
  * 이후, audio_hw_device_open을 통해 audio_hw_device_t 정보를 얻어옵니다.  
    방법은 hw_module_t->methods(hw_module_methods_t)->open 을 호출하면 audio hal에서 adev_open 함수를 호출합니다.

```c
	struct audio_device {
		struct audio_hw_device device;
		...
	};
```
	struct audio_device를 생성하여 멤버변수 struct audio_hw_device device를 리턴합니다.

```c
	struct audio_hw_device {
		struct hw_device_t common;
		uint32_t (*get_supported_devices)(const struct audio_hw_device *dev);
		int (*init_check)(const struct audio_hw_device *dev);
		int (*set_voice_volume)(struct audio_hw_device *dev, float volume);
		int (*set_master_volume)(struct audio_hw_device *dev, float volume);
		int (*get_master_volume)(struct audio_hw_device *dev, float *volume);
		int (*set_mode)(struct audio_hw_device *dev, audio_mode_t mode);
		int (*set_mic_mute)(struct audio_hw_device *dev, bool state);
		int (*get_mic_mute)(const struct audio_hw_device *dev, bool *state);
		int (*set_parameters)(struct audio_hw_device *dev, const char *kv_pairs);
		char * (*get_parameters)(const struct audio_hw_device *dev,
		                         const char *keys);
		size_t (*get_input_buffer_size)(const struct audio_hw_device *dev,
		                                const struct audio_config *config);
		int (*open_output_stream)(struct audio_hw_device *dev,
		                          audio_io_handle_t handle,
		                          audio_devices_t devices,
		                          audio_output_flags_t flags,
		                          struct audio_config *config,
		                          struct audio_stream_out **stream_out);
		void (*close_output_stream)(struct audio_hw_device *dev,
		                            struct audio_stream_out* stream_out);
		int (*open_input_stream)(struct audio_hw_device *dev,
		                         audio_io_handle_t handle,
		                         audio_devices_t devices,
		                         struct audio_config *config,
		                         struct audio_stream_in **stream_in);
		void (*close_input_stream)(struct audio_hw_device *dev,
		                           struct audio_stream_in *stream_in);
		int (*dump)(const struct audio_hw_device *dev, int fd);
		int (*set_master_mute)(struct audio_hw_device *dev, bool mute);
		int (*get_master_mute)(struct audio_hw_device *dev, bool *mute);
	};
	typedef struct audio_hw_device audio_hw_device_t;
```

 * AudioFlinger에서 hw_get_module와 audio_hw_device_open를 호출하여 audio HAL과 연결을 먼저하고, 
 * open_output_stream 함수를 호출하면 struct audio_stream를 하나 생성하여 각 포인터를 연결합니다.

-----

### Audio HAL의 연결 포인터 3그룹.

#### 1. module open시 일어나는 audio_hw_device 관련 연결 작업.

```c
   static int adev_open(....)
   {
       adev->device.init_check = adev_init_check;
       adev->device.set_voice_volume = adev_set_voice_volume;
       adev->device.set_master_volume = adev_set_master_volume;
       adev->device.get_master_volume = adev_get_master_volume;
       adev->device.set_master_mute = adev_set_master_mute;
       adev->device.get_master_mute = adev_get_master_mute;
       adev->device.set_mode = adev_set_mode;
       adev->device.set_mic_mute = adev_set_mic_mute;
       adev->device.get_mic_mute = adev_get_mic_mute;
       adev->device.set_parameters = adev_set_parameters;
       adev->device.get_parameters = adev_get_parameters;
       adev->device.get_input_buffer_size = adev_get_input_buffer_size;
       adev->device.open_output_stream = adev_open_output_stream;
       adev->device.close_output_stream = adev_close_output_stream;
       adev->device.open_input_stream = adev_open_input_stream;
       adev->device.close_input_stream = adev_close_input_stream;
       adev->device.dump = adev_dump;
   }
```

#### 2. openOutput에서 일어나는 audio_hw_output 관련 연결 작업
 
```c
 static int adev_open_output_stream(.... ) 
   {
       out->stream.common.get_sample_rate = out_get_sample_rate;
       out->stream.common.set_sample_rate = out_set_sample_rate;
       out->stream.common.get_buffer_size = out_get_buffer_size;
       out->stream.common.get_channels = out_get_channels;
       out->stream.common.get_format = out_get_format;
       out->stream.common.set_format = out_set_format;
       out->stream.common.standby = out_standby;
       out->stream.common.dump = out_dump;
       out->stream.common.set_parameters = out_set_parameters;
       out->stream.common.get_parameters = out_get_parameters;
       out->stream.common.add_audio_effect = out_add_audio_effect;
       out->stream.common.remove_audio_effect = out_remove_audio_effect;
       out->stream.get_latency = out_get_latency;
       out->stream.set_volume = out_set_volume;
       out->stream.write = out_write;
       out->stream.get_render_position = out_get_render_position;
       out->stream.get_next_write_timestamp = out_get_next_write_timestamp;
       out->stream.get_presentation_position = out_get_presentation_position;
   }
```

#### 3. openInput에서 일어나는 audio_hw_input 관련 연결 작업
 
```c
   static int adev_open_input_stream(....)
   {
       in->stream.common.get_sample_rate = in_get_sample_rate;
       in->stream.common.set_sample_rate = in_set_sample_rate;
       in->stream.common.get_buffer_size = in_get_buffer_size;
       in->stream.common.get_channels = in_get_channels;
       in->stream.common.get_format = in_get_format;
       in->stream.common.set_format = in_set_format;
       in->stream.common.standby = in_standby;
       in->stream.common.dump = in_dump;
       in->stream.common.set_parameters = in_set_parameters;
       in->stream.common.get_parameters = in_get_parameters;
       in->stream.common.add_audio_effect = in_add_audio_effect;
       in->stream.common.remove_audio_effect = in_remove_audio_effect;
       in->stream.set_gain = in_set_gain;
       in->stream.read = in_read;
       in->stream.get_input_frames_lost = in_get_input_frames_lost;
   }

```


-----

<br />
<br />
<br />
<br />
<br />

-----

# 분석

-----

## 분석 : device directory

device/company/test/rk3568_poc/rk3568_poc.mk
device/company/nova/rk3568/device.mk
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
 > "android.hardware.audio@7.0-impl" 에서 impl은 implementation의 약어.
 > 즉, Android 7.0 용 오디오 하드웨어 인터페이스의 구현을 의미

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


## 분석 : audio_route
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

- libtinyalsa.so

> system/lib/libtinyalsa.so : Android 시스템의 오디오 하드웨어와 상호 작용하는데 사용되는 오픈 소스 라이브러리. 

system/media/audio_route 경로에 위치하며, tinyalsa_hal에서 libtinyalsa.so파일을 추가하여 따로 정의된 xml파일에 따라 오디오 코덱을 제어하도록 할수 있을 것 같다.

 - 참고 : hardware/qcom/audio/hal/audio_hw.c 의 voice_start_call() -> voice_start_usecase() -> voice_set_sidetone() -> platform_set_sidetone()




# 참고

## 참고 : rk817 mixer info
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

 - Android의 오디오 모듈에 대한 config file 정리.
   * /system/etc/mixer_paths.xml : route list (system audio stream)
   * /vendor/etc/audio_policy_configuration.xml  
      : xml 내의 <modules>는 각 audio HAL 의 so 파일에 해당하며 모듈에 나열된 mixPorts, devicePorts, routes 는 audio routing에 대한 정보를 나타낸다.
     + module name : primary(for in-vehicle usage), A2DP, remote_submix, USB 를 지원하며, module 이름과 해당 오디오 드라이버는 audio.primary.$(variant).so 으로 컴파일 되어야 한다.  


 - AudioRoute index
```
typedef enum _AudioRoute {
    SPEAKER_NORMAL_ROUTE = 0,
    SPEAKER_INCALL_ROUTE, // 1
    SPEAKER_RINGTONE_ROUTE,
    SPEAKER_VOIP_ROUTE,

    EARPIECE_NORMAL_ROUTE, // 4
    EARPIECE_INCALL_ROUTE,
    EARPIECE_RINGTONE_ROUTE,
    EARPIECE_VOIP_ROUTE,

    HEADPHONE_NORMAL_ROUTE, // 8
    HEADPHONE_INCALL_ROUTE,
    HEADPHONE_RINGTONE_ROUTE,
    SPEAKER_HEADPHONE_NORMAL_ROUTE,
    SPEAKER_HEADPHONE_RINGTONE_ROUTE,
    HEADPHONE_VOIP_ROUTE,

    HEADSET_NORMAL_ROUTE, // 14
    HEADSET_INCALL_ROUTE,
    HEADSET_RINGTONE_ROUTE,
    HEADSET_VOIP_ROUTE,

    BLUETOOTH_NORMAL_ROUTE, // 18
    BLUETOOTH_INCALL_ROUTE,
    BLUETOOTH_VOIP_ROUTE,

    MAIN_MIC_CAPTURE_ROUTE, // 21
    HANDS_FREE_MIC_CAPTURE_ROUTE,
    BLUETOOTH_SOC_MIC_CAPTURE_ROUTE,

    PLAYBACK_OFF_ROUTE, // 24
    CAPTURE_OFF_ROUTE,
    INCALL_OFF_ROUTE,
    VOIP_OFF_ROUTE,

    HDMI_NORMAL_ROUTE, // 28

    SPDIF_NORMAL_ROUTE,

    USB_NORMAL_ROUTE, // 30
    USB_CAPTURE_ROUTE,

    HDMI_IN_NORMAL_ROUTE,
    HDMI_IN_OFF_ROUTE,
    HDMI_IN_CAPTURE_ROUTE,
    HDMI_IN_CAPTURE_OFF_ROUTE,

    MAX_ROUTE, //36
} AudioRoute;
```

-----

<br />
<br />
<br />
<br />
<br />

-----

# 개발

## develop command

```bash
adb root ; adb remount ; adb push  device/COMPANY/test/rk3568_edpp01/audio/audio_policy_configuration.xml  /vendor/etc/
adb root ; adb remount ; adb push  out/target/product/rk3568_edpp01/vendor/lib/hw/audio.primary.rk30board.so /vendor/lib/hw/
scrcpy -m1024 --always-on-top
```

-----

<br />
<br />
<br />
<br />
<br />

-----

# Note

## android_automotive
 - [ ] Car audio policy의 경우, alarm, notification, system sound는 cpu board에서 출력되고, 그외 sound는 extend audio board 에서 출력  
 - [ ] *android_policy_configuration.xml*에서 **role** 의 속성으로 *sink(output)*, *source(input)* 을 세팅하는데, door와 같은 시나리오에 어떻게 적용해야 하나 ?
 - [ ] prebuilts/vndk/v31/x86_x64/include/hardware/libhardware/include/hardware/audio.h : 뭐하는 곳?
 - [ ] to enable the audio patch feature, the audio HAL should set the major HAL version 3.0 or higher? : https://source.android.com/docs/core/audio/device-type-limit
	 ref : audio HAL for Cuttlefish 
 - [ ] 자동차 오디오 HAL 구현 :  https://source.android.com/docs/devices/automotive/audio/audio-hal?hl=ko
 
 - [ ] audiopolicymanager_tests :  gtest Framework를 사용하는 테스트 프로그램
 - [ ] libaudiopolicymanagercustom : 
 - [x] Android Audio HAL의 stream 구조체에서 standby는 스트림이 현재 사용되지 않고 대기 중임을 나타냄.  스트림이 standby 상태에 있으면 전력을 절약하고 스트림이 재개될때까지 오디오 데이터를 처리하지 않는다.
 - [x] frames_rd 는 오디오 드라이버가 읽은 오디오 프레임 수를 의미함. 오디오 드라이버는 오디오 스트림에서 오디오 데이터를 읽고 이 데이터를 하드웨어에 전송한다. frames_rd 값은 오디오 드라이버가 읽은 오디오 프레임 수와 오디오 하드웨어에 전송된 오디오 프레임 수를 추적하는데 사용.


