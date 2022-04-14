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

