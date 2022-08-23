# DEVICE 
> aosp rk3568 device 에 대한 문서 입니다.

```bash
lchy0113@AOA:~/ssd/Rockchip/ROCKCHIP_ANDROID12/device$ tree -R kdiwin/test/rk3568_poc/
kdiwin/test/rk3568_poc/
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
device/kdiwin/test/rk3568_poc/AndroidBoard.mk
	|
	+-> include device/kdiwin/nova/rk3568/board.mk
		|	/* include rockchip's makefile */
		+-> include device/rockchip/common/build/rockchip/RebuildFstab.mk
		+-> include device/rockchip/common/build/rockchip/RebuildDtboImg.mk
		+-> include device/rockchip/common/build/rockchip/RebuildParameter.mk
		|
		+-> bootloader
		|	/* include common u-boot make template */
		+-> include device/kdiwin/nova/common/uboot.mk
		|
		+-> kernel
		|	/* include common kernel make template */
		|-> include device/kdiwin/nova/common/kernel.mk
		|
		+-> rockchip images
```
---
```bash
device/kdiwin/test/rk3568_poc/AndroidProducts.mk
	|
	+-> Makefile 지정(rk3568_poc.mk) 
	+-> lunch choice 등록
```
---
```bash
device/kdiwin/test/rk3568_poc/BoardConfig.mk
	|
	+-> include device/kdiwin/nova/rk3568/config.mk
	|	|
	|	+-> include device/kdiwin/nova/common/config.mk
	|	+->	include device/rockchip/rk356x/BoardConfig.mk
	|	|	+-> build default config 지정
	|	+-> bootloader, kernel, dtb, hal  build시 default config 재지정 
```
---
```bash
device/kdiwin/test/rk3568_poc/rk3568_poc.mk
	|
	+->	inherit device/kdiwin/nova/rk3568/device.mk
	|	|
	|	+-> include device/rockchip/common/build/rockchip/DynamicPartitions.mk 
	|	|	+->	파티션 설정
	|	+-> include device/kdiwin/nova/rk3568/config.mk
	|	|	|
	|	|	+-> include device/kdiwin/nova/common/config.mk
	|	|	+->	include device/rockchip/rk356x/BoardConfig.mk
	|	|	|	+-> build default config 지정
	|	|	+-> bootloader, kernel, dtb, hal  build시 config 재지정
	|	+-> include device/rockchip/common/Boardconfig.mk
	|	|		board config 기본 세팅
	|	+-> inherit device/kdiwin/nova/common/device.mk
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
