# DISPLAY
> rockchip display 에 대해 정리합니다.

# Introduction
## Display Pipe

```bash
[ LCD Controller ]  ->  [ Display Interface ]  ->  [ Panel ]
```

1) Rockchip 플랫폼의 LCD Controller 를 VOP(Video Output Processor)라고 합니다. 보통 1~2개의VOP를 가지고 있습니다. 2개의 VOP를 지원하는 경우, Dual Screen을 지원합니다. 
2) Rockchip 플랫폼의 칩은 HDMI/MIPI-DSI/RGB/LVDS/eDP/DP등을 포함하고 있습니다.


# Panel
## Documentation and source code
- kernel
	drivers/gpu/drm/panel/panel-simple.c
	Documentation/devicetree/bindings/display/panel/simple-panel.txt
- uboot (next-dev)
	drivers/video/drm/rockchip_panel.c

## DT binding
1) simple-panel(lvds/rgb/edp)
2) simple-panel-dsi(mipi-dsi)

# RGB
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

	ports	{
		port@1	{
			reg = <1>;
			rgb_out_panel: endpoint	{
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



# MIPI-DSI
- rk3568 : (1~8lanes, 1.2Gbps per lane)
	
## Documentation and source code
- Kernel (develop-4.19)
	drivers/gpu/drm/rockchip/dw-mipi-dsi.c
	drivers/phy/rockchip/phy-rockchip-inno-video-combo-phy.c
	drivers/phy/rockchip/phy-rockchip-inno-mipi-dphy.c
	Documentation/devicetree/bindings/display/rockchip/dw_mipi_dsi_rockchip.txt
	Documentation/devicetree/bindings/phy/phy-rockchip-inno-video-combo-phy.txt
	Documentation/devicetree/bindings/phy/phy-rockchip-inno-mipi-dphy.txt

- uboot (next-dev)
	drivers/video/drm/dw_mipi_dsi.c
	drivers/video/drm/inno_video_combo_phy.c
	drivers/video/drm/inno_mipi_phy.c

## DT Bindings
### Host

1) single-channel
```bash
[ VOP ] -> [ MIPI-DSI ] -> [ Panel ]
```

```dtb
&dsi0 {

}
```



---

# 👨<200d>💻 develop

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

```
// rockchip/rk3568.dtsi
vop : compatible = "rockchip,rk3568-vop"
vop_out
	|
	+-> vp0
	|	|
	|	+-> dsi0	// mipi-dsi
	|	+->	dsi1	// mipi-dsi
	|	+-> edp		// edp
	|	+-> hdmi	// hdmi
	|
	+-> vp1
	|	|
	|	+->	dsi0	// mipi-dsi
	|	+->	dsi1	// mipi-dsi
	|	+-> edp		// edp
	|	+-> hdmi	// hdmi
	|	+-> lvds	// lvds
	|
	+-> vp2
		|
		+->	vp2_out_lvds	// lvds
		+->	vp2_out_rgb: endpoint@1 {
				reg = <1>;
				remote-endpoint = <&rgb_in_vp2>;
			};

```

