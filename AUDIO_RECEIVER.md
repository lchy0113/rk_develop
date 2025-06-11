# AUDIO_RECEIVER
> AUDIO 관련 RECEIVER 장치 개발 문서
> Develop based on AK7755

<br/>
<br/>
<br/>
<hr>

## AUDIO MUX

```plane
                              +------------+
---(stream;ECHO_LINE_OUT)---> +             |
                              |             |
<--(stream;ECHO_LINE_IN)----- +             |
                              |             |
                              |             |
<--(stream;DTMF)------------> +             |
                              |             |
                              |             |
--(SEL_PSTN_AUD)------------> +             |
--(DTMF_EN)-----------------> +             |
--(SEL_LB_AUD)--------------> +             |
                              +-------------+

```

| **MODE**  | **SEL_PSTN_AUD** | **DTMF_EN** | **SEL_LB_AUD** |
|-----------|------------------|-------------|----------------|
| pstn_call |         H        |      L      |        L       |
| pstn_dial |         L        |      H      |        L       |
| loby_call |         L        |      L      |        H       |


<br/>
<br/>
<br/>
<hr>

## RECEIVER UNIT

```plane

```

RECEIVER_ENk

<br/>
<br/>
<br/>
<br/>
<hr>

# ETC

- peripheral pin

  * common
 SEL_LB_AUD       : GPIO0_A5(05)
 SEL_PSTN_AUD     : GPIO0_C6(22)
 DTMF_EN          : GPIO3_C2(114)

 RECEIVER_EN      : GPIO1_D5(61)
 HOOK_DET         : GPIO3_C6(118)


  * special
 LBAUDIOSEL_0     : GPIO1_A7(39) (high: enable)
 LBAUDIOSEL_1     : GPIO1_B3(43) (high: enable)
 LBAUDIOSEL_2     : GPIO0_A4(04) (high: enable)
 LBVIDEOSEL_0     : GPIO1_D7(63) (high: LB_VIDEO_IN -> LB_VIDEO_OUT, low: LB_VIDEO_IN -> LB_VIDEO)

<br/>
<br/>
<br/>
<br/>
<hr>

# Receiver: Headset observe

> Headset Observe 코드를 참고하여 Receiver 를 구현.

![](./images/AUDIO_RECEIVER_01.png)
  
 3.5mm 오디오 잭 연결 여부를 감지하기 위한 회로로, 잭이 연결되면 SoC의 GPIO 입력 핀으로 감지 신호(HP_DET_L_GPIO3_C2)가 LOW로 들어오도록 설계됨.   

  - HP_DET_L_GPIO3_C2 : 잭 연결 감지용 GPIO 입력 핀(Low Active)  
    * 잭 연결 시 : Low(GND)  
      + HP_DET_L_GPIO3_C2 라인은 내부 R7016(10KΩ) Pull-up 저항에 의해 HIGH 상태 유지  
      + SoC에서는 이 GPIO 입력을 **high** 로 인식함.  
    * 잭 미 연결 시 : High(Pull-Up)  
      + 잭 내부의 **Switch (DET 핀)**이 GND에 연결됨.  
      + *HP_DET_L_GPIO3_C2*핀이 GND 연결되어 LOW 상태.  
      + SoC에서는 이 GPIO 입력을 **low** 으로 감지. 
