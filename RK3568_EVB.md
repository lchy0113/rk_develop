RK3568_EVB
=====

# Code compiling

- One key compiling command
```bash

./build.sh -UKAup
( WHERE: -U = build uboot
-C = build kernel with Clang
-K = build kernel
-A = build android
-p = will build packaging in IMAGE
-o = build OTA package
-u = build update.img
-v = build android with 'user' or 'userdebug'
-d = huild kernel dts name
-V = build version
-J = build jobs
------------you can use according to the requirement, no need to record
uboot/kernel compiling commands------------------
)
============================================================
Please remember to set the environment variable before using the one key
compiling command, and select the platform to be compiled, for example:
source build/envsetup.sh
lunch rk3568_s-userdebug
============================================================
```

- Android
```bash
build/envsetup.sh
lunch rk3568_s-userdebug
```

- one key compiling
```bash
./build.sh -AUCKu
```


- kernel compiling
```bash
make ARCH=arm64 rockchip_defconfig rk356x_evb.config android-11.config; 
make ARCH=arm64 rk3568-evb7-ddr4-v10.img -j24
```

- u-boot compiling
```bash
./make.sh rk3568
```
