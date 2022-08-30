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
	|
	+-> rockchip/rk3568-poc-v00.dtsi
	|	|
	|	+-> rockchip/rk3568.dtsi
	|	|	|
	|	|	+-> rockchip/rk3568-dram-default-timing.dtsi
	|	|
	|	+-> rockchip/rk3568-poc.dtsi
	|
	+-> rockchip/rk3568-android.dtsi
```
