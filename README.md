# rk_Develop
repository about developing the Rockchip Platform.

## Compiling command summary
- Android
```bash
build/envsetup.sh
lunch rk3568_r-userdebug
```
 * one key compiling
```bash
./build.sh -AUCKu
```
- kernel compiling
```bash
make ARCH=arm64 rockchip_defconfig rk356x_evb.config android-11.config
make ARCH=arm64 rk3568-evb7-ddr4-v10.img -j32
```
- uboot compoling
```bash
./make.sh rk3568
```

- build out
```bash

```



<hr />

## Document

 - Develop/Rockchip/Develop_data/
   * Rockchip_Developer_Guide_Android11_SDK_V1.1.4_EN.pdf
	: Android11 가이드 문서 (전체적인 내용 boot~android)
   * Rockchip RK3568B2 Datasheet V1.0-20210701.pdf
 	: RK3568B2 datasheet 

 - Develop/Rockchip/Develop_data/RK3568_DDR4_EVB/DOC/
   * Rockchip_RK3568_EVB1_User_Guide_V1.0_CN.pdf 
    : RK3568 evboard user guide

 - Develop/Rockchip/RKDocs/android/
   * Rockchip_Developer_Guide_*
	: Android feature 기능에 대한 설명 문서
 - Develop/Rockchip/RKDocs/common/
	: boot & device 설명 문서 

