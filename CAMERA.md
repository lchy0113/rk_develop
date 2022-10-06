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

```dtb
&i2c4 {
        status = "okay";
        XC7160: XC7160b@1b{
                status = "okay";
                compatible = "firefly,xc7160";
                reg = <0x1b>;
                clocks = <&cru CLK_CIF_OUT>;
                clock-names = "xvclk";
                power-domains = <&power RK3568_PD_VI>;
                pinctrl-names = "default";
                pinctrl-0 = <&cif_clk>;

                power-gpios = <&gpio4 RK_PB5 GPIO_ACTIVE_LOW>;
                reset-gpios = <&gpio0 RK_PD5 GPIO_ACTIVE_HIGH>;
                pwdn-gpios = <&gpio4 RK_PB4 GPIO_ACTIVE_HIGH>;

                firefly,clkout-enabled-index = <0>;
                rockchip,camera-module-index = <0>;
                rockchip,camera-module-facing = "back";
                rockchip,camera-module-name = "NC";
                rockchip,camera-module-lens-name = "NC";
                port {
                        xc7160_out: endpoint {
                                remote-endpoint = <&mipi_in_ucam4>;
                                data-lanes = <1 2 3 4>;
                        };
                };
        };
};
```

### configure logical dphy

- csi2_dphy0, csi2_dphy1/csi2_dphy2 은 동시에 사용할 수 없습니다. 
- csi2_dphy_hw 노드를 활성화 시킵니다.

```dtb
&csi2_dphy0 {
        status = "okay";
        /*
        * dphy0 only used for full mode,
        * full mode and split mode are mutually exclusive
        */
        ports {
                #address-cells = <1>;
                #size-cells = <0>;
                port@0 {
                        reg = <0>;
                        #address-cells = <1>;
                        #size-cells = <0>;
...
                        mipi_in_ucam4: endpoint@5 {
                                reg = <5>;
                                remote-endpoint = <&xc7160_out>;
                                data-lanes = <1 2 3 4>;
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


### configure isp

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


## Split Mode 설정

- link path:
	* sensor1->csi_dphy1->isp_vir0
	* sensor2->csi_dphy2->mipi_csi2->vicap->isp_vir1

### configure Sensor

```dtb
&i2c4 {
            status = "okay";
           gc2053: gc2053@37 { //IR
                status = "okay";
                compatible = "galaxycore,gc2053";
                reg = <0x37>;

                avdd-supply = <&vcc_camera>;
                power-domains = <&power RK3568_PD_VI>;
                clock-names = "xvclk";
                pinctrl-names = "default";

		clocks = <&pmucru CLK_WIFI>;
                pinctrl-0 = <&refclk_pins>;
                power-gpios = <&gpio0 RK_PD5 GPIO_ACTIVE_HIGH>;//IR_PWR_EN
                pwdn-gpios = <&gpio4 RK_PB5 GPIO_ACTIVE_LOW>;

                firefly,clkout-enabled-index = <1>;
                rockchip,camera-module-index = <0>;
                rockchip,camera-module-facing = "back";
                rockchip,camera-module-name = "YT-RV1109-2-V1";
                rockchip,camera-module-lens-name = "40IR-2MP-F20";
                port {
                        gc2053_out: endpoint {
                                        remote-endpoint = <&dphy1_in>;
                                        data-lanes = <1 2>;
                        };
                };
        };
        gc2093: gc2093b@7e{ //RGB
                status = "okay";
                compatible = "galaxycore,gc2093";
                reg = <0x7e>;

                avdd-supply = <&vcc_camera>;
                power-domains = <&power RK3568_PD_VI>;
                clock-names = "xvclk";
                pinctrl-names = "default";
                flash-leds = <&flash_led>;

                pwdn-gpios = <&gpio4 RK_PB4 GPIO_ACTIVE_HIGH>;

                firefly,clkout-enabled-index = <0>;
                rockchip,camera-module-index = <1>;
                rockchip,camera-module-facing = "front";
                rockchip,camera-module-name = "YT-RV1109-2-V1";
                rockchip,camera-module-lens-name = "40IR-2MP-F20";
                port {
                        gc2093_out: endpoint {
                                        remote-endpoint = <&dphy2_in>;
                                        data-lanes = <1 2>;
                        };
                };
        };

};
```

### configure csi2_dphy1/csi2_dphy2

```dtb
&csi2_dphy0 {
         status = "disabled";
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

&rkcif_mipi_lvds {
        status = "okay";
        port {
                cif_mipi_in: endpoint {
                        remote-endpoint = <&mipi_csi2_output>;
                        data-lanes = <1 2>;
                };
        };
};

&rkcif_mipi_lvds_sditf {
        status = "okay";
        port {
                mipi_lvds_sditf: endpoint {
                        remote-endpoint = <&isp1_in>;
                        data-lanes = <1 2>;
                };
        };
};
```


### configure isp

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
                        remote-endpoint = <&dphy1_out>;
                };
        };
};

&rkisp_vir1 {
        status = "okay";

        port {
                reg = <0>;
                #address-cells = <1>;
                #size-cells = <0>;

                isp1_in: endpoint@0 {
                        reg = <0>;
                        remote-endpoint = <&mipi_lvds_sditf>;
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
```


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

	
* rk3568-evb sensor 
	- ov5695(4-0036)

* reference code 
	- drivers/media/i2c/techpoint/techpoint_dev.c
