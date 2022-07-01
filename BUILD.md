# BUILD
Rockchip rk3567의 build.sh에 의해 생성된 파일은 아래와 같습니다. 

```bash
▾ Image-rk3568_r/
    baseparameter.img*
    boot-debug.img*
    boot.img*
    config.cfg*
    dtbo.img*
    MiniLoaderAll.bin*
    misc.img*
    parameter.txt*
    pcba_small_misc.img*
    pcba_whole_misc.img*
    recovery.img*
    resource.img*
    super.img*
    uboot.img*
    vbmeta.img*
```

- dtbo.img
```bash
// dtbo image
BOARD_DTBO_IMG=$OUT/rebuild-dtbo.img
cp -a $BOARD_DTBO_IMG $IMAGE_PATH/dtbo.img

```

- 기타 이미지
```bash
// resource image
copy_images $KERNEL_PATH/resource.img $IMAGE_PATH/resource.img
// boot.img
copy_images_from_out boot.img
copy_images_from_out boot-debug.img
copy_images_from_out vendor_boot.img
copy_images_from_out vendor_boot-debug.img

// recovery image
copy_images_from_out recovery.img

// super image
copy_images_from_out super.img

/ userdata image
copy_images $OUT/userdata.img $IMAGE_PATH/data.img

// vbmeta image
cp -a device/rockchip/common/vbmeta.img $IMAGE_PATH/vbmeta.img

// misc image
cp -a rkst/Image/misc.img $IMAGE_PATH/misc.img


// u-boot image
cp -a $UBOOT_PATH/uboot.img $IMAGE_PATH/uboot.img

// miniloader image
cp -a $UBOOT_PATH/*_loader_*.bin $IMAGE_PATH/MiniLoaderAll.bin

// config image
cp -a ./rk356x/rk3568_s/config.cfg $IMAGE_PATH/config.cfg


// parameter image
cp -a $OUT/parameter.txt $IMAGE_PATH/parameter.txt


// baseparameter image
cp -a device/rockchip/common/baseparameter/v2.0/baseparameter.img $IMAGE_PATH/baseparameter.img
```



- TO DO LIST


- DONE LIST
	* SOONG_OST_OUT_EXECUTABLES := out/soong/host/linux-x86/bin
		android 이미지 빌드에 필요한 binary 저장 경로.
	* intermediates := out/target/product/rk3568_r/obj/FAKE/rockchip_dtbo_intermediates
		dtbo 관련 intermediates 이미지. 


