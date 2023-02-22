AUDIO_HAL
=====

# Audio HAL blockdiagram

 ![](images/AUDIO_HAL_01.png)

## HAL layer 
 - audio HAL에는 audio_module과 audio_policy_module이 존재합니다. 
 - HAL layer의 아래의 layer는 tinyalsa를 사용합니다. 

 - audio.a2dp.default.so(bluetooth a2dp audio 관리), audio.usb.default.so(usb 외부 audio 관리)와 같은 독립적인 lib 파일로 구현됩니다. 
 - audio.primary.default.so(장치의 대부분의 audio 관리)
 - 일부 manufacturer 은 audio.primary.rk30board.so 와 같은 lib를 구현해 배포합니다.

-----

## key class 및 structure
 - HAL은 upper layer에 hardware에 대한 인터페이스를 제공해야 합니다.
   * **struct audio_hw_device** : struct audio_hw_device 를 통해 인터페이스를 제공합니다.

 - AudioFlinger가 library를 호출하는 과정은 아래와 같습니다.
 ```bash

 ```


# Code Analyse


 [-> *hardware/rockchip/audio/tinyalsa_hal/audio_hw.c* ]
```c
static struct hw_module_methods_t hal_module_methods = {
    .open = adev_open,
};

struct audio_module HAL_MODULE_INFO_SYM = {
    .common = {
        .tag = HARDWARE_MODULE_TAG,
        .module_api_version = AUDIO_MODULE_API_VERSION_0_1,
        .hal_api_version = HARDWARE_HAL_API_VERSION,
        .id = AUDIO_HARDWARE_MODULE_ID,
        .name = "Manta audio HW HAL",
        .author = "The Android Open Source Project",
        .methods = &hal_module_methods,
    },
};

static int adev_open(const hw_module_t* module, const char* name,
                     hw_device_t** device)
{
    struct audio_device *adev;
    int ret;
	
	// log : ALSA Audio Version: V1.1.0
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

 [-> *hardware/rockchip/audio/tinyalsa_hal/audio_hw.h* ]
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
adev_open(const hw_module_t* module, const char* name, hw_device_t** device)
	|
	+->	adev_open_init(struct audio_device *adev)
				

```
