# Memo 
-----
## Camera

gpio GPIO1_B0(DOOR_PCTL)

io -4 -w 0xfdc60008 0x00070000 ; io -4 -w 0xfe740008 0x01000100 ; io -4 -w 0xfe740000 0x01000100 ; 

iomux :
io -4 -w 0xfdc60008 0x00070000 ; 

out :
io -4 -w 0xfe740008 0x01000100 ; 

high :
io -4 -w 0xfe740000 0x01000100 ; 

am start -n com.android.camera2/com.android.camera.CameraActivity


v4l2-ctl -d /dev/video5 --set-fmt-video=width=1920,height=1080,pixelformat=NV12 --stream-mmap=3 --stream-to=/data/local/tmp/out.yuv --stream-skip=9 --stream-count=1 
v4l2-ctl -d /dev/video0 --set-fmt-video=width=960,height=480,pixelformat=NV12 --stream-mmap=3 --stream-to=/data/local/tmp/out.yuv --stream-skip=9 --stream-count=1 


ffplay out.yuv -f rawvideo -pixel_format nv12 -video_size 1920x1080
ffplay out.yuv -f rawvideo -pixel_format nv12 -video_size 960x480



// v4l2_dbg() log
echo 1 > /sys/module/video_rkcif/parameters/debug

// vb2 log : reqbuf, qbuf, dqbuf, ring buffer for VPU/ISP
echo 7 > /sys/module/videobuf2_core/parameters/debug

// v4l2 log : ioctl ....
echo 0x1f > /sys/class/video4linux/video0/dev_debug

-----
gpio GPIO0_B7(RST_CH710)
io -4 -w 0xfdc6000c 0x70000000 ; io -4 -w 0xfdd60008 0x80008000 ; io -4 -w 0xfdd60000 0x80008000

iomux : 
io -4 -w 0xfdc6000c 0x70000000

out : (io -r -4 0xfdd60008)
io -4 -w 0xfdd60008 0x80008000

high : enable (io -r -4 0xfdd60000)
io -4 -w 0xfdd60000 0x80008000

-----
gpio GPIO2_A6(SEL_SUB_VIDEO)
io -4 -w 0xfdc60024 0x07000000 ; io -4 -w 0xfe750008 0x00400040 ; io -4 -w 0xfe750000 0x00400000


iomux : (io -r -4 0xfdc60000 + 0x24)
io -4 -w 0xfdc60024 0x07000000 ; 

out : (io -r -4 0xfe750000 + 0x8)
io -4 -w 0xfe750008 0x00400040

low : (io -r -4 0xfe750000 + 0x00)
io -4 -w 0xfe750000 0x00400000

-----
VOP2_CLUSTER_WIN0_AFBCD_MODE 
addr : 0xfe040000 + 0x54
io -r -4 -l 20 0xfe040000

-----
<br/>

## android13 for rk3568
=====

# build command

```bash
#Android
build/envsetup.sh; lunch rk3568_t-userdebug

#kernel
cd kernel-5.10

## export clang to the environment
export PATH=../prebuilts/clang/host/linux-x86/clang-r450784d/bin:$PATH
alias msk='make CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1'

## build
msk ARCH=arm64 rockchip_defconfig android-13.config rk356x.config && msk ARCH=arm64 BOOT_IMG=../rockdev/Image-rk3568_t/boot.img rk3568-evb1-ddr4-v10.img


make ARCH=arm64 rockchip_defconfig android-13.config rk356x.config;
make ARCH=arm64 rk3568-evb1-ddr4-v10.img -j24

#uboot
./make.sh rk3568

#android
./build.sh A

#pack
./build.sh u
```
