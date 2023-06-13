# POWER 

> RK3568 IO Power Domain Configuration Guide


 main control power domain 의 IO level은 연결된 주변 칩의 IO level과 일치해야 하며, 소프트웨어의 voltage 구성은 하드웨어 voltage와 일치해야 합니다. 

 RK3568에는 PMUIO[0:2] 및 VCCIO[1:7] 인 총 10 개의 독립적인 IO power domain이 있습니다. 

 - PMUIO0, PMUIO1 은 fixed-level power domain이며, 변경할 수 없습니다.
 - PMUIO2, VCCIO1, VCCIO[3:7] 은  power domains은 hardware supply voltage 와 맞는 software 구성이 필요합니다. 
	 1) hardware IO level이 1.8V인 경우, software voltage 세팅은 1.8V와 일치해야 합니다.
	 2) hardware IO level이 3.3V인 경우, software voltage 세팅은 3.3V와 일치해야 합니다.
 - VCCIO2 power domain 에 대한 software는 구성할 필요가 없지만 hardware power  supply device voltage은 FLASH_VOL_SEL 상태와 일치해야 합니다.
	 1) VCCIO2의 power supply이 1.8V일 때 FLASH_VOL_SEL 핀은 HIGH값을 유지되어야 합니다.
	 2) VCCIO2의 power supply이 3.3V일 때 FLASH_VOL_SEL 핀은 LOW값을 유지되어야 합니다.


## dts 정보

arch/arm64/boot/dts/rockchip/rk3568-poc.dtsi
```dtb
 /*
  * There are 10 independent IO domains in RK3566/RK3568, including PMUIO[0:2] and VCCIO[1:7].
  * 1/ PMUIO0 and PMUIO1 are fixed-level power domains which cannot be configured;
  * 2/ PMUIO2 and VCCIO1,VCCIO[3:7] domains require that their hardware power supply voltages
  *    must be consistent with the software configuration correspondingly
  *	a/ When the hardware IO level is connected to 1.8V, the software voltage configuration
  *	   should also be configured to 1.8V accordingly;
  *	b/ When the hardware IO level is connected to 3.3V, the software voltage configuration
  *	   should also be configured to 3.3V accordingly;
  * 3/ VCCIO2 voltage control selection (0xFDC20140)
  *	BIT[0]: 0x0: from GPIO_0A7 (default)
  *	BIT[0]: 0x1: from GRF
  *    Default is determined by Pin FLASH_VOL_SEL/GPIO0_A7:
  *	L:VCCIO2 must supply 3.3V
  *	H:VCCIO2 must supply 1.8V
  */
&pmu_io_domains {
	status = "okay";
	pmuio2-supply = <&vcc3v3_pmu>;
	vccio1-supply = <&vccio_acodec>;
	vccio3-supply = <&vccio_sd>;
	vccio4-supply = <&vcc_3v3>;
	vccio5-supply = <&vcc_3v3>;
	vccio6-supply = <&vcc_3v3>;
	vccio7-supply = <&vcc_3v3>;
}
```


 * **VCCIO1(vccio1-supply) 기준(example)**

	![](./images/POWER_01.png)

	위 그림에서 VCCIO1의 power supply device는 vccio_acodec입니다.  
	회로도에서 vccio_acodec를 검색하면 다음 모듈을 찾을 수 있습니다.  

	![](./images/POWER_02.png)  

	위의 그림에서 vccio_acodec이 RK809의 LDO4에 의해 power를 받는 다는 것을 확인 할 수 있습니다.  
	다음과 같이 software의 dts에서 LDO_REG4(LDO4)의 구성 정보를 찾습니다.  

	```dtb
	&i2c0 {
	(...)
		rk809: pmic@20 {
		(...)
			regulators {
				vccio_acodec: LDO_REG4 {
					regulator-always-on;
					regulator-boot-on;
					regulator-min-microvolt = <3300000>;
					regulator-max-microvolt = <3300000>;
					regulator-name = "vccio_acodec";
					regulator-state-mem {
						regulator-off-in-suspend;
					};
				};
			};
		(...)
		};
	};
	```


	위의 vccio_acodec를 pmu_io_domains 노드에서 vccio1-supply = <&vccio_acodec>으로 구성하여 vccio1의 voltage 를 설정했습니다.


 * **MIPI_CSI_RX_AVDD_0V9 & MIPI_CSI_RX_AVDD_1V8 기준(example)**

	 ![](./images/POWER_06.png)

	 위의 그림에서 MIPI_CSI_RX의 power supply device는 *VDDA0V9_IMAGE*, *VCCA1V8_IMAGE* 입니다.   
	 회로도에서 *VDDA0V9_IMAGE*, *VCCA1V8_IMAGE* 을 검색하면 다음 모듈을 찾을 수 있습니다.

	 ![](./images/POWER_07.png)

```dtb
&i2c0 {
	status = "okay";
	(...)

	rk809: pmic@20 {
	(...)
		regulators {
		(...)
			vdda0v9_image: LDO_REG1 {
				regulator-boot-on;
				regulator-always-on;
				regulator-min-microvolt = <900000>;
				regulator-max-microvolt = <900000>;
				regulator-name = "vdda0v9_image";
				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};
		(...)
			vcca1v8_image: LDO_REG9 {
				regulator-always-on;
				regulator-boot-on;
				regulator-min-microvolt = <1800000>;
				regulator-max-microvolt = <1800000>;
				regulator-name = "vcca1v8_image";
				regulator-state-mem {
					regulator-off-in-suspend;
				};
			};
		(...)
		}
	}
```  
      
위의 **vdda0v9_image**, **vcca1v8_image** 를 pmu_io_domains 노드에서 ... 으로 구성하여 vccio1의 voltage 를 설정했습니다.
	  

<pr/>

## power management 관리

 - [x] TSADC_SHUT_M0 : 기능 확인
 - [x] PMIC_SLEEP : 기능 확인
 - [x] VDD_CPU_COM(ARM core power feedback output) : 기능 확인

### TSADC; Temperature-Sensor ADC(TS-ADC)

 TS-ADDC Controller module은 user-defined 모드와 automatic 모드를 지원한다. 
 - user-defined mode 는 direct 제어를 위해 software에서 write를 해당 register에 write하여 제어한다.
 - automati mode는 module에서 자동으로 TSADC 의 출력을 polling 한다.

 일정 period of time 동안 temperature가 높으면 processor down 인터럽트가 발생합니다.
 일정 period of time 동안 temperature가 높으면 TSHUT 에서 CRU 모듈에게 TSHUT 결과를 전달하고, chip 을 reset 하거나 GPIO를 통해 PMIC를 제어 한다.

 - tsadc configuration
 tsadc (thermal sensor)는 
 thermal control의 thermal sensor인 tsadc는 temperature 데이터를 얻는데 사용된다. 일반적으로 dtsi와 dts에서 configuration을 해야한다.

```dtb
	tsadc: tsadc@fe710000 {
		compatible = "rockchip,rk3568-tsadc";
		reg = <0x0 0xfe710000 0x0 0x100>;			/* 레지스터의 basic address, length */
		interrupts = <GIC_SPI 115 IRQ_TYPE_LEVEL_HIGH>;	/* interrupt number , trigger method */
		rockchip,grf = <&grf>;				/* grp module 호출 */
		clocks = <&cru CLK_TSADC>, <&cru PCLK_TSADC>;
		clock-names = "tsadc", "apb_pclk";
		assigned-clocks = <&cru CLK_TSADC_TSEN>, <&cru CLK_TSADC>;		/* working clock, configuration clock */
		assigned-clock-rates = <17000000>, <700000>;
		resets = <&cru SRST_TSADC>, <&cru SRST_P_TSADC>,				/* reset signal */
			 <&cru SRST_TSADCPHY>;
		reset-names = "tsadc", "tsadc-apb", "tsadc-phy";
		/**
		 * thermal sensor symbol, tsadc 가 thermal sensor가 될수 있음을 의미. 
		 * tsadc 노드를 호출할 때 필요한 매개변수 수를 지정한다.
		 * soc 에 tsadc가 한개만 있을 경우, 0으로 세팅해야 하며, 1개 이상인 경우, 1로 세팅한다.
		 */
		#thermal-sensor-cells = <1>;
		rockchip,hw-tshut-temp = <120000>;	/* the threshold temperature of reboot,  120 degree */
		rockchip,hw-tshut-mode = <0>; /* tshut mode 0:CRU 1:GPIO */
		rockchip,hw-tshut-polarity = <0>; /* tshut polarity 0:LOW 1:HIGH */
		pinctrl-names = "gpio", "otpout";
		pinctrl-0 = <&tsadc_gpio_func>;
		pinctrl-1 = <&tsadc_shutorg>;
		status = "disabled";
	};


	/** 
 	 * IO port Configuration
	 */
	gpio-func {
		/* configure it to be gpio mode */
		/omit-if-no-ref/
		tsadc_gpio_func: tsadc-gpio-func {
			rockchip,pins =
				<0 RK_PA1 RK_FUNC_GPIO &pcfg_pull_none>;
		};
	};

	tsadc {
		/omit-if-no-ref/
		tsadcm0_shut: tsadcm0-shut {
			rockchip,pins =
				/* tsadcm0_shut */
				<0 RK_PA1 1 &pcfg_pull_none>;
		};

		/omit-if-no-ref/
		tsadcm1_shut: tsadcm1-shut {
			rockchip,pins =
				/* tsadcm1_shut */
				<0 RK_PA2 2 &pcfg_pull_none>;
		};

		/* configure it to be over temperature protection mode */
		/omit-if-no-ref/
		tsadc_shutorg: tsadc-shutorg {
			rockchip,pins =
				/* tsadc_shutorg */
				<0 RK_PA1 2 &pcfg_pull_none>;
		};
	};

```
 dts configure 는 주로 CRU reset 또는 gpio reset, 저전압 reset , 고전압 reset 을 선택하는데 사용된다. 
 *pio reset으로 configure하려면 tsadc 출력 핀을 pmic reset 핀에 연결해야 한다. 그렇지 않은면 CRU reset으로만 구성할 수 있다.*

> CRU reset : CPU reset 은 ARM processor가 치명적인 오류를 감지했을때 발생하는 유형의 재설정. 

 - develop document : Documentation/devicetree/bindings/thermal/rockchip-thermal.txt

-----

### VDD_CPU_COM ; arm core power feedback output 인터페이스
 ARM 코어 전원 피드백 출력 인터페이스는 ARM 코어의 전원 상태를 모니터링하기 위해 사용됩니다. 이 인터페이스는 전압, 전류 및 온도와 같은 다양한 전원 매개변수를 제공합니다. 이 정보는 ARM 코어의 전원 관리를 위해 사용될 수 있습니다.

 ARM 코어 전원 피드백 출력 인터페이스는 일반적으로 ARM 코어의 전원 관리 컨트롤러에 연결됩니다. 전원 관리 컨트롤러는 이 정보를 사용하여 ARM 코어의 전원을 최적화할 수 있습니다. 예를 들어, ARM 코어의 전압을 낮추거나 전류를 줄임으로써 ARM 코어의 전력을 절약할 수 있습니다.

 ARM 코어 전원 피드백 출력 인터페이스는 ARM 코어의 전원 상태를 모니터링하고 전원 관리를 최적화하는 데 중요한 도구입니다.

-----

### TCS4525 Voltage Regulator

 - driver location
```bash
drivers/regolator/fan53555.c
```

 - dts node
```dts
	vdd_cpu: tcs4525@1c {
		compatible = "tcs,tcs452x";
		reg = <0x1c>;
		/* supply parameter ; hardware input voltage. no actual meaning, */
		vin-supply = <&vcc5v0_sys>;	
		regulator-compatible = "fan53555-reg";
		regulator-name = "vdd_cpu";
		regulator-min-microvolt = <712500>;
		regulator-max-microvolt = <1390000>;
		regulator-init-microvolt = <900000>;
		regulator-ramp-delay = <2300>;
		/**
		 * 이것은 IO가 서로 다른 voltage의 두 그룹을 변경하는 데 사용되지만,
		 * 현재는 스위치를 빠르게 변경하는 데 사용됩니다.
		 * <1> : VSEL pin is connected to pmic_sleep.
		 * <0> : VSEL pin이 low일 때 running voltage을 출력하고,
		 *       high일 때 idle voltage을 출력한다(대기 시 꺼짐으로 설정할 수도 있음).
		 */
		fcs,suspend-voltage-selector = <1>;
		regulator-boot-on;
		regulator-always-on;
		regulator-state-mem {
			regulator-off-in-suspend;
		};
	};

```


<pr/>

## register check 
> 부팅 후, 레지스터 값을 체크하여 voltage 디버깅

RK3568 칩은 Datasheet 에 따라서 PMU_GRF_IO_VSEL0 ~ PMU_GRP_IO_VSEL2 레지스터 주소(base addr : 0xFDC20140~0xFDC20148) 메모리를 통해 I/O 가능합니다.

![](./images/POWER_03.png)
![](./images/POWER_04.png)
![](./images/POWER_05.png)

| register         	| address    	| command             	| reset value 	|
|------------------	|------------	|---------------------	|-------------	|
| PMU_GRF_IO_VSEL0 	| 0xFDC20140 	| io -4 -r 0xFDC20140 	| 0x00000000  	|
| PMU_GRF_IO_VSEL1 	| 0xFDC20144 	| io -4 -r 0xFDC20144 	| 0x000000ff  	|
| PMU_GRF_IO_VSEL2 	| 0xFDC20148 	| io -4 -r 0xFDC20148 	| 0x00000030  	|


## Memo

 ### DCDC(Direct Cuttent)와 LDO(Low dropout regulator) 차이
 DCDC(Direct Current to Direct Current) 컨버터와 LDO(Low Dropout Regulator)는 모두 전력을 조절하는 장치입니다. 
 DCDC 컨버터는 입력 전압과 출력 전압이 서로 다를 수 있는 반면, LDO 컨버터는 입력 전압과 출력 전압이 동일해야 합니다. 
 DCDC 컨버터는 일반적으로 LDO 컨버터보다 효율성이 높지만, LDO 컨버터는 더 작고 저렴합니다.

 DCDC 컨버터는 일반적으로 전원을 공급하는 장치의 전압을 높이거나 낮추는 데 사용됩니다. 
 예를 들어, 12V 자동차 배터리에서 작동하는 장치에 5V 전원을 공급하려면 DCDC 컨버터가 필요합니다. 

 LDO 컨버터는 일반적으로 민감한 장치에 전원을 공급하는 데 사용됩니다. 
 예를 들어, 컴퓨터의 마더보드에 있는 칩셋은 LDO 컨버터로 전원을 공급받습니다.

 DCDC 컨버터와 LDO 컨버터는 모두 전원을 효율적으로 조절하는 데 사용할 수 있습니다.
 그러나 특정 응용 프로그램에 가장 적합한 컨버터는 장치의 전압 요구 사항과 민감도에 따라 다릅니다.

 아래는 DCDC 컨버터와 LDO 컨버터의 주요 차이점입니다.

| **특성**              	| **DCDC 컨버터**                                         	| **LDO 컨버터**                          	|
|-----------------------	|---------------------------------------------------------	|-----------------------------------------	|
| 입력 전압과 출력 전압 	| 서로 다를 수 있음                                       	| 동일해야 함                             	|
| 효율성                	| 일반적으로 LDO 컨버터보다 높음                          	| 일반적으로 LDO 컨버터보다 낮음          	|
| 크기                  	| 일반적으로 LDO 컨버터보다 큼                            	| 일반적으로 LDO 컨버터보다 작음          	|
| 비용                  	| 일반적으로 LDO 컨버터보다 비쌈                          	| 일반적으로 LDO 컨버터보다 저렴함        	|
| 응용 프로그램         	| 전원을 공급하는 장치의 전압을 높이거나 낮추는 데 사용됨 	| 민감한 장치에 전원을 공급하는 데 사용됨 	|

 - RK3568+RK809에 대한 power supply solution 이미지 

![](./images/POWER_08.png)  
  
 - rk809 는 5개의 BUCK(LOGIC, GPU, DDR_VDDQ, NPU, 1V8)  에 power 를 공급함.
 - rk809 는 11개의 LDO(IMAGE, 0V9, PMU, ACODEC, SD, PMU, 1V8, PMU, IMAGE, SD, 3V3) 에 power 를 공급함.
