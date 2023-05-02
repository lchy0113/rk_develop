# DEVICE 
> aosp rk3568 device 에 대한 문서 입니다.


## Device Map

### uart

```bash
/* Default UART Map */

+---------------+
| [RK3568]      |
|               |
|    UART0------+ <-----> zigbee
|               |
|    UART1-+-M0-+
|          +-M1-+
|               |
|    UART2-+-M0-+ <----> device control
|          +-M1-+
|               |
|    UART3-+-M0-+
|          +-M1-+
|               |
|    UART4-+-M0-+
|          +-M1-+ <----> debug
|               |
|    UART5-+-M0-+
|          +-M1-+
|               |
|    UART6-+-M0-+ <----> sub
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


## to do : 
 - [ ] change userdata partition file system to EXT4  : 기본적으로 data 파티션의 파일시스템은 fsfs으로 구성된다.   배터리를 사용하지 않는 제품은 ext4 파일시스템으로 변경을 추천한다. (data loss 방지를 위해서 f2fs파일시스템을 사용함.)
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
