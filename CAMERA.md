# CAMERA 


## 1. CAMERA(mipi)

RK3568 플랫폼은 1개의 physical mipi csi2 dphy를 가지고 있습니다. physical mipi csi2 dphy는 2가지 모드를 선택할 수 있습니다.
 - full mode : 
	* csi2_dphy0 (csi2_dphy0, csi2_dphy1/csi2_dphy2 을 동시에 사용하지 못합니다.)
	* 최대 4 data lanes
	* 최대 2.5Gbps/lane 속도
 - split mode :
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


### 1.1 Full Mode 설정

- link path :
	* sensor->csi_dphy0->isp_vir0

#### 1.1.1 configure sensor

- camera sensor와 통신하는 i2c 버스 세팅. 

```dtb
&i2c4 {
	status = "okay";
	ov5695: ov5695@36 {
		status = "okay";
		compatible = "ovti,ov5695";
		reg = <0x36>;
		clocks = <&cru CLK_CIF_OUT>;
		clock-names = "xvclk";
		power-domains = <&power RK3568_PD_VI>;
		pinctrl-names = "default";
		pinctrl-0 = <&cif_clk>;
		reset-gpios = <&gpio3 RK_PB6 GPIO_ACTIVE_HIGH>;
		pwdn-gpios = <&gpio4 RK_PB4 GPIO_ACTIVE_HIGH>;
		rockchip,camera-module-index = <0>;
		rockchip,camera-module-facing = "back";
		rockchip,camera-module-name = "TongJu";
		rockchip,camera-module-lens-name = "CHT842-MD";
		port {
			ov5695_out: endpoint {
				remote-endpoint = <&mipi_in_ucam2>;
				data-lanes = <1 2>;
			};
		};
	};
};
```

#### 1.1.2 configure logical dphy

- csi2_dphy0, csi2_dphy1/csi2_dphy2 은 동시에 사용할 수 없습니다. 
- csi2_dphy_hw 노드를 활성화 시킵니다.

```dtb
&csi2_dphy0 {
	status = "okay";

	ports {
		#address-cells = <1>;
		#size-cells = <0>;
		port@0 {
			reg = <0>;
			#address-cells = <1>;
			#size-cells = <0>;

			mipi_in_ucam0: endpoint@1 {
				reg = <1>;
				remote-endpoint = <&ucam_out0>;
				data-lanes = <1 2 3 4>;
			};
			mipi_in_ucam1: endpoint@2 {
				reg = <2>;
				remote-endpoint = <&gc8034_out>;
				data-lanes = <1 2 3 4>;
			};
			mipi_in_ucam2: endpoint@3 {
				reg = <3>;
				remote-endpoint = <&ov5695_out>;
				data-lanes = <1 2>;
			};
		};
		port@1 {
			reg = <1>;
			#address-cells = <1>;
			#size-cells = <0>;

			csidphy_out: endpoint@0 {
				reg = <0>;
				remote-endpoint = <&isp0_in>;
			};
		};
	};
};


&csi2_dphy_hw {
   status = "okay";
};

&csi2_dphy1 {
        status = "disabled";
};

&csi2_dphy2 {
        status = "disabled";
};
```


#### 1.1.3 configure isp

- The remote-endpoint in rkisp_vir0 node should point to *csidphy_out*

```dtb
&rkisp {
   status = "okay";
};

&rkisp_mmu {
   status = "okay";
};

&rkisp_vir0 {
	status = "okay";

	port {
		#address-cells = <1>;
		#size-cells = <0>;

		isp0_in: endpoint@0 {
			reg = <0>;
			remote-endpoint = <&csidphy_out>;
		};
	};
};

```


### 1.2 Split Mode 설정


- link path:
	* sensor->csi_dphy0->isp_vir0
	or 
	* sensor1->csi_dphy1->isp_vir0
	* sensor2->csi_dphy2->mipi_csi2->vicap->isp_vir1

#### 1.2.1 configure Sensor

```dtb
&i2c4 {
	status = "okay";

	// MIPI
	tp2860: tp2860@44 {
			status = "okay";
			compatible = "techpoint,tp2860";
			reg = <0x44>;

			// resetPin assignment and effective level
			reset-gpios = <&gpio3 RK_PC6 GPIO_ACTIVE_LOW>;	/* low active */
			//sensor Related power domain enable
			power-domains = <&power RK3568_PD_VI>;
			
			// Module number, this number should not be repeated
			rockchip,camera-module-index = <0>;
			// Module orientation which are "back" and "front"
			rockchip,camera-module-facing = "back";
			// module name
			rockchip,camera-module-name = "E-QFN40";
			// lens name
			rockchip,camera-module-lens-name = "DP-VIN3";

			port {
				tp2860_out: endpoint {
					// mipi dphy port
					remote-endpoint = <&mipi_in_ucam0>;
					//slave-mode;
					// csi2 dphy lane name,2lane is <1 2>, 4lane is <1 2 3 4>
					data-lanes = <1 2>;

			};
		};
	};
};

```

#### 1.2.2 configure csi2_dphy0 (or csi2_dphy1/csi2_dphy2)

```dtb
&csi2_dphy0 {
	status = "okay";

	ports {
		#address-cells = <1>;
		#size-cells = <0>;
		port@0 {
			reg = <0>;
			#address-cells = <1>;
			#size-cells = <0>;

			mipi_in_ucam0: endpoint@1 {
				reg = <1>;
				// The port name of the sensor
				remote-endpoint = <&tp2860_out>;
				// csi2 dphy lane number
				data-lanes = <1 2>;
			};
		};
		port@1 {
			reg = <1>;
			#address-cells = <1>;
			#size-cells = <0>;

			csidphy_out: endpoint@0 {
				reg = <0>;
				remote-endpoint = <&isp0_in>;
			};	
		};
	};	
};


&csi2_dphy1 {
        status = "okay";
        /*
        * dphy1 only used for split mode,
        * can be used  concurrently  with dphy2
        * full mode and split mode are mutually exclusive
        */
        ports {
                #address-cells = <1>;
                #size-cells = <0>;

                port@0 {
                        reg = <0>;
                        #address-cells = <1>;
                        #size-cells = <0>;

                        dphy1_in: endpoint@1 {
                                        reg = <1>;
                                        remote-endpoint = <&gc2053_out>;
                                        data-lanes = <1 2>;
                        };
                };

                port@1 {
                        reg = <1>;
                        #address-cells = <1>;
                        #size-cells = <0>;

                        dphy1_out: endpoint@1 {
                                        reg = <1>;
                                        remote-endpoint = <&isp0_in>;
                        };
                };
        };
};

&csi2_dphy2 {
        status = "okay";
        /*
        * dphy2 only used for split mode,
        * can be used  concurrently  with dphy1
        * full mode and split mode are mutually exclusive
        */
        ports {
                #address-cells = <1>;
                #size-cells = <0>;

                port@0 {
                        reg = <0>;
                        #address-cells = <1>;
                        #size-cells = <0>;

                        dphy2_in: endpoint@1 {
                                        reg = <1>;
                                        remote-endpoint = <&gc2093_out>;
                                        data-lanes = <1 2>;
                        };
                };

                port@1 {
                        reg = <1>;
                        #address-cells = <1>;
                        #size-cells = <0>;

                        dphy2_out: endpoint@1 {
                                        reg = <1>;
                                        remote-endpoint = <&mipi_csi2_input>;
                        };
                };
        };
};

&csi2_dphy_hw {
      status = "okay";
};

&mipi_csi2 {
        status = "okay";

        ports {
                #address-cells = <1>;
                #size-cells = <0>;

                port@0 {
                        reg = <0>;
                        #address-cells = <1>;
                        #size-cells = <0>;

                        mipi_csi2_input: endpoint@1 {
                                        reg = <1>;
                                        remote-endpoint = <&dphy2_out>;
                                        data-lanes = <1 2>;
                        };
                };

                port@1 {
                        reg = <1>;
                        #address-cells = <1>;
                        #size-cells = <0>;

                        mipi_csi2_output: endpoint@0 {
                                        reg = <0>;
                                        remote-endpoint = <&cif_mipi_in>;
                                        data-lanes = <1 2>;
                        };
                };
        };
};
```


#### 1.2.3 configure isp

- The remote-endpoint in rkisp_vir0 node should point to dphy1_out

```dtb
&rkisp {
        status = "okay";
};

&rkisp_mmu {
        status = "okay";
};

&rkisp_vir0 {
	status = "okay";

	port {
		#address-cells = <1>;
		#size-cells = <0>;

		isp0_in: endpoint@0 {
			reg = <0>;
			remote-endpoint = <&csidphy_out>;
		};
	};
};

&rkcif_mmu {
    status = "okay";
};

&rkcif {
    status = "okay";
};
```

### 1.3 Related Directory(kernel)

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


### 1.4 Develop 

* hw Interface

| **GPIOs**         	| **IOMUX**         	| **address**       	|
|-------------------	|-------------------	|-------------------	|
| GPIO4_B2          	| RESERVE_SDA       	| 0xFDC60068[08:10] 	|
| GPIO4_B3          	| RESERVE_SCL       	| 0xFDC60068[14:12] 	|
| GPIO3_C6          	| MIPI_CAM0_RST     	| 0xFDC60054[10:8]  	|
| MIPI_CSI_RX_D0P   	| MIPI_CSI_RX_D0P   	| 0xFE870000        	|
| MIPI_CSI_RX_D0N   	| MIPI_CSI_RX_D0N   	| 0xFE870000        	|
| MIPI_CSI_RX_D1P   	| MIPI_CSI_RX_D1P   	| 0xFE870000        	|
| MIPI_CSI_RX_D1N   	| MIPI_CSI_RX_D1N   	| 0xFE870000        	|
| MIPI_CSI_RX_CLK0P 	| MIPI_CSI_RX_CLK0P 	| 0xFE870000        	|
| MIPI_CSI_RX_CLK0N 	| MIPI_CSI_RX_CLK0N 	| 0xFE870000        	|


* code 
	- [x] RKISP 드라이버는 프레임워크에서 제공하는 user control을 사용해야 합니다. 카메라 센서 드라이버는 다음 control functions을 구현해야 합니다. (CIS 드라이버 V4L2-controls list1 참조)
	- [x] PTZ 란 ? : cctv 에서 카메라 모듈을 제어하는 기능
	- [x] sensor와 cif가 바인딩되었는지 확인. : rkisp-vir0: Async subdev notifier completed 
	- [x] BLOB, YCbCr_420_888, IMPLEMENTATION_DEFINED
	- [x] rk3568 evb에서 CIF_CLKOUT 핀의 용도. 센서 동작중에 어떤 동작을 취하는지 확인 필요.  : 외부 크리스탈을 대체 하여 Soc 에서 발진


### 1.5 Camera 디버깅

 * v4l2-ctl 을 사용하여 카메라 프레임 데이터를 디버깅 합니다.

```bash
# camera test device
v4l2-ctl --verbose -d /dev/video0 --set-fmt-video=width=720,height=480,pixelformat='NV12' --stream-mmap=4 --set-selection=target=crop,flags=0,top=0,left=0,width=720,height=480 --stream-to=/data/out.yuv
```

 * debug 활성화
```bash
echo 1 > /sys/module/video_rkcif/parameters/debug
// vb2(vpu/isp)
echo 7 > /sys/module/videobuf2_core/parameters/debug
```

 * dumpsys CAMERA
	```bash
	dumpsys media.camera
	```

 * write register timing
```c
__ov5695_start_stream
	|	// preview 시작 시,
	+-> ret = ov5695_write_array(ov5695->client, ov5695->cur_mode->reg_list);


__ov5695_stop_stream
	| preview 종료 시,	
	+-> 
```


-----

## 2. CAMERA(dvp)

RK3568 플랫폼은 1개의 DVP 인터페이스를 가지고 있습니다. 

### 2.1 DVP 인터페이스 설정

#### 2.1.1 configure sensor

- camera sensor와 통신하는 i2c 버스 세팅. 

```dtb
&i2c2 {
	status = "okay";
	pinctrl-0 = <&i2c2m1_xfer>;

	gc2145: gc2145@3c{
		status = "okay";
		compatible = "galaxycore,gc2145";
		reg = <0x3c>;
		pinctrl-names = "default";
		clocks = <&cru CLK_CIF_OUT>;
		clock-names = "xvclk";
		power-domains = <&power RK3568_PD_VI>;
		pinctrl-0 = <&cif_clk &cif_dvp_clk &cif_dvp_bus16>;
		/* avdd-supply = <>; */
		/* dvdd-supply = <>; */
		/* dovdd-supply = <>; */
		/*power-gpios = <&gpio4 RK_PA6 GPIO_ACTIVE_HIGH>;*/
		reset-gpios = <&gpio4 RK_PA7 GPIO_ACTIVE_LOW>;
		pwdn-gpios = <&gpio4 RK_PA6 GPIO_ACTIVE_HIGH>;
		rockchip,camera-module-index = <1>;
		rockchip,camera-module-facing = "front";
		rockchip,camera-module-name = "CameraKing";
		rockchip,camera-module-lens-name = "Largan";
		port {
			gc2145_out: endpoint {
				remote-endpoint = <&dvp_in_bcam>;
			};
		};
	};
};

```

#### 2.1.2 configure logical dvp

- dvp 노드를 활성화 시킵니다.

```dtb
&rkcif_dvp {
	status = "okay";
	port {
		/* Parallel bus endpoint */
		dvp_in_bcam: endpoint {
			remote-endpoint = <&gc2145_out>;
			bus-width = <8>;
			vsync-active = <0>;
			hsync-active = <1>;
		};
	};
};
```


---

## 3. rkcif

rkcif 드라이버는 v4l2/media framework를 기반으로 구성된 하드웨어 장치 subdevices의(mipi dphy, sensor)  인터럽트 처리, 버퍼 관리, power 제어 등을 담당합니다.
  
 
![](./images/CAMERA_02.png)



---

## 4. isp 


 * ISP : Image Signal Processing  
	- ISP 는 아래 기능을 포함합니다.
		+ MIPI serial camera Interface
		+ Image Signal Processing
		+ Many Image Enhancement Blocks
		+ Crop
		+ Resize
	- block diagram
		![](./images/CAMERA_01.png)
---

## 5. techpoint tp2825 

> techpoint tp2826 코드 분석 자료 

* 코드 분석 

```c
static int __init tp2802_module_init(void)
	|
	+-> misc_regiser(&tp2802_dev);
	|	// register misc device
	|		static struct file_operations tp2802_fops =
	|	    {
	|			.owner = THIS_MODULE,
	|			.unlocked_ioctl = tp2802_ioctl,
	|			.open = tp2802_open,
	|			.release = tp2802_close
	|		};
	|		|
	|		+-> long tp2802_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
	|		|	/**
	|		|	  * TP2802_READ_REG:
	|		|	  * TP2802_WRITE_REG:
	|		|	  * TP2802_SET_VIDEO_MODE:
	|		|	  * TP2802_GET_VIDEO_MODE:
	|		|	  * TP2802_GET_VIDEO_LOSS:
	|		|	  * TP2802_SET_IMAGE_ADJUST:
	|		|	  * TP2802_GET_IMAGE_ADJUST:
	|		|	  * TP2802_SET_PTZ_DATA:
	|		|	  * TP2802_GET_PTZ_DATA:
	|		|	  * TP2802_SET_SCAN_MODE:
	|		|	  * TP2802_DUMP_REG:
	|		|	  * TP2802_FORCE_DETECT:
	|		|	  * TP2802_SET_BURST_DATA:
	|		|	  * TP2802_SET_VIDEO_INPUT:
	|		|	  * TP2802_SET_PTZ_MODE:
	|		|	  * TP2802_SET_RX_MODE:
	|		|	  * TP2802_SET_FIFO_DATA:
	|		+-> // open, release 는 특별한 기능 없음.
	+-> i2c_client_init();
	|	// register i2c device
	|
	+-> tp2802_comm_init();
	|	// tp2860 초기화 코드 동작(write register)
	|	// TP2825B_reset_default(chip, VIDEO_PAGE)
	|	// tp2802_set_video_mode(chip, mode, VIDEO_PAGE, STD_TVI)
	|		// mode : #define DEFAULT_FORMAT TP2802_1080P25(0x03) -> TP2802_NTSC(0x09)
	|		|
	|		+-> tp2802_set_work_mode_NTSC(chip)
	|	// TP2860_output(chip);
	|	// TP2825B_RX_init(chip, PTZ_RX_TVI_CMD);
	printk("TP2825B Driver Init Successful!\n");

```

---

## Note

