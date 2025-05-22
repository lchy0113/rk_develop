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
