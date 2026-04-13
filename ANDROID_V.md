 Android 15 (VanilaIceCream)
====

>> Android 15 SDK를 사용하여 RK3568 SoC 개발

<br/>
<br/>
<br/>
<br/>
<hr>

# Output Image

컴파일 이후 생성되는 파일 리스트.  
```bash
rockdev/Image-rk3568_u/
    +-> boot-debug.img
boot.img
config.cfg
dtbo.img
MiniLoaderAll.bin
misc.img
parameter.txt
pcba_small_misc.img
pcba_whole_misc.img


```



<br/>
<br/>
<br/>
<br/>
<hr>

# GKI 

<br/>
<br/>
<br/>
<hr>

## Download sources and build tools

```
mkdir android-kernel && cd android-kernel
repo init -u https://android.googlesource.com/kernel/manifest -b common-android14-6.1-2025-01
repo sync
```

<br/>
<br/>
<br/>
<br/>
<hr>

# Develop with dlkm strucutre

<br/>
<br/>
<br/>
<hr>

## mkcombinedroot

 Rockchip 전용 이미지 툴. 
 GKI 환경에서 vendor_boot.img 를 재패키징 하는 도구. 

<br/>
<br/>
<hr>

### 역할 
```
1. kernel 에서 .ko 생성
2. .ko를 mkcombinedroot로 복사
3. 기존 vendor_boot.img 복사 
4. mkgki4.sh 실행 -> ko 추가해서 vendor_boot.img 재생성.
5. flash
```

> 👉 driver를 kernel에 넣는 게 아니라 .ko로 분리해야 해서 사용된 기법? 

<br/>
<br/>
<hr>

### 내부 역할

```
// KO 파일 관리
mkcombinedroot/vendor_ramdisk/lib/modules/
// 로딩 순서 관리
mkcombinedroot/res/vendor_modules.load
mkcombinedroot/res/vendor_ramdisk_modules.load
```

<br/>
<br/>
<hr>

### tree

```
lchy0113@hsdev:~/platform/ANDROID/Rockchip_Android_V/mkcombinedroot$ tree 
.
├── bin
│   ├── blk_alloc_to_base_fs
│   ├── build_image
│   ├── depmod
│   ├── e2fsdroid
│   ├── minigzip
│   ├── mkbootfs
│   ├── mkbootimg
│   ├── mke2fs
│   ├── mke2fs.conf
│   ├── mkf2fsuserimg.sh
│   ├── mkuserimg_mke2fs
│   ├── repack_bootimg
│   ├── simg2img
│   └── unpack_bootimg
├── copy_moduls.sh
├── lib64
│   ├── libbase.so
│   ├── libc++.so
│   ├── libcutils.so
│   ├── libext4_utils.so
│   ├── liblog.so
│   └── libz.so
├── mkgki4.sh
├── modular_kernel.mk
├── patches
│   └── system_tools_mkbootimg.diff
├── prebuilts
│   └── boot-6.1.img
├── README
├── recovery_modules.load
├── res
│   ├── bootconfig
│   ├── debug_list.load
│   ├── file_contexts.bin
│   ├── ramdisk_modules.load
│   ├── recovery_gki.mk
│   ├── system_gki.mk
│   ├── vendor_gki.mk
│   ├── vendor_image_info.txt
│   ├── vendor_modules.load
│   ├── vendor_ramdisk_gki.mk
│   └── vendor_ramdisk_modules.load
├── tools
│   ├── DepSort.java
│   ├── gki_load_check.sh
│   └── search_3.sh
├── vendor_boot.img
└── vendor_ramdisk
    └── first_stage_ramdisk
        └── fstab.rk30board

8 directories, 43 files

```

<br/>
<br/>
<br/>
<br/>
<hr>

# rkr3 vs rkr4 

 - rkr4 : android-15.0.0_r17
 - rkr3 : android-15.0.0_r9

<br/>
<br/>
<br/>
<br/>
<hr>

# repo management

```bash
Normal download steps
Create new project folder.
$ mkdir nova; cd nova
Initialize repo project with specifiying the url of this repository.
$ repo init -u ssh://git@git.kdiwin.com:7999/hnnov/nova-manifests -m target/rk3576_v.xml
Synchronize repositories (-j option can be used in specifying count of jobs)
$ repo sync
```

 legacy structure
```bash
target/rk3576_v.xml
    |
    +-> aosp/android-15.0.9_r9.xml
    +-> socs/a15_rkr3.xml
    +-> nova/nova_device.xml
    +-> nova/nova_device_rockchip.xml
    +-> nova/nova_vendor.xml
```

 new structure
```bash
target/rk3576_v_rkr4.xml
target/rk3568_v_rkr4.xml
    |
    +-> target/android_v_rkr4.xml
        |
        +-> aosp/android-15.0.0_r17.xml    // revision이 r9 에서 업데이트
        +-> aosp/a15_rkr4.xml              // revision이 rkr3 에서 업데이트
        +-> nova/nova_device.xml
        +-> nova/nova_device_rockchip.xml
        +-> nova/nova_vendor.xml
```


<br/>
<br/>
<br/>
<br/>
<hr/>

# Note

<br/>
<br/>
<br/>
<hr>

## build rk3576_evb

```bash
lunch rk3576_u-ap4a-userdebug
```
