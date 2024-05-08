
LINUX
=====



<br/>  
<br/>  
<br/>  
<br/>  
<hr>  

# Trial Image 

## Download

 [Link](http://download.friendlyelec.com/nanopir5s)

## Login

 root / rockchip

 To change the password, please modify the following file:

```bash
 buildroot/configs/rockchip/network.config # branch: rockchip-kernel4.19
 buildroot/rockchip/base/common.config     # branch: rockchip-kernel5.10
```

<br/>  
<br/>  
<br/>  
<br/>  
<hr>  

# Download Source Code

## Buildroot for RK3568

```bash
$ mkdir buildroot-rk3568
$ cd buildroot-rk3568
$ repo init -u https://github.com/friendlyarm/buildroot_manifests \
    -b rockchip-kernel5.10 -m rk3568.xml  \
	    --no-clone-bundle
$ repo sync -j32 

```

# Compile Source Code

## setup development env

need a host PC running a 64-bit Ubuntu 20.04 system and run the following command on the PC:
 > rk3568_dev_priv:latest


```bash
$ wget -O - https://raw.githubusercontent.com/friendlyarm/build-env-on-ubuntu-bionic/master/install.sh 

```

## get help info

```bash
$ ./build.sh 
USAGE: ./build.sh <parameter>

# select board: 
  ./build.sh nanopi_r5s.mk
  ./build.sh nanopi_r5c.mk

# build module: 
  ./build.sh all                -build all
  ./build.sh uboot              -build uboot only
  ./build.sh kernel             -build kernel only
  ./build.sh buildroot          -build buildroot rootfs only
  ./build.sh sd-img             -pack sd-card image, used to create bootable SD card
  ./build.sh emmc-img           -pack sd-card image, used to write buildroot to emmc
# clean
  ./build.sh clean              -remove old images
  ./build.sh cleanall
```

## compile individual component

need to select an board.

```bash
# example NanoPi R5S 
$ ./build.sh nanopi_r5s.mk
```

### kernel

```bash
$ ./build.sh kernel
```
### uboot

```bash
$ ./build.sh uboot
```
### buildroot

```bash
$ ./build.sh buildroot
```

### generate image for emmc

```bash
$ sudo ./build.sh emmc-img
```

### generate image for sdcard

```bash
$ sudo ./build.sh sd-img

# Run the following for sdcard install:
$ sudo dd if=out/Buildroot_20211213_NanoPi-R4S_arm64_sd.img bs=1M of=/dev/sdX
```


# Customize Buildroot

structure of directory

```bash
buildroot-rk3568$ tree -d -L 1
.
├── app							-> rockchip app
├── buildroot					-> buildroot's source code
├── device						-> configuration file for board
├── external					-> external (ex. rockchip) buildroot package
├── kernel						-> kernel 
├── out -> scripts/sd-fuse/out
├── rkbin						-> rockchip loader binaries
├── scripts						-> script file for generating an image
├── toolchain
└── u-boot						-> u-boot

10 directories
```

## update buildroot configuration

 - list available configurations

```bash
$ cd buildroot
$ make list-defconfigs
```

The configuration of FriendlyELEC RK3399:
friendlyelec_rk3399_defconfig - Build for friendlyelec_rk3399

 - Update Configurations Using menuconfig

```bash
$ make friendlyelec_rk3399_defconfig
$ make menuconfig
$ make savedefconfig
$ diff .defconfig configs/friendlyelec_rk3399_defconfig 
$ cp .defconfig configs/friendlyelec_rk3399_defconfig
```

 - recompile

```bash
$ cd ../
$ ./build.sh buildroot
```


## customize file system

 put the file in device/friendlyelec/rk3599/common-files, then repackage  the img:

```bash

$ sudo ./build.sh sd-img
$ sudo ./build.sh emmc-img
```

## use cross compiler in sdk

version information :
gcc version 6.4.0 (Buildroot 2018.02-rc3-g4f000a0797)

```bash
$ export PATH=$PWD/buildroot/output/rockchip_rk3399/host/bin/:$PATH
$ aarch64-buildroot-linux-gnu-g++ -v
```

## cross compile qt program

```bash
$ git clone https://github.com/friendlyarm/QtE-Demo.git
$ cd QtE-Demo
$ ../buildroot/output/rockchip_rk3399/host/bin/qmake QtE-Demo.pro
$ make

```

<br/>  
<br/>  
<br/>  
<br/>  
<hr>  

# Reference 

 https://wiki.friendlyelec.com/wiki/index.php/Main_Page 
