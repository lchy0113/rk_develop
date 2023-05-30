# SPL 

> SPL 의 기능은 miniloader를 교체하여 trust.img 및 uboot.img의 로드 및 부팅을 완료하는 것.
> SPL은 현재 2가지 firmware 부팅을 지원함.


- FIT firmware : 기본적으로 활성화 되어 있음.
- RKFW firmware : 기본적으로 비활성화 되어 있으며, 사용자가 별도로 구성하고 활성화 해야함.

-----

## FIT firmware

 FIT(flattened image tree) 타입은 SPL에서 지원하는 비교적 새로운 firmware 타입으로, 다중 이미지 패키징 및 검증을 지원함. 
 FIT은 DTS구문을 사용하여 패키징된 이미지를 설명하고 설명 파일은 u-boot.its이며, FIT firmware는 u-boot.itb 입니다.

 - FIT firmware 의 장점 
 dts 문법 및 compile rule을 따르기에 보다 유연하고 firmware 분석시,  libfdt 라이브러리를 직접 사용할 수 있다.


### u-boot.its 

 - /images : dtsi의 역활과 유사하게 사용가능한 모든 resource의 구성을 정적으로 정의함.
 - /configurations : 각 구성 노드는 board 수준 dts와 유사한 부팅 가능한 구성으로 기술합니다.
   * default : 현재 선택된 기본 구성을 지정합니다.

```dts
/*
 * Copyright (C) 2020 Rockchip Electronic Co.,Ltd
 *
 * Simple U-boot fit source file containing ATF/OP-TEE/U-Boot/dtb/MCU
 */

/dts-v1/;

/ {
	description = "FIT Image with ATF/OP-TEE/U-Boot/MCU";
	#address-cells = <1>;

	images {

		uboot {
			description = "U-Boot";
			data = /incbin/("u-boot-nodtb.bin");
			type = "standalone";
			arch = "arm64";
			os = "U-Boot";
			compression = "none";
			load = <0x00a00000>;
			hash {
				algo = "sha256";
			};
		};
		atf-1 {
			description = "ARM Trusted Firmware";
			data = /incbin/("./bl31_0x00040000.bin");
			type = "firmware";
			arch = "arm64";
			os = "arm-trusted-firmware";
			compression = "none";
			load = <0x00040000>;
			hash {
				algo = "sha256";
			};
		};
		atf-2 {
			description = "ARM Trusted Firmware";
			data = /incbin/("./bl31_0x00068000.bin");
			type = "firmware";
			arch = "arm64";
			os = "arm-trusted-firmware";
			compression = "none";
			load = <0x00068000>;
			hash {
				algo = "sha256";
			};
		};
		atf-3 {
			description = "ARM Trusted Firmware";
			data = /incbin/("./bl31_0xfdcd0000.bin");
			type = "firmware";
			arch = "arm64";
			os = "arm-trusted-firmware";
			compression = "none";
			load = <0xfdcd0000>;
			hash {
				algo = "sha256";
			};
		};
		atf-4 {
			description = "ARM Trusted Firmware";
			data = /incbin/("./bl31_0xfdcc9000.bin");
			type = "firmware";
			arch = "arm64";
			os = "arm-trusted-firmware";
			compression = "none";
			load = <0xfdcc9000>;
			hash {
				algo = "sha256";
			};
		};
		atf-5 {
			description = "ARM Trusted Firmware";
			data = /incbin/("./bl31_0x00066000.bin");
			type = "firmware";
			arch = "arm64";
			os = "arm-trusted-firmware";
			compression = "none";
			load = <0x00066000>;
			hash {
				algo = "sha256";
			};
		};
		optee {
			description = "OP-TEE";
			data = /incbin/("tee.bin");
			type = "firmware";
			arch = "arm64";
			os = "op-tee";
			compression = "none";
			
			load = <0x8400000>;
			hash {
				algo = "sha256";
			};
		};
		fdt {
			description = "U-Boot dtb";
			data = /incbin/("./u-boot.dtb");
			type = "flat_dt";
			arch = "arm64";
			compression = "none";
			hash {
				algo = "sha256";
			};
		};
	};

	configurations {
		default = "conf";
		conf {
			description = "rk3568-poc";
			rollback-index = <0x0>;
			firmware = "atf-1";
			loadables = "uboot", "atf-2", "atf-3", "atf-4", "atf-5", "optee";
			
			fdt = "fdt";
			signature {
				algo = "sha256,rsa2048";
				
				key-name-hint = "dev";
				sign-images = "fdt", "firmware", "loadables";
			};
		};
	};
};
```

### u-boot.itb

```bash
                                 mkimage + dtc 
    [u-boot.its] + [images]            ==>            [u-boot.itb]
```
 <itb 파일이 생성 과정.>


```
lchy0113@311b765fde20:~/Develop_ssd/ROCKCHIP_ANDROID12/out/target/product/rk3568_rgbp02/obj/BOOTLOADER_OBJ$ fdtdump fit/uboot.itb

**** fdtdump is a low-level debugging tool, not meant for general use.
**** If you want to decompile a dtb, you probably want
****     dtc -I dtb -O dts <filename>

/dts-v1/;
// magic:               0xd00dfeed
// totalsize:           0xe00 (3584)
// off_dt_struct:       0x58
// off_dt_strings:      0xb64
// off_mem_rsvmap:      0x28
// version:             17
// last_comp_version:   16
// boot_cpuid_phys:     0x0
// size_dt_strings:     0xc5
// size_dt_struct:      0xb0c

/memreserve/ 0x7fa7adf46000 0xc00;
/memreserve/ 0x7fa7adf45000 0xe00;
/ {
    version = <0x00000000>;
    totalsize = <0x001e3200>;
    timestamp = <0x646dbf99>;
    description = "FIT Image with ATF/OP-TEE/U-Boot/MCU";
    #address-cells = <0x00000001>;
    images {
        uboot {
            data-size = <0x00131b00>;
            data-position = <0x00001000>;
            description = "U-Boot";
            type = "standalone";
            arch = "arm64";
            os = "U-Boot";
            compression = "none";
            load = <0x00a00000>;
            hash {
                value = <0xe039960d 0x2cfc8384 0x8234c898 0x879801e9 0x9b378258 0x8a370cb0 0xc40e7dd2 0xacb2c497>;
                algo = "sha256";
            };
        };
        atf-1 {
            data-size = <0x00028000>;	// compiler 는 이 필드에 atf-1 크기를 기술.
            data-position = <0x00132c00>;	// compiler 는 이 필드에 atf-1 offset 을 기술.
            description = "ARM Trusted Firmware";
            type = "firmware";
            arch = "arm64";
            os = "arm-trusted-firmware";
            compression = "none";
            load = <0x00040000>;
            hash {
                value = <0x32fbfe61 0x3959f3a5 0xa194b87d 0x05b07db2 0xb5b4fefa 0x83791951 0xf7f6d265 0x9abc6c6c>;
                algo = "sha256";
            };
        };
        atf-2 {
            data-size = <0x0000a000>;
            data-position = <0x0015ac00>;
            description = "ARM Trusted Firmware";
            type = "firmware";
            arch = "arm64";
            os = "arm-trusted-firmware";
            compression = "none";
            load = <0xfdcc1000>;
            hash {
                value = <0x9662321b 0x37d2cd36 0xd4775509 0x52c8c3c7 0x4144d95b 0xee5a22d7 0xfe54fbe1 0x54eb5a59>;
                algo = "sha256";
            };
        };
```

-----

## RKFW firmware

 - configuration
```bash
CONFIG_SPL_LOAD_RKFW 		// enable
CONFIG_RKFW_TRUST_SECTOR	// partition table 정의와 일치해야 하는 trust.img partition addr
CONFIG_RKFW_U_BOOT_SECTOR	// partition table 정의와 일치해야 하는 uboot.img partition addr
```


### 관련 파일

```bash
./include/spl_rkfw.h
./common/spl/spl_rkfw.c
```

### storate 우선 순위

u-boot dts에서 u-boot, spl-boot-order를 통해 storage device 의 booting 우선 순위를 지정.

```dts
/ {
	aliases {
		ethernet0 = &gmac0;
		ethernet1 = &gmac1;
		mmc0 = &sdhci;
		mmc1 = &sdmmc0;
		mmc2 = &sdmmc1;
	};

	chosen {
		stdout-path = &uart2;
		u-boot,spl-boot-order = &sdmmc0, &sdhci, &nandc0, &spi_nand, &spi_nor;
	};
};
```
