
PSTN module


<br/>  
<br/>  
<br/>  
<br/>  

<hr>


- [Reference](#reference)
- [Develop](#develop)
	- [Interface](#interface)
	

<br/>  
<br/>  
<br/>  
<br/>  

<hr>

# reference

<br/>  
<br/>  
<br/>  
<br/>  

<hr>

# develop

## interface

```bash
(soc)          (base)
GPIO2_D1       LINE_ON
GPIO3_C1       DTMF_CLK
GPIO3_C2       DTMF_EN      +-----------------+
GPIO3_A2       DTMF_DATA    | DTMF Generators |
GPIO3_D1       DTMF_DET     +-----------------+

GPIO2_C6       SEL_PSTN_AUD       (talk:high)
GPIO0_A5       SEL_ECHO_PSTN_AUD  (talk:high)

(terminal)
               TIP
               RING

(audio codec)  
ECHO_LINE_OUT  PSTN_TX     +- PSTN_AUD
ECHO_LINE_IN   AUD_RX      +
			  

```

 - TIP, RING 은 PSTN에서 사용되는 2개의 전선. 
   * 전화선 연결과 음성 통화 기능을 담당. 
