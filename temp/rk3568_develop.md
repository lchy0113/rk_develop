# Memo 
-----
## Audio

```bash
# pctl
adb shell "echo 40 > sys/class/gpio/export ; echo "out"  > /sys/class/gpio/gpio40/direction ; echo 1 > /sys/class/gpio/gpio40/value"

# push lib audio
adb root ; adb remount ; adb push .\audio.primary.rk30board.so /vendor/lib/hw
```

<br/>
<br/>
<br/>
<br/>
<br/>

-----

## Camera


[rk3568]
	tp2860_out[tp2860]		-	dphy2_in[csi2_dphy2]	-	csidphy_out[csi2_dphy0]		-	mipi_csi2_input[mipi_csi2]	-	mipi_csi2_output[mipi_csi2]	-	cif_mipi_in[rkcif_mipi_lvds]

[rk3566]
	ov02k10_out[ov02k10]	-	dphy2_in[csi2_dphy2]		-	mipi_csi2_input[csi2_dphy2]	-	mipi_csi2_input[mipi_csi2]	-	mipi_csi2_output[mipi_csi2]	-	cif_mipi_in[rkcif_mipi_lvds]
	
	

[m00_b_tp2860 5-0044] -> [rockchip-csi2-dphy1] -> [rockchip-mipi-csi2] -> [stream_cif_mipi_id0]
[m00_b_ov5695 4-0036] -> [rockchip-csi2-dphy1] -> [rockchip-mipi-csi2]/dev/v4l-subdev0 -> [stream_cif_mipi_id0]/dev/video0


io -4 -w 0xfdc60008 0x00070000 ; io -4 -w 0xfe740008 0x01000100 ; io -4 -w 0xfe740000 0x01000100 ; v4l2-ctl -d /dev/video1 --set-fmt-video=width=720,height=480,pixelformat=NV12 --stream-mmap=3 --stream-to=/data/local/tmp/out.yuv --stream-skip=1 --stream-count=1

gpio GPIO1_B0(DOOR_PCTL)

io -4 -w 0xfdc60008 0x00070000 ; io -4 -w 0xfe740008 0x01000100 ; io -4 -w 0xfe740000 0x01000100 ; 

iomux :
io -4 -w 0xfdc60008 0x00070000 ; 

out :
io -4 -w 0xfe740008 0x01000100 ; 

high :
io -4 -w 0xfe740000 0x01000100 ; 

am start -n com.android.camera2/com.android.camera.CameraActivity

```bash
/** 
  * code flow : TP28xx_TP2920_MDIN400 project 
  *	ManVidRes : TP2802_NTSC
  * ManVidStd : STD_TVI
  */
TP28xx_Init(void)
    |
    V
set (tp2860_1080P30_2lane_dataset)
    |
    V
set Set_VidRes(TP2802_NTSC, ,0)
	TP2855_SYSCLK_CVBS()
	index=34 
	tp28xx_write_byte()
 
```
/// comment

[1ed643d] : camera api success
[5aaecf9] : camera api fail
[7f7929a] : 

v4l2-ctl  -d /dev/v4l-subdev2  --set-ctrl=test_pattern=1
v4l2-ctl -d /dev/v4l-subdev3 --set-fmt-video=width=720,height=480,pixelformat=NV12 --stream-mmap=3 --stream-to=/data/local/tmp/out.yuv --stream-skip=1 --stream-count=1 
v4l2-ctl -d /dev/video0 --set-fmt-video=width=720,height=480,pixelformat=NV12 --stream-mmap=3 --stream-to=/data/local/tmp/out.yuv --stream-skip=1 --stream-count=1 
v4l2-ctl -d /dev/video0 --set-fmt-video=width=1920,height=1080,pixelformat=NV12 --stream-mmap=3 --stream-to=/data/local/tmp/out.yuv --stream-skip=1 --stream-count=1 
v4l2-ctl -d /dev/video1 --set-fmt-video=width=720,height=480,pixelformat=YUYV --stream-mmap=3 --stream-to=/data/local/tmp/out.yuv --stream-skip=1 --stream-count=1 
v4l2-ctl -d /dev/video0 --set-fmt-video=width=720,height=480,pixelformat=NV12 --stream-mmap=3 --stream-to=/data/local/tmp/out.yuv --stream-skip=100 --stream-count=1 --stream-poll
v4l2-ctl -d /dev/video0 --set-fmt-video=width=720,height=480,pixelformat=YUYV --stream-mmap=3 --stream-to=/data/local/tmp/out.yuv --stream-skip=100 --stream-count=1 --stream-poll
v4l2-ctl -d /dev/video1 --set-fmt-video=width=720,height=480,pixelformat=YUYV --stream-mmap=3 --stream-skip=1 --stream-to=/data/local/tmp/out.yuv --stream-count=1 --stream-poll
[rockchip] 
echo 0 > /sys/devices/platform/rkcif_mipi_lvds/compact_test


ffplay out.yuv -f rawvideo -pixel_format nv12 -video_size 1920x1080
ffplay out.yuv -f rawvideo -pixel_format nv12 -video_size 720x480
ffplay out.yuv -f rawvideo -pixel_format nv12 -video_size 2592x1944

```bash
// List available formats for ffmpeg
ffmpeg -pix_fmts

// Convert a 720x480 nv12 (yuv 420 semi-planar) image to png
ffmpeg -s 720x480 -pix_fmt nv12 -i frame_out.yuv -f image2 -pix_fmt rgb24 frame_out.png

// Convert a 640x480 uyvy422 image to png
ffmpeg -s 640x480 -pix_fmt uyvy422 -i frame_out.yuv -f image2 -pix_fmt rgb24 frame_out.png

// Display a 640x480 grayscale raw rgb file
display -size 640x480 -depth 8 captdump-nv12.rgb

// Convert a 640x480 grayscale raw rgb file to png
convert -size 640x480 -depth 8 captdump-nv12.rgb image.png

// play 
ffplay out.yuv -f rawvideo -pixel_format nv12 -video_size 720x480
```

```bash
// v4l2 command

// capture raw stream
v4l2-ctl --device /dev/video0 --set-fmt-video=width=720,height=480,pixelformat=NV12 --stream-mmap  --stream-to=./output_720x480.yuv --stream-count=1

// recording raw stream
v4l2-ctl --device /dev/video0 --set-fmt-video=width=720,height=480,pixelformat=nv12 --stream-mmap --stream-to=output_video_720x480.yuv --stream-count=100
```

// push xml
adb push hardware/rockchip/camera/etc/camera/camera3_profiles_rk356x.xml /vendor/etc/camera/camera3_profiles.xml
// push lib
adb push  out/target/product/rk3568_edpp02/vendor/lib/hw/camera.rk30board.so /vendor/lib/hw/

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
media-ctl -d /dev/media0 --set-v

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



rk3568_mipi_phy
 - lane_ck_ttago : 


-----

 0x06 ( Reset Control ) [7] SRESET 을 제어할때 현상 발생. 

 - mipi debugging timing
```bash
adb shell "io -4 -r -l 0x10 0xfe870140 ; io -4 -r -l 0x10 0xfe8701c0 ; io -4 -r -l 0x10 0xfe870240"
```

