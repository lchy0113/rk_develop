DTBO
> Device Tree Blob Overlay

```Makefile
# dtbo 이미지를 생성하기 위한 파일
# (PRODUCT_DTBO_TEMPLATE)dt-overlay.in : DTBO Template file
# (rebuild_dts)device-tree-overlay.dts : DTS파일, DTBO 이미지 생성 위한 입력 파일
# (rebuild_dtbo_dtb)device-dtbo.dtb : dts 파일을 컴파일하여 생성된 dtb 파일
# (rebuild_dtbo_img)rebuild-recovery-dtbo.img : 최종 dtbo 파일

AOSP_DTC_TOOL := $(SOONG_HOST_OUT_EXECUTABLES)/dtc
AOSP_MKDTIMG_TOOL := $(SOONG_HOST_OUT_EXECUTABLES)/mkdtimg
ROCKCHIP_FSTAB_TOOLS := $(SOONG_HOST_OUT_EXECUTABLES)/fstab_tools


## device-tree-overlay.dts 파일을 생성하는 타겟
# fstab_tools을 사용하여, 입력된 DTBO Template file 을 기반으로 DTS 파일 생성 
$(rebuild_dts) : $(ROCKCHIP_FSTAB_TOOLS) $(PRODUCT_DTBO_TEMPLATE)
	@echo "RICHGOLD Building dts file $@."
	$(ROCKCHIP_FSTAB_TOOLS) -I dts \
		-i $(PRODUCT_DTBO_TEMPLATE) \
		-p $(dtbo_boot_device) \
		-f $(dtbo_flags) \
		-o $(rebuild_dts)

## rebuild-recovery-dtbo.img 최종 dtbo파일을 생성하는 타겟
# rebuild_dts파일을 입력받아, dtb(rebuild_dtbo_dtb) 파일을 생성한 후, 
# 이를 기반으로 dtbo(rebuild_dtbo_img) 이미지 생성.
#
$(rebuild_dtbo_img) : $(rebuild_dts) $(AOSP_DTC_TOOL) $(AOSP_MKDTIMG_TOOL)
    @echo "RICHGOLD Building dtbo img file $@."
	    $(AOSP_DTC_TOOL) -@ -O dtb -o $(rebuild_dtbo_dtb) $(rebuild_dts)
	    $(AOSP_MKDTIMG_TOOL) create $(rebuild_dtbo_img) $(rebuild_dtbo_dtb)

```

