# DISPLAY
> rockchip display 에 대해 정리합니다.

# Introduction
## Display Pipe

```bash
[ LCD Controller ]  ->  [ Display Interface ]  ->  [ Panel ]
```

1) Rockchip 플랫폼의 LCD Controller 를 VOP(Video Output Processor)라고 합니다. 
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
