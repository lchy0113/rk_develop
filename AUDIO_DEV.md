# AUDIO_DEV

<br/>  
<br/>  
<br/>  
<br/>  

----
	
## wallpad - door

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
	


## [analyse]audio_hal

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

----
	



## [develop]

 - IO Control Path 를 사용하여 관련 GPO 제어
```bash
Card:0
  id iface dev sub idx num perms     type   name
     1 MIXER   0   0   0   1 rw        ENUM   IO Control Path: (0 STBY) { STBY=0, DOOR_CALL=1, DOOR_TALK=2, DOOR_SUB_TALK=3, VOIP_SUB_TALK=4 }
	  
```
