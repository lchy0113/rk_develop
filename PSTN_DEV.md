
PSTN module


<br/>  
<br/>  
<br/>  
<br/>  

<hr>


- [Reference](#reference)
- [Develop Driver](#develop-driver)
	- [Interface](#interface)
- [Develop API](#develop-api)

	

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

# develop_driver

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

(terminal side)
               TIP
               RING

(codec side)  
ECHO_LINE_OUT  PSTN_TX     +- PSTN_AUD
ECHO_LINE_IN   AUD_RX      +
			  

```

 - TIP, RING 은 PSTN에서 사용되는 2개의 전선. 
   전화선 연결과 음성 통화 기능 담당. 

   * **TIP** : 전화선에서 하나의 전선으로 전화 플러그의 금속 끝 부분에 연결.
   * **RING** : 전화선에서 하나의 전선으로 TIP 뒤에 있는 금속 링에 연결. 
   
   일반적으로 전화선을 꽂을때 플러그의 TIP이 먼저 연결되고, 그 다음에 RING이 연결.  
   TIP과 RING을 A와 B로 표현하기도 함.  
  
  
## HT9200

 serial mode 동작  


<br/>  
<br/>  
<br/>  
<br/>  

<hr>

# develop_api


