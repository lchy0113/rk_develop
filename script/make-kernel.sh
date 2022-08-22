#!/bin/bash

export PATH=$ANDROID_BUILD_TOP/prebuilts/clang/host/linux-x86/clang-r416183b/bin:$PATH

ADDON_ARGS="CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1"
KERNEL_ARCH="arm64"
KERNEL_DEFCONFIG="rockchip_defconfig android-11.config non_debuggable.config disable_incfs.config"
KERNEL_DTS="rk3568-evb1-ddr4-v10"

echo "Start build kernel"
make clean ; 
make $ADDON_ARGS ARCH=$KERNEL_ARCH $KERNEL_DEFCONFIG
make $ADDON_ARGS ARCH=$KERNEL_ARCH $KERNEL_DTS.img -j32 
if [ $? -eq 0 ]; then
    echo "Build kernel ok!"
else
    echo "Build kernel failed!"
    exit 1
fi

KERNEL_DEBUG=arch/arm64/boot/Image
cp arch/arm64/boot/Image ../out/target/product/rk3568_s/kernel


echo "package resource.img with character images"
cd ../u-boot && ./scripts/pack_resource.sh ../kernel-4.19/resource.img && cp resource.img ../kernel-4.19/resource.img && cd -


# repack v2 boot
BOOT_CMDLINE="console=ttyFIQ0 firmware_class.path=/vendor/etc/firmware init=/init rootwait ro loop.max_part=7 androidboot.console=ttyFIQ0 androidboot.wificountrycode=KR androidboot.hardware=rk30board androidboot.boot_devices=fe310000.sdhci,fe330000.nandc androidboot.selinux=permissive buildvariant=userdebug"
SECURITY_LEVEL="2022-03-05"
mkbootfs -d ../out/target/product/rk3568_s/system ../out/target/product/rk3568_s/ramdisk | minigzip > ../out/target/product/rk3568_s/ramdisk.img 
mkbootimg --kernel ../out/target/product/rk3568_s/kernel --ramdisk ../out/target/product/rk3568_s/ramdisk.img --dtb ../out/target/product/rk3568_s/dtb.img --cmdline "$BOOT_CMDLINE" --os_version 12 --os_patch_level $SECURITY_LEVEL --second ./resource.img --header_version 2 --output ../out/target/product/rk3568_s/boot.img
