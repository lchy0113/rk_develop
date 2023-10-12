# uboot 빌드 스크립트(for rockchip)
> make.sh 

## sub script   

```bash
/** sub script */
SRCTREE=`pwd`
SCRIPT_FIT="${SRCTREE}/scripts/fit.sh"
SCRIPT_ATF="${SRCTREE}/scripts/atf.sh"
SCRIPT_TOS="${SRCTREE}/scripts/tos.sh"
SCRIPT_SPL="${SRCTREE}/scripts/spl.sh"
SCRIPT_UBOOT="${SRCTREE}/scripts/uboot.sh"
SCRIPT_LOADER="${SRCTREE}/scripts/loader.sh"
SCRIPT_DECOMP="${SRCTREE}/scripts/decomp.sh"
CC_FILE=".cc"
REP_DIR="./rep"
```

<br/> 
<br/> 
<br/> 
<br/> 
-----

## script flow

> script는 아래 flow 로 동작

###  01. **process_args**  

> script 실행 시, argument 세팅.

```bash
// make defconfig
```

###  02. **prepare**  

> rkbin tools path 설정 및 build config를 파싱

```bash
RKBIN=rkbin

PLAT_TYPE="FIT'	// if CONFIG_ROCKCHIP_FIT_IMAGE=y from .config
```

###  03. **select_toolchain**  

```bash
TOOLCHAIN=
TOOLCHAIN_NM=
TOOLCHAIN_OBJDUMP=
TOOLCHAIN_ADDR2LINE=
```

###  04. **select_chip_info**  

```bash
RKCHIP=			RK3568
RKCHIP_LABEL=	RK3568	
RKCHIP_LOADER=	RK3568
RKCHIP_TRUST=	RK3568
INI_TRUST=		rkbin/RKTRUST/RK3568TRUST.ini
INI_LOADER=		rkbin/RKBOOT/RK3568MINIALL.ini
```

###  05. **fixup_platform_configure**  

```bash
PLAT_RSA=
PLAT_SHA=
PLAT_UBOOT_SIZE=
PLAT_TRUST_SIZE=
PLAT_TYPE="RKFW" # default
```

###  06. **select_ini_file**  

> 타겟 장치의 정보를 선택

```bash
// to do: target board 별 ini_file 지정해야함.
// configs/rk3568_poc_defconfig에서 CONFIG_LOADER_INI 에 NAME 지정하도록 추가.
INI_LOADER=
```
 
###  07. **handle,args_late**  
###  08. **sub_commands**  
###  09. **clean files**  
###  10. **make PYTHON=python2 CROSS_COMPILE=${toolchain} all --jobs=${JOB}**  
###  11. **pack_images**  

```bash
pack_fit_image --ini-trust rkbin/RKTRUST/RK3568TRUST.ini --ini-loader rkbin/RKBOOT?RK3568MINIALL.ini 
	${SCRIPT_FIT} ${ARG_LIST_FIT} --chip RK3568
		scripts/fit.sh
			scripts/fit-core.sh
				function fit_gen_uboot_itb()
					./make.sh itb 	 rkbin/RKTRUST/RK3568TRUST.ini
					./make.sh loader rkbin/RKBOOT/RK3568MINIALL.ini

					loader rkbin/RKBOOT/RK3568MINIALL.ini
					DEF_PATH:rkbin/rk356x_spl_loader_v1.13.112.bin
					IDB_PATH:rkbin/
```
###  12. **finish**  
###  13. **echo ${TOOLCHAIN}**  
###  14. **date**  
 
-----
<br/>
<br/>
<br/>
<br/>

## build to bootloader by Android 

 > Android build system에 의해 빌드되는 flow정리.

### defconfig 

```Makefile
PRODUCT_UBOOT_CONFIG := rk3568_poc_defconfig rk3568-rgb-p02.config

### BOOTLOADER
TARGET_BOOTLOADER_CONFIG_TARGET := $(PRODUCT_UBOOT_CONFIG)
```


### bootloader makefile

```Makefile
### BOOTLOADER

# Include common u-boot make template
include device/($COMPANY)/$(TARGET)/common/uboot.mk

SPL_LOADER := $(BOOTLOADER_OUT)/rk356x_spl_loader_v1.13.112.bin

.PHONY: uboot u-boot bootloader
uboot u-boot: $(UBOOT_BIN)
bootloader: $(UBOOT_BIN) $(SPL_LOADER)

$(SPL_LOADER): $(UBOOT_BIN) $(BOOTLOADER_OUT)/make.sh
	$(call create_link_under,$(BOOTLOADER_SRC)/configs,*,$(BOOTLOADER_OUT)/configs)
	$(call create_link_under,$(BOOTLOADER_SRC)/scripts,*.sh,$(BOOTLOADER_OUT)/scripts)
	$(call create_link_under,$(BOOTLOADER_SRC)/arch/arm/mach-rockchip,*.sh,$(BOOTLOADER_OUT)/arch/arm/mach-rockchip)
	$(call create_link_under,$(BOOTLOADER_SRC)/arch/arm/mach-rockchip,*.py,$(BOOTLOADER_OUT)/arch/arm/mach-rockchip)
	(cd $(BOOTLOADER_OUT) && $(NOVA_ENV) ./make.sh)

$(BOOTLOADER_OUT)/make.sh: $(BOOTLOADER_SRC)/make.sh
	cp -f $< $@
	ln -sf -T $(realpath rkbin) $(BOOTLOADER_OUT)/../rkbin
	ln -sf -T $(realpath prebuilts) $(BOOTLOADER_OUT)/../prebuilts
```

```Makefile
ifeq ($(TARGET_BOOTLOADER_SRC),)
$(error TARGET_BOOTLOADER_SRC not defined)
endif

ifeq ($(TARGET_BOOTLOADER_CONFIG_TARGET),)
$(error TARGET_BOOTLOADER_CONFIG_TARGET not defined)
endif

# Set the output for the bootloader build
BOOTLOADER_SRC := $(TARGET_BOOTLOADER_SRC)
BOOTLOADER_OUT := $(TARGET_OUT_INTERMEDIATES)/BOOTLOADER_OBJ
BOOTLOADER_ARCH := $(strip $(TARGET_BOOTLOADER_ARCH))
BOOTLOADER_CROSS_COMPILE := $(TARGET_BOOTLOADER_CROSS_COMPILE_PREFIX)

UBOOT_SRCS := \
	$(shell find $(BOOTLOADER_SRC) -name '*.h') \
	$(shell find $(BOOTLOADER_SRC) -name '*.c') \
	$(shell find $(BOOTLOADER_SRC) -name '*.S')

UBOOT_BIN := $(BOOTLOADER_OUT)/u-boot.bin

UBOOT_ARGS := O=$(abspath $(BOOTLOADER_OUT))
ifneq ($(BOOTLOADER_ARCH),)
UBOOT_ARGS += ARCH=$(BOOTLOADER_ARCH)
endif
ifneq ($(BOOTLOADER_CROSS_COMPILE),)
UBOOT_ARGS += CROSS_COMPILE=$(BOOTLOADER_CROSS_COMPILE)
endif
UBOOT_ARGS += $(TARGET_BOOTLOADER_EXTRA_ARGS)

$(BOOTLOADER_OUT):
	$(hide) mkdir -p $@

define build_uboot
	cd $(BOOTLOADER_SRC) && \
	$(NOVA_MAKE) $(UBOOT_ARGS) $(1)
endef

$(UBOOT_BIN): $(BOOTLOADER_OUT) $(UBOOT_SRCS)
	$(call build_uboot,mrproper)
	$(call build_uboot,distclean)
	$(call build_uboot,$(TARGET_BOOTLOADER_CONFIG_TARGET))
	$(call build_uboot,u-boot.bin)

	(...)


## ROCKCHIP IMAGES

ROCKCHIP_OUT := $(TARGET_OUT_INTERMEDIATES)/ROCKCHIP_OBJ

.PHONY: rockdev
rockdev: $(UBOOT_BIN) $(SPL_LOADER) $(PRODUCT_OUT)/kernel $(DEFAULT_GOAL) | $(ROCKCHIP_OUT)/mkimage.sh
	$(NOVA_ENV) $(ROCKCHIP_OUT)/mkimage.sh
	ln -sf -T Image-$(TARGET_PRODUCT) rockdev/latest

# 기호 '|'는 2개의 의존 관계를 OR조건으로 연결하는데 사용. 
# 즉, 타겟을 생성하기 위해 2개의 의존관계중 하나만 충족하면 된다.
$(ROCKCHIP_OUT)/mkimage.sh: $(ROCKCHIP_OUT) | mkimage.sh
	sed -e "s/UBOOT_PATH=u-boot/UBOOT_PATH=$(subst /,\/,$(BOOTLOADER_OUT))/ig" mkimage.sh > $@
	chmod +x $@

$(ROCKCHIP_OUT):
	$(hide) mkdir -p $@

PACK_OUT := $(ROCKCHIP_OUT)/pack

.PHONY: pack
pack: $(PACK_OUT) rockdev
	(cd $(PACK_OUT)/rockdev && .mkupdate.sh rk356x Image)
	$(ACP) -fp $(PACK_OUT)/rockdev/update.img $(PRODUCT_OUT)/update.img


$(PACK_OUT):
	$(hide) mkdir -p $@
# 안드로이드 빌드 디렉토리에 RKTool 링크 생성
	ln -sf -T $(realpath RKTools/linux/Linux_Pack_Firmware/rockdev) $q(PACK_OUT)/rockdev
# 빌드된 이미지 링크 생성
	ln -sf -T $(realpath rockdev/Image-$(TARGET_PRODUCT)) $(PACK_OUT)/rockdev/Image
```

 - .PHONY : Makefile에서 PHYONY는 실제 파일을 나타내지 않는 타겟을 지정하는데 사용. PHONY 타겟은 항상 재생성되며, 의존 관계가 있는 파일의 경우 존재 여부가 무시. 
   * 실제 파일이 아닌 작업을 나타내려는 경우, 
   * 특정 작업을 수행하기 전에 명시적으로 해당 작업을 실행하려는 경우

```Makefile
.PHONY: clean
# clean 타겟은 실제 파일을 나타내지 않으므로 .PHONY 키워드를 사용하여 선언함. 
clean:
	rm -rf *.o *.out

```

----
<br/>
<br/>
<br/>
<br/>


# tools

## boot_merger
 > ini 설정 파일에 따라서 miniloader + ddr + usb plug를 merger하여 loader firmware을 생성.

 - ini file(RK3568MINIALL.ini)
```bash
[CHIP_NAME]
NAME=RK3568		// chip name
[VERSION]
MAJOR=1		
MINOR=1
[CODE471_OPTION]		// code471, Path1경로의 파일을 ddr bin으로 설정
NUM=1
Path1=bin/rk35/rk3568_ddr_1560MHz_v1.13.bin
Sleep=1
[CODE472_OPTION]		// code472, Path1경로의 파일을 usbplug bin으로 설정
NUM=1
Path1=bin/rk35/rk356x_usbplug_v1.14.bin
[LOADER_OPTION]			// FlashData; 현재 ddr bin 으로 설정 , FlashBoot; miniLoader bin 으로 설정
NUM=2
LOADER1=FlashData
LOADER2=FlashBoot
FlashData=bin/rk35/rk3568_ddr_1560MHz_v1.13.bin
FlashBoot=bin/rk35/rk356x_spl_v1.12.bin
[OUTPUT]		// 출력되는 파일 이름
PATH=rk356x_spl_loader_v1.13.112.bin
[SYSTEM]
NEWIDB=true
[FLAG]
471_RC4_OFF=true
RC4_OFF=true
```
