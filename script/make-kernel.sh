#!/bin/bash
export PATH=$ANDROID_BUILD_TOP/prebuilts/clang/host/linux-x86/clang-r416183b/bin:$PATH

source ../build/envsetup.sh >/dev/null
BUILD_PATH="../build_linux_4.19.232"
ADDON_ARGS="CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1"
KERNEL_ARCH="arm64"
TARGET_DEVICE=`get_build_var TARGET_PRODUCT`
KERNEL_DTS=`get_build_var PRODUCT_KERNEL_DTS`
PRODUCT_DEVICE=`get_build_var PRODUCT_DEVICE`
KERNEL_DEFCONFIG="rockchip_defconfig android-11.config non_debuggable.config disable_incfs.config rk3568_poc.config $TARGET_DEVICE.config"
NOVA_MODULE_KCONFIGS=`get_build_var NOVA_MODULE_KCONFIGS`

CONFIG_DIR="./kernel/configs"

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

if [ ! -f "$CONFIG_DIR/$TARGET_DEVICE.config" ] || [ ! -e "$CONFIG_DIR/$TARGET_DEVICE.config" ]; then
    echo "...link $TARGET_DEVICE.config"
    cd "$CONFIG_DIR"
    LINK_NAME="$TARGET_DEVICE.config"
    rm -f "$LINK_NAME"
    if [[ $TARGET_DEVICE == rk3568_poc* ]]; then
        ln -s "../../../device/kdiwin/test/rk3568_poc/configs/kconfig.$TARGET_DEVICE.config" "$LINK_NAME"
    else
        ln -s "../../../device/kdiwin/newjeans/$TARGET_DEVICE/configs/kconfig.config" "$LINK_NAME"
    fi
    echo "Created symlink: $LINK_NAME"
    cd -
fi

for KCONFIG in $NOVA_MODULE_KCONFIGS; do
    # Extract the base name of the kconfig file (e.g., wifi.kconfig -> wifi.config)
    BASENAME=$(basename "$KCONFIG" .kconfig).config
    LINK_NAME="$CONFIG_DIR/$BASENAME"

    # Remove existing link if it exists
    if [ -L "$LINK_NAME" ]; then
        rm -f "$LINK_NAME"
    fi

    # Create a symbolic link with a relative path
    ln -s "../../../$KCONFIG" "$LINK_NAME"
    echo "Created symlink: $LINK_NAME -> ../../../$KCONFIG"

    # Append the link to KERNEL_DEFCONFIG
    KERNEL_DEFCONFIG+=" $BASENAME"
done

if [ ! -d $BUILD_PATH ]; then
	mkdir $BUILD_PATH
	chmod 777 $BUILD_PATH
fi
echo "=============================================================="
echo $KERNEL_DEFCONFIG
echo "=============================================================="

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
make $ADDON_ARGS ARCH=$KERNEL_ARCH O=$BUILD_PATH $KERNEL_DTS.img -j32 

if [ $? -eq 0 ]; then
    echo "Build kernel ok!"
else
    echo "Build kernel failed!"
    exit 1
fi

echo ">>> package resource.img with character images"
## copy to aosp out directory
#cd ../u-boot && ./scripts/pack_resource.sh ../kernel-4.19/resource.img && cp resource.img ../kernel-4.19/resource.img && cd -
## copy to build directory
cd ../u-boot && ./scripts/pack_resource.sh $BUILD_PATH/resource.img && cp resource.img $BUILD_PATH/resource.img && cd -


# repack v2 boot
BOOT_CMDLINE="console=ttyFIQ0 firmware_class.path=/vendor/etc/firmware init=/init rootwait ro loop.max_part=7 androidboot.console=ttyFIQ0 androidboot.wificountrycode=KR androidboot.hardware=rk30board androidboot.boot_devices=fe310000.sdhci,fe330000.nandc androidboot.selinux=permissive buildvariant=userdebug"
SECURITY_LEVEL="2022-03-05"

mkbootfs -d ../out/target/product/$PRODUCT_DEVICE/system ../out/target/product/$PRODUCT_DEVICE/ramdisk | minigzip > ../out/target/product/$PRODUCT_DEVICE/ramdisk.img 

## copy to aosp out directory
#mkbootimg --kernel ../out/target/product/rk3568_poc/kernel --ramdisk ../out/target/product/rk3568_poc/ramdisk.img --dtb ../out/target/product/rk3568_poc/dtb.img --cmdline "$BOOT_CMDLINE" --os_version 12 --os_patch_level $SECURITY_LEVEL --second ./resource.img --header_version 2 --output ../out/target/product/rk3568_poc/boot.img
## copy to build directory
mkbootimg --kernel $BUILD_PATH/arch/arm64/boot/Image --ramdisk ../out/target/product/$PRODUCT_DEVICE/ramdisk.img --dtb $BUILD_PATH/arch/arm64/boot/dts/rockchip/$KERNEL_DTS.dtb --cmdline "$BOOT_CMDLINE" --os_version 12 --os_patch_level $SECURITY_LEVEL --second $BUILD_PATH/resource.img --header_version 2 --output $BUILD_PATH/boot.img


echo ">>> done."