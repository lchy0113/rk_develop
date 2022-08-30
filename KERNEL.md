# KERNEL


<hr/>
<br/>
<br/>
<br/>
<hr/>



# 👨‍💻 develop kernel
> kernel 개발 이력을 정리합니다.

## config

kernel-4.19/arch/arm64/configs/rockchip_defconfig 
mkcombinedroot/configs/android-11.config
kernel/configs/android-4.19/non_debuggable.config
mkcombinedroot/configs/disable_incfs.config
device/kdiwin/nova/rk3568/kconfig.config 


## dts

rockchip/rk3568-poc-v00.dts

```bash
rockchip/rk3568-poc-v00.dts
	|	/* dtb image */
	+-> rockchip/rk3568-poc-v00.dtsi
	|	|	/* set peripheral device (csi, dsi, gmac, i2c, mmc, uart,,) */
	|	+-> rockchip/rk3568.dtsi
	|	|	|	/* define peripheral device address */
	|	|	+-> rockchip/rk3568-dram-default-timing.dtsi
	|	|	/* config dram init */
	|	+-> rockchip/rk3568-poc.dtsi
	|	/* set peripheral device (adc_keys, audiopwmout_diff, backlight, led, sound ,dsi, i2c,,)
	+-> rockchip/rk3568-android.dtsi
		/* set bootargs, debug interface, reserved_memory for dma pool and ramoops, vop */
```
