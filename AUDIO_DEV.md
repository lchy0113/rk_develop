# AUDIO_DEV

 > private/audio

<br/>  
<br/>  
<br/>  
<br/>  

----
	
## io contorl - door

- SEL_DC : GPIO0_A6
  * High(Active)  
```bash
// set gpio
# io -4 -w 0xfdc20004 0x07000000

// set directiron to out
# io -4 -w 0xfdd60008 0x00400040 

// set value to high
# io -4 -w 0xfdd60000 0x00400040 

// set value to low
# io -4 -w 0xfdd60000 0x00400000 
```

<br/>  
<br/>  
<br/>  
<br/>  

----
	


## 📗 [analyse]audio_hal


### [analyse] audio package related

 device/rockchip/common/device.mk 파일에 packages가 선언됨.

 - audio interface

 
```bash
PRODUCT_PACKAGES += \ 
	android.hardware.audio@2.0-service \ 
	android.hardware.audio@7.0-impl \ 
	android.hardware.audio.effect@7.0-impl
```

> *android.hardware.audio@2.0-service, android.hardware.audio@7.0-impl naming rule*  
>  - android : Android System   
>  - hardware : hardware interface  
>  - audio : audio hardware interface   
>  - 2.0 or 7.0 : version  
>  - service : service는 인터페이스를 정의하고 해당 인터페이스를 구현하는 코드를 포함.   
>  - impl : service에서 정의한 인터페이스를 실제로 구현하는 클래스.   

<br/>

 *android.hardware.audio@2.0-service* : core HAL, effect HAL API를 포함.   
 	- core HAL : AudioFlinger가 오디오를 재생하고 오디오 라우팅을 제어하는데 사용하는 주API.  
	- effect HAL : effect framework가 오디오 effect를 제어하는 데 사용되는 API  
	- code : hardware/interfaces/audio/common/all-versions/default/service/  
 *android.hardware.audio@7.0-impl* : common HAL API와 관련 있음.  
 	- common HAL API : core 및 effect HAL 에서 공통적으로 사용되는 데이터 유형의 라이브러리. 인터페이스는 없으며 데이터 구조만 정의함.   
	- code : hardware/interfaces/audio/core/all-versions/default/  
  
  
 - audio lib

 안드로이드 시스템에서 사용되는 오디오 라이브러리.   
 오디오 하드웨어와 상호 작용하며, Android 운영체제의 오디오 기능을 제어하는데 사용.  
 오디오 출력 및 입력을 관리하며, 스피커, 헤드폰, 마이크 등과 상호작용.   

```bash
PRODUCT_PACKAGES += \
	audio_policy.$(TARGET_BOARD_HARDWARE) \ 
	audio.primary.$(TARGET_BOARD_HARDWARE) \
	...
```

 hardware/rockchip/audio/tinyalsa_hal/Android.mk 정의

 *audio.primary.rk30board.so*

### [analyse] audio interface

> upper layer (android.media)에서 사용할 수 있는 사운드 관련 프레임워크 관련 method를 audio 드라이버에게 연결하는 역할 담당.

아래 경로에 코드 위치
 - hardware/libhardware/include/hardware/ 

Audio HAL 관련 2개 interface 제공
 1. audio device의 main function을 제공하는 interface
 hardware/libhardware/include/hardware/audio.h

 2. effect(echo cancellation, noise suppression, downmixing, etc) interface 제공
 hardwrae/libhardware/include/hardware/audio_effect.h


<br/>  
<br/>  

----



### 📗 [analyse] tinyalsa

#### audio patch

 audio patch는 하나 이상의 source 를 하나 이상의 sink에 represent 하기 위해 사용됨.   

-  ex. 댐에 비유해 설명하면, 물의 유입구와 배출구는 여러 개 있을 수 있다.   
 물을 저장 및 방수하기 위해 유입구와 배출구는 하나일 수도 있고 여러개가 될 수도 있다.  
 실제 동작에서 1개 오디오 파일이 2개 speaker, headphone 으로 playback되거나, 2개의 mic가 left, right channel을 1개 오디오 파일에 record 하는 것.  
  
> android.permission.MODIFY_AUDIO_ROUTING permission 필요.  

 audio_patch 구조에는 2개 배열이 있으며, 각 포트는 audio_port이다.  
 stream, device 등 기본적으로 필요한 몇가지 기본 매개변수가 포함되어 있다.  

![](./images/AUDIO_DEV_02.png)


 각 audio_path는 APS에서 지정한 매개변수를 통해 Audioflinger에서 생성되며, Audioflinger 호출을 통해 AudioHAL에서 처리됨.   

 > (빨간색 선 생성과정, 파란색 선 처리 과정)

![](./images/AUDIO_DEV_03.png) 

----

 - **audio patch scenarios 1** : Mix, that is, stream, plays to multiple Devices, that is, hardware

![](./images/AUDIO_DEV_04.png)

 - 일반적으로 setParameters method를 대체하여 setOutputDevice에서 사용됨.

![](./images/AUDIO_DEV_05.png)

 - code flow

![](./images/AUDIO_DEV_06.png)

![](./images/AUDIO_DEV_07.png)

 <br/>
 <br/>

----

 - **audio patch scenarios 2** : Device to Mix, that is recording from hardware device to an audio track.

![](./images/AUDIO_DEV_08.png)

![](./images/AUDIO_DEV_09.png)

 - code flow

![](./images/AUDIO_DEV_10.png)

![](./images/AUDIO_DEV_11.png)

 <br/>
 <br/>

----

 - **audio patch scenarios 3** : Device to Device. 
 > encoder 처리 없이 AudioFlinger 

![](./images/AUDIO_DEV_12.png)

 - code flow

![](./images/AUDIO_DEV_13.png)


 두 장치 사이에서 사용되는 버퍼를 사용. 

![](./images/AUDIO_DEV_14.png)

 - code flow

![](./images/AUDIO_DEV_15.png)

<br/>
<br/>
<br/>
<br/>

-----

 - adev_create_audio_patch
```c
// playback
adev_create_audio_patch sum_sources:1,num_sinks:1,mix(d)->device(2),handle:0xffaefcf4
// system/media/audio/include/system/audio-hal-enums.h
// mix(d) : // audio port 가 sub mix 인 경우, audio port configuration structre 에 대한 확장.
// device(2) : AUDIO_DEVICE_OUT_SPEAKER // audio port가 hardware device인 경우, audio port configuration structure 에 대한 extension

// record
adev_create_audio_patch num_sources:1,num_sinks:1,device(80000004)->mix(1e),handle:0xedabba1c
// system/media/audio/include/system/audio-hal-enums.h
// device(80000004) : AUDIO_DEVICE_IN_BUILTIN_MIC // audio port가 hardware device인 경우, audio port configuration structure 에 대한 extension
// mix(1e) : // audio port 가 sub mix 인 경우, audio port configuration structre 에 대한 확장.
```

 - *AudioPatch는 AUDIO_DEVICE_API_VERSION_3_0 버전 이상에서 지원.*
   * 이하버전에서는 AudioPolicy에서 전달한 AudioPatch는 AudioFlinger에서 set_parameters로 변환되어 HAL로 전달. 

![](./images/AUDIO_DEV_01.png)

   * kvpairs는 createAudioPatch_l 에서 생성. 

```c

```

----

#### route 

alsa_route.c

```c
#define PCM_DEVICE0_PLAYBACK 0 
#define PCM_DEVICE0_CAPTURE  1
#define PCM_DEVICE1_PLAYBACK 2
#define PCM_DEVICE1_CAPTURE  3
#define PCM_DEVICE2_PLAYBACK 4
#define PCM_DEVICE2_CAPTURE  5

#define PCM_MAX PCM_DEVICE2_CAPTURE

struct pcm* 	mPcm[PCM_MAX + 1];
struct mixer* 	mMixerPlabyack;
struct mixer*	mMixerCapture;


route_pcm_open()
    |
    +-> route_init()
    |	/* route_init 시, mPcm[PCM_MAX]을 NULL로 초기화 */
    |
    +-> is_playback_route(route) 
    |   /* route value를 참고하여 playback, capture 여부 확인 */
    |
    +-> get_route_config(route)
    |   /** 
    |     * route_table에 사전 정의된 route value에 해당하는 값을 얻는다
    |     * sound_card, devices, controls 값이 포함 
    |     */
    |
    +-> mixer_open_legacy()
    |   /** 
    |     * mMixerPlayback, mMixerCapture을 업데이트
    |     * route_info->sound_card의 값이 1 인경우 0, 
    |     * 그렇지 않은 경우, cound_card id 값이 입력.
    |     * 
    |     * 1. /dev/snd/controlC0  장치 노드를 오픈(sound/core/control.c)
    |     * 2. SNDRV_CTL_IOCTL_ELEM_LIST ioctl 을 통해 control element list 를 가져온다.
    |     * 3. struct mixer 를 정의함.
    |     *    { 
    |     *      int fd;                            fd 값
    |     *      struct snd_ctl_elem_info *info;    control element List 저장.
    |     *      struct mixer_ctl *ctl;				control element value 저장
    |     *      unsigned count;                    control count값 
    |     *    }
    |     */
    |
    +-> route_set_controls(route)
    |    /**
    |      * route 값을 근거로 mixer 값을 가지고 set_controls를 진행.
    |      */ 
```

audio_hw.c
```c
adev_open_output_stream()
    |	/** 
    |     * adev_open_output_stream() 함수는 출력 장치를 열고, 해당 장치에 대한 출력 스트림을 생성.
    |     * audio_device_t device : 열고자하는 출력 장치를 지정.
    |     *                         정수형 상수로, 다양한 출력 장치를 나타냄.(ex. 스피커, 헤드폰, HDMI)
    |     *                         각 장치는 고유한 ID를 가지며, 이 ID를 사용하여 해당 장치를 선택
    |     * audio_output_flags_t flags : 출력 스트림에 대한 특정 플래그를 지정.
    |     *                              audio_output_flags_t는 비트필드로 특성을 조합할 수있다. 
    |     *                              AUDIO_OUTPUT_FLAG_DIRECT : 직접 출력 모드를 사용. 
    |     *                              AUDIO_OUTPUT_FLAG_PRIMARY : 기본 출력장치를 사용.
    |     */

```

-----


<br/>  
<br/>  
<br/>  
<br/>  

## 📖 [analyse][reference] Qualcomm Audio HAL audio path settings
  
1. **Audio block diagram overview**  
  
  
  
  
  
<br/>  
<br/>  
<br/>  
<br/>  

----
	



## ䷴  [develop]

 - regmap 

> regmap은 cache mechanism base로 운영된다. 
> register가 io명령을 통해 직접수행될 때, driver의 regmap cache를 비활성화 하지 않는 경우, 
> regmap node는 업데이트 된 레지스터를 반영하지 않는다.

```bash
/sys/kernel/debug/regmap/5-0018-ak7755-codec/register

// disable cache

# echo N > cache_only
[148833.374641] rockchip-i2s-tdm ff800000.i2s: debugfs cache_only=N forced:
syncing cache

# echo Y > cache_bypass
[148834.760274] rockchip-i2s-tdm ff800000.i2s: debugfs cache_bypass=Y forced
```




 - IO Control Path 를 사용하여 관련 GPO 제어
```bash
Card:0
  id iface dev sub idx num perms     type   name
     1 MIXER   0   0   0   1 rw        ENUM   IO Control Path: (0 STBY) { STBY=0, DOOR_CALL=1, DOOR_TALK=2, DOOR_SUB_TALK=3, VOIP_SUB_TALK=4 }
	  
```
