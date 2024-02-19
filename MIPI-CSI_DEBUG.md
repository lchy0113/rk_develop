# MIPI-CSI Debug

> mipi csi protocol 에 대해 개발을 하며 이슈를 정리.

## environment

  - board : rk3568
  - linux version : 4.19.232
  - android version : sdk 32
  - mipi device : tp2860
  - camera : ntsc


## check sequence

### driver load

디버깅 진행 시, 카메라 드라이버가 정상적으로 load 되었는지 확인. 
아래 로그를 통해 확인 가능.

*m00_b_tp2860 5-0044*

```bash
# media-ctl -p -d /dev/mediaX

(...)

- entity 26: rockchip-csi2-dphy0 (2 pads, 2 links)
             type V4L2 subdev subtype Unknown
             device node name /dev/v4l-subdev1
        pad0: Sink
                [fmt:UYVY2X8/960x480]
                <- "m00_b_tp2860 5-0044":0 [ENABLED]
        pad1: Source
                [fmt:UYVY2X8/960x480]
                -> "rockchip-mipi-csi2":0 [ENABLED]

- entity 31: m00_b_tp2860 5-0044 (1 pad, 1 link)
             type V4L2 subdev subtype Sensor
             device node name /dev/v4l-subdev2
        pad0: Source
                [fmt:UYVY2X8/960x480]
                -> "rockchip-csi2-dphy0":0 [ENABLED]
```

### mipi data

- linux command를 통해 mipi-csi 데이터 확인.

> mipi 채널에서 출력되는 데이터는 이미 YUV422 format의 이미지

```bash
# v4l2-ctl -d /dev/video0 --set-fmt-video=width=960,height=480,pixelformat=NV12 --stream-mmap=3 --stream-to=/data/local/tmp/out.yuv --stream-skip=1 --stream-count=1
[  133.759473] rkcif_mipi_lvds: stream[0] start streaming
[  133.759677] rkcif_mipi_lvds: Allocate dummy buffer, size: 0x00070800
[  133.759760] rockchip-mipi-csi2 fdfb0000.mipi-csi2: stream on, src_sd: 00000000946f2c82, sd_name:rockchip-csi2-dphy0
[  133.759779] rockchip-mipi-csi2 fdfb0000.mipi-csi2: stream ON
[  133.759820] rockchip-csi2-dphy0: dphy0, data_rate_mbps 148
[  133.759857] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream stream on:1, dphy0
[  133.759872] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream stream on:1, dphy0
[  133.798862] rockchip-mipi-csi2: ERR1: incorrect frame sequence detected, reg: 0x100,cnt:1
[  133.922430] rkcif_mipi_lvds: stream[0] start stopping
[  133.937817] rockchip-mipi-csi2 fdfb0000.mipi-csi2: stream off, src_sd: 00000000946f2c82, sd_name:rockchip-csi2-dphy0
[  133.937849] rockchip-mipi-csi2 fdfb0000.mipi-csi2: stream OFF
[  133.938893] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream_stop stream stop, dphy0
[  133.938921] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream stream on:0, dphy0
[  133.938953] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream stream on:0, dphy0
[  133.940628] rkcif_mipi_lvds: stream[0] stopping finished
```

- linux command를 통해 capture 데이터 확인

```bash
ffplay out.yuv -f rawvideo -pixel_format nv12 -video_size 1920x1080 
```



## error 종류

### error : capture 시, *select timeout* 에러 발생

- 원인 : 이러한 에러가 발생할 수 있는 원인은 MIPI 장치가 제대로 동작하지 않았기 때문이며, 에러는 아래와 같다.

```bash
# v4l2-ctl -d /dev/video0 --set-fmt-video=width=960,height=480,pixelformat=NV12 --stream-mmap=3 --stream-to=/data/local/tmp/out.yuv --stream-skip=1 --stream-count=1
[  133.759473] rkcif_mipi_lvds: stream[0] start streaming
[  133.759677] rkcif_mipi_lvds: Allocate dummy buffer, size: 0x00070800
[  133.759760] rockchip-mipi-csi2 fdfb0000.mipi-csi2: stream on, src_sd: 00000000946f2c82, sd_name:rockchip-csi2-dphy0
[  133.759779] rockchip-mipi-csi2 fdfb0000.mipi-csi2: stream ON
[  133.759820] rockchip-csi2-dphy0: dphy0, data_rate_mbps 148
[  133.759857] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream stream on:1, dphy0
[  133.759872] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream stream on:1, dphy0
[  133.798862] rockchip-mipi-csi2: ERR1: incorrect frame sequence detected, reg: 0x100,cnt:1
select timeout
[  133.922430] rkcif_mipi_lvds: stream[0] start stopping
[  133.937817] rockchip-mipi-csi2 fdfb0000.mipi-csi2: stream off, src_sd: 00000000946f2c82, sd_name:rockchip-csi2-dphy0
[  133.937849] rockchip-mipi-csi2 fdfb0000.mipi-csi2: stream OFF
[  133.938893] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream_stop stream stop, dphy0
[  133.938921] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream stream on:0, dphy0
[  133.938953] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream stream on:0, dphy0
[  133.940628] rkcif_mipi_lvds: stream[0] stopping finished
```

- 디버깅 : 드라이버가 정상 동작하는지 확인, MIPI채널 데이터가 통신되는지 확인. 

### error : frame 에러 발생

- 원인 : rockchip-mipi-csi2: ERR1: error matching frame start with frame end, reg: 0x10,cnt:2 출력

```bash
151366:[2024-02-06 15:52:54.198] [   47.431593] rockchip-mipi-csi2: ERR1: error matching frame start with frame end, reg: 0x10,cnt:2
151462:[2024-02-06 15:52:57.122] [   53.194337] rockchip-mipi-csi2: ERR1: error matching frame start with frame end, reg: 0x10,cnt:1
```

- 디버깅 : 불안정한 하드웨어에 의해 발생되므로 하드웨어 체크가 필요함.


### error : bandwidth lack

- 원인 : 이미지를 출력할때 또는 캡처할때, rkcif_mipi_lvds: ERROR: csi bandwidth lack, intstat:0x80000!!와 같은 에러가 표시.

```bash
# v4l2-ctl -d /dev/video0 --set-fmt-video=width=960,height=480,pixelformat=NV12 --stream-mmap=3 --stream-to=/data/local/tmp/out.yuv --stream-skip=1 --stream-count=1
[   38.623097] rkcif_mipi_lvds: stream[0] start streaming
[   38.623270] rkcif_mipi_lvds: Allocate dummy buffer, size: 0x00070800
[   38.623349] rockchip-mipi-csi2 fdfb0000.mipi-csi2: stream on, src_sd: 00000000946f2c82, sd_name:rockchip-csi2-dphy0
[   38.623365] rockchip-mipi-csi2 fdfb0000.mipi-csi2: stream ON
[   38.623401] rockchip-csi2-dphy0: dphy0, data_rate_mbps 148
[   38.623436] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream stream on:1, dphy0
[   38.623449] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream stream on:1, dphy0
[   38.670555] rkcif_mipi_lvds: ERROR: csi bandwidth lack, intstat:0x80000!!
```

- 디버깅 : 이 문제는 대부분 FRAME FORMAT 불일치로 인해 발생됨.  예를 들어 드라이버에서는 MEDIA_BUS_FMT_UYVY8_2X8을 사용하지만, 캡처 시에는 NV12를 사용한다.  
(NV12를 사용하는 Rockchip 의 이슈 일 수도..)
 NV16 과같은 포맷으로 변경하면 됨.
 **FPS이슈도 함께 디버깅 필요. 에러 발생 시, fps 가 낮아짐.**
  

### error : 간섭 오류

- 원인 : 데이터 채널이 방해를 받으면 rockchip-mipi-csi2: ERR1: crc errors, reg: 0x1000000, cnt:1 발생.

```bash
[2024-02-06 15:58:27.716] [   41.370025] rkcif_mipi_lvds: stream[0] start streaming
[2024-02-06 15:58:27.766] [   41.370643] rkcif_mipi_lvds: Allocate dummy buffer, size: 0x00070800
[2024-02-06 15:58:27.767] [   41.370750] rockchip-mipi-csi2 fdfb0000.mipi-csi2: stream on, src_sd: 000000008ed6bc4c, sd_name:rockchip-csi2-dphy0
[2024-02-06 15:58:27.768] [   41.370761] rockchip-mipi-csi2 fdfb0000.mipi-csi2: stream ON
[2024-02-06 15:58:27.769] [   41.370794] rockchip-csi2-dphy0: dphy0, data_rate_mbps 148
[2024-02-06 15:58:27.770] [   41.370803] _____csi2_dphy_s_stream_start(147)
[2024-02-06 15:58:27.772] [   41.370815] _____csi2_dphy_hw_stream_on(466) sensor->mbus.flags(0x112)
[2024-02-06 15:58:27.778] [   41.370859] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream stream on:1, dphy0
[2024-02-06 15:58:27.818] [   41.370868] rockchip-csi2-dphy csi2-dphy0: csi2_dphy_s_stream stream on:1, dphy0
[2024-02-06 15:58:27.819] [   41.443451] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:1
[2024-02-06 15:58:27.819] [   41.443488] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:2
[2024-02-06 15:58:27.823] [   41.443497] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:3
[2024-02-06 15:58:27.826] [   41.443527] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:4
[2024-02-06 15:58:27.826] [   41.443556] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:5
[2024-02-06 15:58:27.860] [   41.443594] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:6
[2024-02-06 15:58:27.861] [   41.443622] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:7
[2024-02-06 15:58:27.861] [   41.443646] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:8
[2024-02-06 15:58:27.861] [   41.443681] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:9
[2024-02-06 15:58:27.861] [   41.443706] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:10
[2024-02-06 15:58:27.862] [   41.443735] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:11
[2024-02-06 15:58:27.903] [   41.443767] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:12
[2024-02-06 15:58:27.903] [   41.443805] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:13
[2024-02-06 15:58:27.904] [   41.443824] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:14
[2024-02-06 15:58:27.904] [   41.443853] rockchip-mipi-csi2: ERR1: crc errors, reg: 0x10000000, cnt:15 
```

- 디버깅 : 하드웨어가 불안정하여 발생하는 현상이지만, 이러한 현상이 발생하더라도 영상이 정상적으로 출력됨.


### error : ROCKCHIP Micro VI 모듈 사용(vicap)

- 원인 : tp2860 모듈의 MIPI 채널에 연결된 신호는 YUV422 FORMAT이므로 ISP모듈을 거치지 않고 CIF 모듈을 통해서만 데이터를 출력하면 됨. video0 노드로 부터 이미지 출력시 에러가 발생됨.
- 디버깅 : 에러 원인은 VI 모듈이 기본적으로 DMA에서 데이터를 얻는 반면 CIF는 메모리에서 전송되므로 아래 그림과 같이 메모리에서 데이터를 얻기 위해 VI 모듈의 데이터 소스를 변경해야 한다.


### error : 이미지 분할 화면 문제

- 원인 : MIPI 채널이 간섭을 받으면 화면 분할 문제가 발생함. 재현시키기 위해서는 MIPI채널의 데이터 라인이나 Clock 라인에 간섭을 시키면 발생.
- 디버깅 : 2가지 디버깅 방법이 있다. 
  * 장치가 시작 할 때 분할 되는 현상이 발생되는 경우, 장치의 Soft Reset 이 설정되지 않았기 때문에 발생되는 케이스일 확률이 있음.
  * 동작 중, 분할 되는 현상이 발생되는 경우, 하드웨어 간섭으로 인해 화면 분할 현상이 발생됨. csi0, csi1, csi2 와 같은 모듈을 변경하여 디버깅 필요.

 추가로 vicap의 video 이상 감지 기능이 켜지지 않아서 발생되는 현상일수도 있음. 아래와 같은 방법으로 추가.
```dts
&rkcif_mipi_lvds {
	status = "okay";
		rockchip,cif-monitor = <3 2 10 1000 5>;
```

### error : ISP parameter 업데이트 문제

- 원인 : 카메라 드라이버의 이미지 해상도를 변경한 후에도, 아래와 같이 ISP는 이전 FORAMT 값이 저장되 있는 것을 확인.
- 디버깅 : 센서가 서로 다른 해상도의 Raw 데이터를 출력하도록 하려면 먼저 카메라 드라이버의 초기화 목록을 변경한 후, ISP가 다른 해상도의 이미지 포맷을 얻을 수 있도록  3A를 재 시작 해야함.  


### error : VICAP Abnormal 초기화

- 원인 : Rockchip 플랫폼은 드라이버에 exception reset Function을 추가했다. rk3568의 경우 drivers/media/platform 에 있음. 


## cif monitor 

 - rockchip,cif-monitor 구성정보  
```dts
&rkcif_mipi_lvds {
	status = "okay";
	/**
	  * rockchip,cif-monitor = <index0 index1 index2 index3 index4>;  
	  * parameters for do cif reset detecting: 
	  *
	  * index0 : monitor mode, 
	  * 	0 for idle,
	  * 	1 for continue,
	  * 	2 for trigger,
	  * 	3 for hotplug
	  * index1 : the frame id to start timer,
	  * 	min is 2
	  * index2 : frame num of monitoring cycle
	  * index3 : err time for keep monitoring 
	  * 	after finding out err (ms)
	  * index4 : csi2 err reference val for resetting
	  */
	rockchip,cif-monitor = <3 2 1 1000 5>;

	port {
		cif_mipi0_in: endpoint {
			remote-endpoint = <&mipi0_csi2_output>;
		};
	};
};

```  
   * **index0** : **timer monitor mode** reset mode 의 값을 갖으며, 4개의 mode가 있음.   
     + 0;No monitoring mode (idle) : default로 동작하는 mode( rockchip,cif-monitor node가 없는경우, 동작되는 mode)이며, vicap는 image anomaly monitoring을 수행하지 않는다.   
     + 1;continue mode : 1 값을 갖으며, mipi error 또는 실시간 에러 발생 등을 모니터링 하는데 사용한다. 에러 발생 시, vicap을 reset한다.  
       + detection 방법은 index1에 설정된 frame count에 도달하면 timer가 frame bit를 초기화 하고, 모니터링을 시작하며, 오류가 발생하면 해당 프레임 수에 도달 한 후 reset한다.
	   + timer는 index2 의해 설정된 사이클 수를 감지한다.  
	 + 2;trigger mode : csi2 progocol layer에서 오류가 발생한 경우에만 Trigger되며, index4에 의해 설정된 횟수에 도달하면 이미지 프레임 끝에서 trigger가 초기화 되고, vicap이 재실행 된다. index2 에 의해 설정된 사이클 수에 도달한 후 reset.
	 + 3;hot plug mode : car-to-machine chips를 대상으로 하며, device가 plug 및 unplug했을 때, 중단되는 문제를 해결하는데 사용. 이 mode에는 "continuous mode" 의 기능이 있다. 

	+ RKMODULE_SET_VICAP_RST_INFO 명령은 reset 활성화를 한 후, vicap은 RKMODULE_GET_VICAP_RST_INFO를 통해 정보를 얻은 후 Reset 작업을 트리거 한다.
   * **index1** : **timer triggered frame numer**  
              continue 또는 hotplug mode의 경우, *index1 에 정의된 frame data를 수집한 후*, 모니터링 타이머가 트리거 된다.   
   * **index2** : **timer frame number of monitor cycle**
              모니터링 타이머의 주기는 한 프레임 단위로 index2 프레임.   
   * **index3** : **timer error time for keeping(unit:ms) **
              reset 타이머의 매개변수. vicap csi2의 에러가 발생된 후, 정의된 시간 내 모니터링이 계속된다. 감지된 오류는 더이상 증가하지 않으면 재설정이 수행된다.    
   * **index4** : **timer csi2 error reference value for resetting**
              mipi csi 의  오류 발생 횟수를 설정하는데 사용. 이숫자에 도달하면 reset 이 트리거 된다.  
     
|     ROCKCHIP_CIF_USE_MONITOR     |                                                             Monitor 매커니즘 활성화 여부는 기본적으로 비활성화 되어 있음.                                                            |
|:--------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| ROCKCHIP_CIF_MONITOR_MODE        | Monitor 모드                                                                                                                                                                         |
| ROCKCHIP_CIF_MONITOR_START_FRAME | detect start이 시작되는 Frame을 지정. 0 값을 권장. 기본적으로 데이터 스트림은 켜져있을때 detecting됨.                                                                                |
| ROCKCHIP_CIF_MONITOR_CYCLE       | detection perio, in Frame.<br>frame rate가 25fps 이고, 구성이 4인 경우 detection period는 40ms*4.<br>프로젝트에 따라 detection interval을 조정.<br>detection period는 약 400ms 권장. |


```c
//code 

rkcif_reset_watchdog_timer_handler() 
 // watchdog timer handler 를 initialize


rkcif_detect_reset_event()
 // detect reset event 
```

