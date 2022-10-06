# CAMERA 

RK3568 플랫폼은 1개의 physical mipi csi2 dphy를 가지고 있습니다. physical mipi csi2 dphy는 2가지 모드를 선택할 수 있습니다.
1. full mode : 
	* csi2_dphy0 (csi2_dphy0, csi2_dphy1/csi2_dphy2 을 동시에 사용하지 못합니다.)
	* 최대 4 data lanes
	* 최대 2.5Gbps/lane 속도
2. split mode :
	* csi2_dphy1 and/or csi2_dphy2 (csi2_dphy0 을 이 모드에서는 사용 할수 없습니다.)
	* csi2_dphy1과 csi2_dphy2 는 동시에 사용 가능합니다.
	* csi2_dphy1과 csi2_dphy2 는 동시에 사용하는경우, 최대 2 data lanes 을 사용가능 합니다.
	* csi2_dphy1은 physical dphy lane0/lane1 과 매핑 됩니다.
	* csi2_dphy2은 physical dphy lane2/lane3 과 매핑 됩니다.
	* 최대 2.5Gmps/lane 속도
	
| **Option**   	| **Sensor Lane**                 	| **Interface**                                                                                        	|
|--------------	|---------------------------------	|------------------------------------------------------------------------------------------------------	|
| _full mode_  	| sensor1 x4lane                  	| MIPI_CSI_RX_D0, MIPI_CSI_RX_D1, MIPI_CSI_RX_D2, MIPI_CSI_RX_D3, MIPI_CSI_RX_CLK0                     	|
| _split mode_ 	| sensor1 x2lane + sensor2 x2lane 	| MIPI_CSI_RX_D0, MIPI_CSI_RX_D1, MIPI_CSI_RX_CLK0, & MIPI_CSI_RX_D2, MIPI_CSI_RX_D3, MIPI_CSI_RX_CLK1 	|


## Full Mode 설정


### configure sensor

- camera sensor와 통신하는 i2c 버스 세팅. 

```bash

```

### configure logical dphy

- csi2_dphy0, csi2_dphy1/csi2_dphy2 은 동시에 사용할 수 없습니다. 
- csi2_dphy_hw 노드를 활성화 시킵니다.

```bash

```


### configure isp

- The remote-endpoint in rkisp_vir0 node should point to csidphy_out

```bash

```


## Split Mode 설정

- link path:
	* sensor1->csi_dphy1->isp_vir0
	* sensor2->csi_dphy2->mipi_csi2->vicap->isp_vir1

### configure Sensor

### configure csi2_dphy1/csi2_dphy2

### configure isp

- The remote-endpoint in rkisp_vir0 node should point to dphy1_out

```bash
```

## Related Directory(kernel)

```bash
Linux Kernel-4.19
|-- arch/arm/boot/dts 								#DTS configuration file
|-- drivers/phy/rockchip
|	|-- phy-rockchip-mipi-rx.c						#mipi dphy driver
|	|-- phy-rockchip-csi2-dphy-common.h
|	|-- phy-rockchip-csi2-dphy-hw.c
|	|-- phy-rockchip-csi2-dphy.c
|-- drivers/media
|	|-- platform/rockchip/cif 						#RKCIF driver
|	|-- platform/rockchip/isp 						#RKISP driver
|	|	|-- dev 									#includes probe, asynchronous register clock, pipeline, iommu and media/v4l2 framework
|	|	|-- capture									#includes mp/sp/rawwr configuration and vb2, frame interrupt handle
|	|	|-- dmarx 									#includes rawrd configuration and vb2, frame interrupt handle
|	|	|-- isp_params 								#3A-related parameters
|	|	|-- isp_stats 								#3A-related statistics
|	|	|-- isp_mipi_luma 							#mipi luminance data statistics
|	|	|-- regs 									#register-related read/write operation
|	|	|-- rkisp 									#isp subdev and entity register
|	|	|-- csi	 									#csi subdev and mipi configuration
|	|	|-- bridge 									#bridge subdev,isp and ispp interaction bridge
|	|-- platform/rockchip/ispp 						#rkispp driver
|	|	|-- dev 									#includes probe, asynchronous register, clock, pipeline, iommu and media/v4l2 framework
|	|	|-- stream 									#includes 4-channel video output configuration and  vb2, frame interrupt handle
|	|	|-- rkispp 									#ispp subdev and entity register
|	|	|-- params	 								#TNR/NR/SHP/FEC/ORB parameters
|	|	|-- stats 									#ORB statistics
|-- i2c
|	|-- os04a10.c									#CIS(cmos image sensor) driver	
```



## Camera 디버깅

v4l2-ctl 을 사용하여 카메라 프레임 데이터를 디버깅 합니다.

```bash
# camera test device
v4l2-ctl --verbose -d /dev/video0 --set-fmt-video=width=1920,height=1080,pixelformat='NV12' --stream-mmap=4 --set-selection=target=crop,flags=0,top=0,left=0,width=1920,height=1080 --stream-to=/data/out.yuv
```


```bash
# host pc
ffplay -f rawvideo -video_size 1920x1080 -pix_fmt nv12 out.yuv
# 


---

## Note
* CIF : 
* ISP : Image Signal Processing  
	- ISP 는 아래 기능을 포함합니다.
		+ MIPI serial camera Interface
		+ Image Signal Processing
		+ Many Image Enhancement Blocks
		+ Crop
		+ Resize
	- block diagram
		![](./images/CAMERA_01.png)

	
