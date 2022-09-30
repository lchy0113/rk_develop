#!/bin/bash

PACK_TOOL_DIR=RKTools/linux/Linux_Pack_Firmware

if [ -d $PACK_TOOL_DIR/rockdev/Image ]; then
	rm -rf $PACK_TOOL_DIR/rockdev/Image
fi

if [ -f $PACK_TOOL_DIR/rockdev/update.img ]; then
	rm -f $PACK_TOOL_DIR/rockdev/update.img 
fi

mkdir -p $PACK_TOOL_DIR/rockdev/Image/

cp -f u-boot/rk356x_spl_loader_v1.13.112.bin $PACK_TOOL_DIR/rockdev/Image/MiniLoaderAll.bin
cp -f out/target/product/rk3568_poc/parameter.txt $PACK_TOOL_DIR/rockdev/Image/parameter.txt
cp -f u-boot/uboot.img $PACK_TOOL_DIR/rockdev/Image/uboot.img
cp -f rkst/Image/misc.img $PACK_TOOL_DIR/rockdev/Image/misc.img
cp -f device/rockchip/common/vbmeta.img $PACK_TOOL_DIR/rockdev/Image/vbmeta.img
cp -f build_linux_4.19.232/boot.img $PACK_TOOL_DIR/rockdev/Image/boot.img
cp -f out/target/product/rk3568_poc/recovery.img $PACK_TOOL_DIR/rockdev/Image/recovery.img
cp -f device/rockchip/common/baseparameter/v2.0/baseparameter.img $PACK_TOOL_DIR/rockdev/Image/baseparameter.img
cp -f out/target/product/rk3568_poc/super.img $PACK_TOOL_DIR/rockdev/Image/super.img

cd $PACK_TOOL_DIR/rockdev && ./mkupdate.sh rk356x Image  
