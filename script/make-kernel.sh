#!/bin/bash
export PATH=$ANDROID_BUILD_TOP/prebuilts/clang/host/linux-x86/clang-r416183b/bin:$PATH

source ../build/envsetup.sh >/dev/null
BUILD_PATH="../build_linux_4.19.232"
ADDON_ARGS="CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1"
KERNEL_ARCH="arm64"
TARGET_DEVICE=`get_build_var TARGET_PRODUCT`
KERNEL_DTS=`get_build_var PRODUCT_KERNEL_DTS`
KERNEL_DEFCONFIG="rockchip_defconfig android-11.config non_debuggable.config disable_incfs.config kconfig.config $TARGET_DEVICE.config"

echo -e "TARGET_DEVICE:"$TARGET_DEVICE
echo -e "KERNEL_DTS:"$KERNEL_DTS

if [ -f ./logo.bmp.dev ]; then
	echo "...change bootlogo to develop"
	cp logo.bmp.dev logo.bmp
fi

if [ -f ./logo_kernel.bmp.dev ]; then
	echo "...change kernellogo to develop"
	cp logo_kernel.bmp.dev logo_kernel.bmp
fi

if [ ! -f ./kernel/configs/kconfig.config ]; then
	echo "...link kconfig.config"
	cd ./kernel/configs/
	ln -s ../../../device/kdiwin/test/common/configs/kconfig.config kconfig.config
	cd -
fi

if [ ! -f ./kernel/configs/$TARGET_DEVICE.config ]; then
	echo "...link $TARGET_DEVICE.config"
	cd ./kernel/configs/
	if [ -f ../../../device/kdiwin/newjeans/base/configs/kconfig_edpp04.config ]; then
		ln -s ../../../device/kdiwin/newjeans/base/configs/kconfig_edpp04.config $TARGET_DEVICE.config
	fi
	if [ -f ../../../device/kdiwin/test/rk3568_edpp04/configs/kconfig.config ]; then
		ln -s ../../../device/kdiwin/test/rk3568_edpp04/configs/kconfig.config $TARGET_DEVICE.config
	fi
	cd -
fi

# ./kernel-4.19/arch/arm64/configs/rockchip_defconfig 
# ./kernel/configs/android-11.config -> ../../../mkcombinedroot/configs/android-11.config
# ./kernel/configs/non_debuggable.config -> ../../../mkcombinedroot/configs/non_debuggable.config 
# ./kernel/configs/disable_incfs.config -> ../../../mkcombinedroot/configs/disable_incfs.config
# ./kernel/configs/kconfig.config -> ../../../device/company/test/rk3568_poc/kconfig.config
#KERNEL_DTS="rk3568-rgb-p01"
#KERNEL_DTS="rk3568-rgb-p02"
#KERNEL_DTS="rk3568-poc-v00"

if [ ! -d $BUILD_PATH ]; then
	mkdir $BUILD_PATH
	chmod 777 $BUILD_PATH
fi

if [ ! -f $BUILD_PATH/.config ]; then
	echo "...defconfig"
	make $ADDON_ARGS ARCH=$KERNEL_ARCH O=$BUILD_PATH distclean
	make $ADDON_ARGS ARCH=$KERNEL_ARCH O=$BUILD_PATH $KERNEL_DEFCONFIG
fi

if [ "$1" = "savedefconfig" ]; then
	make $ADDON_ARGS ARCH=$KERNEL_ARCH O=$BUILD_PATH $1
	exit
fi

if [ "$1" = "menuconfig" ]; then
	make $ADDON_ARGS ARCH=$KERNEL_ARCH O=$BUILD_PATH $1
	exit
fi

if [ "$1" = "modules" ]; then
	INSTALL_MOD_PATH=$BUILD_PATH make $ADDON_ARGS ARCH=$KERNEL_ARCH O=$BUILD_PATH modules -j32
	INSTALL_MOD_PATH=$BUILD_PATH make $ADDON_ARGS ARCH=$KERNEL_ARCH O=$BUILD_PATH modules_install -j32
#	INSTALL_MOD_PATH=$BUILD_PATH make $ADDON_ARGS ARCH=$KERNEL_ARCH O=$BUILD_PATH firmware_install -j32
	exit
fi

echo ">>> Start build kernel"
#make clean ; 
#make $ADDON_ARGS ARCH=$KERNEL_ARCH $KERNEL_DEFCONFIG
make $ADDON_ARGS ARCH=$KERNEL_ARCH O=$BUILD_PATH $KERNEL_DTS.img -j32 

if [ $? -eq 0 ]; then
    echo "Build kernel ok!"
else
    echo "Build kernel failed!"
    exit 1
fi

#KERNEL_DEBUG=arch/arm64/boot/Image
## copy to aosp out directory
#cp arch/arm64/boot/Image ../out/target/product/rk3568_poc/kernel
#cp arch/arm64/boot/dts/rockchip/rk3568-poc-v00.dtb ../out/target/product/rk3568_poc/dtb.img


echo ">>> package resource.img with character images"
## copy to aosp out directory
#cd ../u-boot && ./scripts/pack_resource.sh ../kernel-4.19/resource.img && cp resource.img ../kernel-4.19/resource.img && cd -
## copy to build directory
cd ../u-boot && ./scripts/pack_resource.sh $BUILD_PATH/resource.img && cp resource.img $BUILD_PATH/resource.img && cd -


# repack v2 boot
BOOT_CMDLINE="console=ttyFIQ0 firmware_class.path=/vendor/etc/firmware init=/init rootwait ro loop.max_part=7 androidboot.console=ttyFIQ0 androidboot.wificountrycode=KR androidboot.hardware=rk30board androidboot.boot_devices=fe310000.sdhci,fe330000.nandc androidboot.selinux=permissive buildvariant=userdebug"
SECURITY_LEVEL="2022-03-05"

mkbootfs -d ../out/target/product/$TARGET_PRODUCT/system ../out/target/product/$TARGET_PRODUCT/ramdisk | minigzip > ../out/target/product/$TARGET_PRODUCT/ramdisk.img 

## copy to aosp out directory
#mkbootimg --kernel ../out/target/product/rk3568_poc/kernel --ramdisk ../out/target/product/rk3568_poc/ramdisk.img --dtb ../out/target/product/rk3568_poc/dtb.img --cmdline "$BOOT_CMDLINE" --os_version 12 --os_patch_level $SECURITY_LEVEL --second ./resource.img --header_version 2 --output ../out/target/product/rk3568_poc/boot.img
## copy to build directory
mkbootimg --kernel $BUILD_PATH/arch/arm64/boot/Image --ramdisk ../out/target/product/$TARGET_DEVICE/ramdisk.img --dtb $BUILD_PATH/arch/arm64/boot/dts/rockchip/$KERNEL_DTS.dtb --cmdline "$BOOT_CMDLINE" --os_version 12 --os_patch_level $SECURITY_LEVEL --second $BUILD_PATH/resource.img --header_version 2 --output $BUILD_PATH/boot.img


echo ">>> done."
