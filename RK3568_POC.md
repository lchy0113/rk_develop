# DEVICE 
> aosp rk3568 device 에 대한 문서 입니다.


## Device Map

### uart
 - upper layer에는 아래와 같은 uart node로 제공.

| **uart dev node** 	| **connect device**   	|
|-------------------	|----------------------	|
| /dev/ttyS0        	| rs485;device control 	|
| /dev/ttyS1        	| rs485;sub-phone      	|
| /dev/ttyS2        	| zigbee               	|
| /dev/ttyS3        	| temp                 	|


```bash
+---------------+
| [RK3568]      |
|               |
|    UART0------+ <-----> zigbee	(rk3568_rgb_p01: micom)
|               |
|    UART1-+-M0-+
|          +-M1-+
|               |
|    UART2-+-M0-+ <----> device control;rs485  (rk3568_rgb_p01: debug)
|          +-M1-+
|               |
|    UART3-+-M0-+	(rk3558_rgb_p01: pstn modem)
|          +-M1-+
|               |
|    UART4-+-M0-+	(rk3568_rgb_p01: device control;rs485)
|          +-M1-+ <----> debug
|               |
|    UART5-+-M0-+
|          +-M1-+
|               |
|    UART6-+-M0-+ <----> sub;rs485
|          +-M1-+
|               |
|    UART7-+-M0-+
|          +-M1-+
|               |
|    UART8-+-M0-+
|          +-M1-+
|               |
|    UART9-+-M0-+ <----> mcu(temp)
|          +-M1-+
|               |
+---------------+
```

### i2c
- rk3568_rgb_p02 board

```bash
+---------------+
| [RK3568]      |
|               |
|    I2C0-------+
|               |
|    I2C1-------+ <----> hot key
|               |
|    I2C2--+-M0-+
|          +-M1-+ <----> internal cam
|               |
|    I2C3--+-M0-+ <----> touch ic
|          +-M1-+
|               |
|    I2C4--+-M0-+ <----> pmic
|          +-M1-+
|               |
|    I2C5--+-M0-+
|          +-M1-+ <----> audio codec, decoder
|               |
|    I2C_HDMI---+
+---------------+
```

### vop
- rk3568 support vop

```bash
+---------------+
| [RK3568]      |
|               |
|   Port0------ + <----> dsi0, dsi2, edp, hdmi 
|               |
|               |
|   Port2------ + <----> dsi0, dsi1, edp, hdmi, lvcd
|               |
|               |
|   Port2------ + <----> lvds, rgb 
|               |
|               |
+---------------+
```



- rk3568_rgb_p01, rk3568_rgb_p02 board

```bash
+---------------+
| [RK3568]      |
|               |
|   Port0------ + <----> hdmi
|               |
|               |
|   Port2------ +
|               |
|               |
|   Port2------ + <----> rgb565 
|               |
|               |
+---------------+
```

- rk3568_edp_p01 board

```bash
+---------------+
| [RK3568]      |
|               |
|   Port0------ + <----> hdmi
|               |
|               |
|   Port2------ + <----> edp
|               |
|               |
|   Port2------ + 
|               |
|               |
+---------------+
```

### io power domain
> rk3568_rgb_p01, rk3568_rgb_p02 board

```bash
+--------------------------------------------------------------------------------------+
| [RK3568]                                                                             |
|                                                                                      |
|     [io domain]    [pin num]    [supply power net name]    [voltage]                 |
|                                                                                      |
|     PMUIO1         Y20          VCC3V3_PMU                 3.3V                      | 
|                                                                                      |
|     PMUIO2         W19          VCC3V3_PMU                 3.3V                      |
|                                                                                      |
|     VCCIO1         H17          VCCIO_ACODEC               3.3V                      |
|                                                                                      |
|     VCCIO2         H18          VCCIO_FLASH                1.8V                      |
|                   /* pin "FLASH_VOL_SEL" must be logic High,                         |
|                     if VCCIO_FLASH=3.3V, FLASH_VOL_SEL must be logic low             |
|                     and VCCIO_FLASH=1.8V, FLASH_VOL_SEL must be logic high */        |
|                                                                                      |
|     VCCIO3         L22          VCCIO_SD                   3.3V                      |
|                                                                                      |
|     VCCIO4         J21          VCC_3V3                    3.3V                      |
|                                                                                      |
|     VCCIO5         V10 V11      VCC_3V3                    3.3V                      |
|                                                                                      |
|     VCCIO6         R9 U9        VCC_3V3                    3.3V                      |
|                                                                                      |
|     VCCIO7         V12          VCC_3V3                    3.3V                      |
|                                                                                      |
+--------------------------------------------------------------------------------------+
```


### gpio
> rk3568_rgb_p02 board

- pio_hal
```bash
// input
	GPIO0_C6	DOOR_CALL_DET
	GPIO1_A6	ESCAPE_IN
	GPIO1_A7	EMG_IN
	GPIO1_B0	SEQ1_IN
	GPIO1_B1	SEQ2_IN
	GPIO2_C6	PIR_DET

// output
	GPIO0_A5	DOOR_OPEN
	GPIO0_B7	RST_CH710
	GPIO0_C2	ZIGBee_RST
	GPIO0_C5	DOOR_PCTL
	GPIO1_A5	EMER_LEDOUT
```


- audio
```bash
	GPIO0_A6	SEL_DC
	GPIO0_B1	DOOR_MIC_EN
	GPIO0_B2	SEL_DC_SUB
	GPIO0_C3	SEL_SUB-
	GPIO0_C4	SEL_ECHO_SUB+
	GPIO2_D1	SEL_DTMF
	GPIO3_A1	SEL_PSTN
	GPIo3_A2	SEL_SUB_PSTN
	GPIO3_C1	SEL_ECHO
	GPIO3_C2	SEL_SUB_VIDEO
	GPIO3_D0	DTMF_DATA
	GPIO3_D1	DTMF_EN
	GPIO3_D2	PSTN_OFF_HOOK
	GPIO3_D3	RING_DET
	GPIO3_D4	PSTN_DET
	GPIO4_C2	DTMF_CLK
	GPIO4_D2	SPK_AMP_EN
```

## Kernel DTB

```bash
    /                               /                               /
    rk3568-pinctrl.dtsi----------+
    rk3568.dtsi------------------+	
    rk3568-poc.dtsi--------------+--rk3568-poc-v00.dtsi----------+--rk3568-poc-v00.dts
        +-> /**                         +-> /**
              * backlight                     * set iodomain
              * leds                          * panel 
              * sound card                    * usb
              * iodomain                      * camera
              * mmc                           * gmac
              * etc                           * i2c1-5
              */                              * uart
                                              */
                                    rk3568-android.dtsi----------+
                                        +-> /**
                                              * setting bootargs
                                              * reserved_memory
                                              */
// change

    rk3568-pinctrl.dtsi----------+                                                                                     
    rk3568.dtsi------------------+                                                                   
    rk3568-poc.dtsi--------------+--rk3568-rgb.dtsi--------------+--rk3568-rgb-p01.dts                     
                                 |                               +--rk3568-rgb-p02.dts                     
                                 |                               +
                                 +--rk3568-edp.dtsi--------------+--rk3568-edp-p01.dts
                                                                 +
                                    rk3568-android.dtsi----------+                       
                                                                 +
    /                               /                               /
```




## Android Device

```bash
lchy0113@AOA:~/ssd/Rockchip/ROCKCHIP_ANDROID12/device$ tree -R company/test/rk3568_poc/
company/test/rk3568_poc/
├── AndroidBoard.mk
├── AndroidProducts.mk
├── BoardConfig.mk
├── bt_vendor.conf
├── media_profiles_default.xml
└── rk3568_poc.mk

0 directories, 6 files:w

```
---
```bash
device/company/test/rk3568_poc/AndroidBoard.mk
	|
	+-> include device/company/nova/rk3568/board.mk
		|	/* include rockchip's makefile */
		+-> include device/rockchip/common/build/rockchip/RebuildFstab.mk
		+-> include device/rockchip/common/build/rockchip/RebuildDtboImg.mk
		+-> include device/rockchip/common/build/rockchip/RebuildParameter.mk
		|
		+-> bootloader
		|	/* include common u-boot make template */
		+-> include device/company/nova/common/uboot.mk
		|
		+-> kernel
		|	/* include common kernel make template */
		|-> include device/company/nova/common/kernel.mk
		|
		+-> rockchip images
```
---
```bash
device/company/test/rk3568_poc/AndroidProducts.mk
	|
	+-> Makefile 지정(rk3568_poc.mk) 
	+-> lunch choice 등록
```
---
```bash
device/company/test/rk3568_poc/BoardConfig.mk
	|
	+-> include device/company/nova/rk3568/config.mk
	|	|
	|	+-> include device/company/nova/common/config.mk
	|	+->	include device/rockchip/rk356x/BoardConfig.mk
	|	|	+-> build default config 지정
	|	+-> bootloader, kernel, dtb, hal  build시 default config 재지정 
```
---
```bash
device/company/test/rk3568_poc/rk3568_poc.mk
	|
	+->	inherit device/company/nova/rk3568/device.mk
	|	|
	|	+-> include device/rockchip/common/build/rockchip/DynamicPartitions.mk 
	|	|	+->	파티션 설정
	|	+-> include device/company/nova/rk3568/config.mk
	|	|	|
	|	|	+-> include device/company/nova/common/config.mk
	|	|	+->	include device/rockchip/rk356x/BoardConfig.mk
	|	|	|	+-> build default config 지정
	|	|	+-> bootloader, kernel, dtb, hal  build시 config 재지정
	|	+-> include device/rockchip/common/Boardconfig.mk
	|	|		board config 기본 세팅
	|	+-> inherit device/company/nova/common/device.mk
	|	|	+-> copy init.nova.common.rc, setting nova overlay, copy adb key, copy system_dump.sh
	|`	+-> inherit device/rockchip/rk356x/device.mk
	|	|	+-> copy package and file related rockchip rk3568 
	|	+-> inherit device/rockchip/common/device.mk
	|	|	+-> copy package and file related rockchip and aosp platform
	|	+-> inherit frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk
	|	|	+-> setting property
	|	+-> overlay 및 package 지정.
	+-> product name, device, model, brand, manufacturer 세팅.  
```


-----

## userdata partition file system 검토
> change userdata partition file system to EXT4

 - diff 파일 참고.
   * [diff file](./attachment/diff_changed_data_partion_to_ext4_from_f2fs.diff)

-----

## Data 영역 read/write performance 최적화

 - 데이터 영역 write performance 최적화.
   * 배터리가 있는 장치의 경우, 스토리지 읽기/쓰기 속도 및 성능을 향상시키기 위해 fstab의 데이터 파티션 탑재 매개변수에 'fsync_mode=nobarrier'를 추가하는 것이 좋다.
     + 이 매개변수는 배터리가 없는 장치에서 데이터 손상을 일으킬 수 있다.
     + 따라서 배터리가 없는 장치에는 이 매개변수를 추가하지 않는 것이 좋다.
     + fsync_mode = nobarrier는 linux에서 사용하는 Mount 옵션.    
     + 이 옵션을 사용하면 file system write작업이 완료 되기전에 하드웨어 cache를 flush 하지 않는다. 
     + 즉, 파일시스템의 쓰기 작업이 더 빨리 완료 된다. 반대로, 시스템에 손실에 발생할 위험이 있다. 
 

-----

## to do : 
 - [x] change userdata partition file system to EXT4  : 기본적으로 data 파티션의 파일시스템은 fsfs으로 구성된다.   배터리를 사용하지 않는 제품은 ext4 파일시스템으로 변경을 추천한다. (data loss 방지를 위해서 f2fs파일시스템을 사용함.)
```bash
/dev/block/dm-8 on /data type f2fs (rw,lazytime,seclabel,nosuid,nodev,noatime,background_gc=on,discard,no_heap,user_xattr,inline_xattr,acl,inline_data,inline_dentry,flush_merge,extent_cache,mode=adaptive,active_logs=6,reserve_root=32768,resuid=0,resgid=1065,alloc_mode=reuse,fsync_mode=posix)

// patch-01
device/rockchip/common$ git diff
diff --git a/scripts/fstab_tools/fstab.in b/scripts/fstab_tools/fstab.in
index 6e78b00..a658332 100755
--- a/scripts/fstab_tools/fstab.in
+++ b/scripts/fstab_tools/fstab.in
@@ -20,6 +20,6 @@ ${_block_prefix}system_ext /system_ext
 ext4 ro,barrier=1
${_flags},first_stage_
# For sdmmc
/devices/platform/${_sdmmc_device}/mmc_host*
 auto
 auto
 defaults
voldmanaged=sdcard1:auto
#
 Full disk encryption has less effect on rk3326, so default to enable this.
-/dev/block/by-name/userdata /data f2fs	noatime,nosuid,nodev,discard,reserve_root=32768,resgid=1065 latemount,wait,check,fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized,quota,formattable,reservedsize=128M,checkpoint=fs
+#/dev/block/by-name/userdata /data f2fs noatime,nosuid,nodev,discard,reserve_root=32768,resgid=1065 latemount,wait,check,fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized,quota,formattable,reservedsize=128M,checkpoint=fs
# for ext4
-#/dev/block/by-name/userdata
 /data
 ext4
discard,noatime,nosuid,nodev,noauto_da_alloc,data=ordered,user_xattr,barrier=1latemount,wait,formattable,check,fileencryption=software,quota,reservedsize=128M,checkpoint=block
+/dev/block/by-name/userdata /data ext4 discard,noatime,nosuid,nodev,noauto_da_alloc,data=ordered,user_xattr,barrier=1 latemount,wait,formattable,check,fileencryption=software,quota,reservedsize=128M,checkpoint=block

// patch-02
device/rockchip/rk356x$ git diff
diff --git a/rk3566_r/recovery.fstab b/rk3566_r/recovery.fstab
index 7532217..cf789ac 100755
--- a/rk3566_r/recovery.fstab
+++ b/rk3566_r/recovery.fstab
@@ -7,7 +7,7 @@
 /dev/block/by-name/odm				/odm	 		ext4	defaults	 defaults
 /dev/block/by-name/cache			/cache			ext4	defaults	 defaults
 /dev/block/by-name/metadata		/metadata		ext4	defaults	 defaults
-/dev/block/by-name/userdata		/data			f2fs	defaults	 defaults
+/dev/block/by-name/userdata		/data			ext4	defaults	 defaults
 /dev/block/by-name/cust			/cust			ext4	defaults	 defaults
 /dev/block/by-name/custom			/custom			ext4	defaults	 defaults
 /dev/block/by-name/radical_update	/radical_update ext4	defaults	 defaults
```
 - [ ] app performance mode setting : Configure the file: package_performance.xml in device/rockchip/rk3xxx/. Add the package names which need to use performance mode in the node:(use aapt dump badging (file_path.apk) to acquire the package name)
```bash
< app package="package name" mode="whether to enable the acceleration, 1 for enable, 0 for disable"/>
// take antutu as example as below, 

< app package="com.antutu.ABenchMark"mode="1"/>
< app package="com.antutu.benchmark.full"mode="1"\/>
< app package="com.antutu.benchmark.full"mode="1"\/>
```




