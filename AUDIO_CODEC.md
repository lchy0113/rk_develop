# AUDIO_CODEC

> AUDIO_CODEC 드라이버에 대한 문서.
>> AsahiKASEI 사 AK7755 를 레퍼런스 함.

 - block diagram
	![](images/AUDIO_CODEC_01.png)

 - Path and Sequence 
   * playback(digital to analog)
	   ![](images/AUDIO_CODEC_02.png)
	  + SDIN1 -> DSP -> DAC -> OUT1/OUT2


   * recoding(analog to digital)
	   ![](images/AUDIO_CODEC_03.png)
	  + IN1/IN3 -> ADC -> DSP -> SDOUT1


	
