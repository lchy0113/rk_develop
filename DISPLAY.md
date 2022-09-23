# DISPLAY
> rockchip display 에 대해 정리합니다.

# Introduction
## Display Pipe

```bash
[ LCD Controller ]  ->  [ Display Interface ]  ->  [ Panel ]
```

1) Rockchip 플랫폼의 LCD Controller 를 VOP(Video Output Processor)라고 합니다. 보통 1~2개의VOP를 가지고 있습니다. 2개의 VOP를 지원하는 경우, Dual Screen을 지원합니다. 
2) Rockchip 플랫폼의 칩은 HDMI/MIPI-DSI/RGB/LVDS/eDP/DP등을 포함하고 있습니다.


# Panel 장치
## Documentation and source code
- kernel
	drivers/gpu/drm/panel/panel-simple.c
	Documentation/devicetree/bindings/display/panel/simple-panel.txt
- uboot (next-dev)
	drivers/video/drm/rockchip_panel.c

## DT binding
1) simple-panel(lvds/rgb/edp)
2) simple-panel-dsi(mipi-dsi)

# RGB 인터페이스
## Documentation and source code
- uboot (next-dev)
	drivers/video/drm/rockchip_rgb.c
	drivers/video/drm/inno_video_combo_phy.c
	drivers/video/drm/inno_video_phy.c

## DT Bindings
### Host
```dtb
&rgb {
	status = "okay";

	ports {
		port@1 {
			reg = <1>;

			rgb_out_panel: endpoint {
				remote-endpoint = <&panel_in_rgb>;
			};
		};
	};
};
```

### PHY
```dtb
&video_phy	{
	status = "okay";
};
```


### Panel
```dtb
	panel {
		compatible = "simple-panel";
		bus-format = <MEDIA_BUS_FMT_RGB666_1X24_CPADHI>;
		backlight = <&backlight>;
		enable-gpios = <&gpio3 RK_PC5 GPIO_ACTIVE_LOW>;
		enable-delay-ms = <20>;
		reset-gpios = <&gpio0 RK_PB7 GPIO_ACTIVE_LOW>;
		reset-delay-ms = <10>;
		prepare-delay-ms = <20>;
		unprepare-delay-ms = <20>;
		disable-delay-ms = <20>;
		status = "okay";
		width-mm = <1024>;
		height-mm = <600>;
		bpc = <8>;

		display-timings {
			native-mode = <&timing0>;

			timing0: timing0 {
				clock-frequency = <51200000>;
				hactive = <1024>;
				vactive = <600>;
				hback-porch = <140>;
				hfront-porch = <160>;
				vback-porch = <20>;
				vfront-porch = <12>;
				hsync-len = <100>;
				vsync-len = <10>;
				hsync-active = <1>;
				vsync-active = <1>;
				de-active = <0>;
				pixelclk-active = <1>;
			};
		};

		ports {
			panel_in_rgb: endpoint {
				remote-endpoint = <&rgb_out_panel>;
			};
		};
	};
```

# HDMI 인터페이스

## DT Bindings
### Host
```dtb
&hdmi {
	status = "okay";
	rockchip,phy-table =
		<92812500  0x8009 0x0000 0x0270>,
		<165000000 0x800b 0x0000 0x026d>,
		<185625000 0x800b 0x0000 0x01ed>,
		<297000000 0x800b 0x0000 0x01ad>,
		<594000000 0x8029 0x0000 0x0088>,
		<000000000 0x0000 0x0000 0x0000>;
};

&hdmi_in_vp0 {
	status = "okay";
};

```

---
# baseparameter images 
> baseparameter 이미지는 rockchip 디스플레이 해상도, 디스플레이 효과 조정 구성 등과 같은 정보를 저장하는데 사용되며, 종료 및 재시작 후에도 이전과 동일한 효과가 유지 될 수 있도록 보장합니다. 

---

# 💻  개발 업무

rgb node : rockchip,rk3568-rgb
```dtb
// rockchip/rk3568.dtsi
	grf: syscon@fdc60000 {
		compatible = "rockchip,rk3568-grf", "syscon", "simple-mfd";
		reg = <0x0 0xfdc60000 0x0 0x10000>;
...

		rgb: rgb {
			compatible = "rockchip,rk3568-rgb";
			pinctrl-names = "default";
			pinctrl-0 = <&lcdc_ctl>;
			status = "disabled";

			ports {
				#address-cells = <1>;
				#size-cells = <0>;

				port@0 {
					reg = <0>;
					#address-cells = <1>;
					#size-cells = <0>;

					rgb_in_vp2: endpoint@2 {
						reg = <2>;
						remote-endpoint = <&vp2_out_rgb>;
						status = "disabled";
					};
				};
			};
		};

	}
```

driver : drivers/gpu/drm/rockchip/rockchip_rgb.c

---

# 📌 정리

rk3568 poc 의 디스플레이는 아래와 같이 구성되어 동작되고 있습니다. 

```
vop_out
	|
	+-> vp0 (0xfe040c00)
	|	|
	|	+-> hdmi interface
	|
	+-> vp2 (0xfe040e00)
		|
		+-> rgb interface
```

- hdmi to cvbs converter 
 hdmi to cvbs converter 를 통해 cvbs 출력을 내보내는 기능을 사용하기 위해서는 GPIO4_D2 핀을 high 로 세팅하면 동작
 
