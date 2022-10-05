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

	* dtbo.img 생성 과정. 
```bash
ifdef PRODUCT_DTBO_TEMPLATE // PRODUCT_DTBO_TEMPLATE 이 정의된 경우, (device/rockchip/common/build/rockchip/RebuildDtboImg.mk)
|
+->	PRODUCT_DTBO_TEMPLATE := $(LOCAL_PATH)/dt-overlay.in // (device/rockchip/rk356x/rk3568_s/rk3568_s.mk)
|											|
|											+-> device/rockchip/rk356x/rk3568_s/dt-overlay.in
|												/dts-v1/;
|												/plugin/;
|
|												&chosen {
|													bootargs_ext = "androidboot.boot_devices=${_boot_device}";
|												};
|												
|												&reboot_mode {
|													mode-bootloader = <0x5242C309>;
|													mode-charge = <0x5242C30B>;
|													mode-fastboot = <0x5242C303>;
|													mode-loader = <0x5242C301>;
|													mode-normal = <0x5242C300>;
|													mode-recovery = <0x5242C303>;
|												};
|
+-> out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/device-tree-overlay.dts
|	|
|	+->	
|
+-> out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/rebuild-dtbo.img
	|
	| recipe : rebuild_dts AOSP_DTC_TOOL AOSP_MKDTIMG_TOOL
	+-> out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/device-tree-overlay.dts
	|	| recipe : ROCKCHIP_FSTAB_TOOLS PRODUCT_DTBO_TEMPLATE
	|	+-> out/soong/host/linux-x86/bin/fstab_tools -I dts -i device/rockchip/rk356x/rk3568_s/dt-overlay.in \
	|		-p fe310000.sdhci,fe330000.nandc -f wait -o rockdev/richgold/device-tree-overlay.dts
	|
	+-> $ out/soong/host/linux-x86/bin/dtc -O dtb \
	|	-o out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/device-dtbo.dtb \
	|	out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/device-tree-overlay.dts 
	|
	+-> $ out/soong/host/linux-x86/bin/mkdtimg	\
		create out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/rebuild-dtbo.img \
		out/target/product/rk3568_evb/obj/FAKE/rockchip_dtbo_intermediates/device-dtbo.dtb
```
	* fstab_tools
		: fstab generator script
		```bash
		$ fstab_tools -h
		fstab_generator.py -I <type: fstab/dts> -i <fstab_template> -p <block_prefix> -d <dynamic_part_list> -f <flags> -c <chained_flags> -s <sdmmc_device> -o <output_file>
		```
	* dtc 
		: devicetree compiler 
	* mkdtimg
		: https://source.android.com/devices/architecture/dto/partitions?hl=ko#mkdtimg 


- parameter.txt
 README(device/rockchip/common/scripts/parameter_tools/README)에 의하면 parameter_tools에 의해 생성됩니다.
 device/rockchip/common/build/rockchip/RebuildParameter.mk 에 Makefile 정의 되어 있습니다.
```bash
$(rebuild_parameter) : $(PRODUCT_PARAMETER_TEMPLATE) $(ROCKCHIP_PARAMETER_TOOLS)
	@echo "Building parameter.txt $@."
	$(ROCKCHIP_PARAMETER_TOOLS) --input $(PRODUCT_PARAMETER_TEMPLATE) \
	--start-offset 8192 \
	--firmware-version $(BOARD_PLATFORM_VERSION) \
	--machine-model $(PRODUCT_MODEL) \
	--manufacturer $(PRODUCT_MANUFACTURER) \
	--machine $(PRODUCT_DEVICE) \
	--partition-list $(partition_list) \
	--output $(rebuild_parameter)


/*
sample
parameter_tools --input device/rockchip/common/scripts/parameter_tools/parameter.in \
	--firmware-version 12.0 \
	--machine-model rk3568_s \
	--manufacturer rockchip \
	--machine rk3568_s \
	--partition-list security:4M,uboot:4M,trust:4M,misc:4M,dtbo:8M,vbmeta:1M,boot:20M,recovery:64M,backup:384M,cache:384M,metadata:16M,super:3112M \
	--output out/target/product/rk3568_s/obj/FAKE/rockchip_parameter_intermediates/parameter.txt
*/
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

- update.img 이미지 생성

$ make -j32 rockdev
$ cd RKTools/linux/Linux_Pack_Firmware/rockdev
$ ./mkupdate.sh rk356x ../../../../rockdev/Image-rk3568_poc/

- TO DO LIST


- DONE LIST
	* SOONG_OST_OUT_EXECUTABLES := out/soong/host/linux-x86/bin
		android 이미지 빌드에 필요한 binary 저장 경로.
	* intermediates := out/target/product/rk3568_r/obj/FAKE/rockchip_dtbo_intermediates
		dtbo 관련 intermediates 이미지. 


