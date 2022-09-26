# USB

-----

# 1. RK3568 USB 컨트롤러 및 PHY 소개
RK3568는 1개의 OTG 인터페이스, 1개의 USB 3.0 호스트 인터페이스 및 2개의 USB2.0 호스트 인터페이스를 포함하여 총 4개의 USB 주변 장치 인터페이스를 지원합니다.
USB 인터페이스 이름과 인터페이스 유형 간의 해당 관계는 다음과 같습니다.

| Chip   	| OTG0       	| HOST1        	| HOST2        	| HOST3        	|
|--------	|------------	|--------------	|--------------	|--------------	|
| RK3568 	| USB3.0 OTG 	| USB 3.0 HOST 	| USB 2.0 HOST 	| USB 2.0 HOST 	|
| RK3566 	| USB2.0 OTG 	| USB 3.0 HOST 	| USB 2.0 HOST 	| USB 2.0 HOST 	|

1.1 rk3568-poc 사용 USB 컨트롤러

| **board**  	| **OTG0**    	| **HOST1** 	| **HOST2**     	| **HOST3** 	|
|------------	|-------------	|-----------	|---------------	|-----------	|
| rk3568-poc 	| usb 2.0 otg 	| X         	| usb 2.0 host  	| X         	|


아래 그림은 RK356x USB controller와 PHY 간 다이어그램입니다.

  ![](./images/USB_03.png)

 1. 각 USB2.0 PHY에는 USB2.0 컨트롤러에서 각각 사용하는 2개의 포트가 있습니다. 
 2. OTG 포트의 USB3.0 컨트롤러와 SATA0 컨트롤러는 Combo PHY0을 공유하고,  HOST1포트의 USB3.0 컨트롤러와 SATA1/QSGMII 컨트롤러는  Combo PHY1을 공유합니다. 
   OTG 포트의 SATA0와 USB3.0 기능은 함께 사용할 수 없으므로, 제품 형태에 따라 구성해야 합니다.
 3. **EHCI/OHCI**는 USB 컨트롤러가 EHCI 컨트롤러와 OHCI 컨트롤러를 통합하는 것을 의미합니다. 
   **DWC3/xHCI**는 USB 컨트롤러가 DWC3 컨트롤러와 xHCI 컨트롤러를 통합하는 것을 의미합니다.


-----

# 2. RK3568 USB 하드웨어 회로 설계

## 2.1 RK3568 USB 2.0/3.0 PHY power supply controller

RK3568 에는 2개의 USB 2.0 PHY가 포함되어 있으며, 각각에는 3.3V, 1.8V 및 0.9V의 세가지의 power supply 장치가 있습니다. 이 세가지의 power supply 장치의 전압 요구사항은 아래와 같습니다.

| **Supply Voltage** 	| **Min** 	| **Typ** 	| **Max** 	| **Unit** 	|
|--------------------	|---------	|---------	|---------	|----------	|
| USB_AVDD_3V3       	| 3.0     	| 3.3     	| 3.6     	| V        	|
| USB_AVDD_1V8       	| 1.62    	| 1.8     	| 1.98    	| V        	|
| USB_AVDD_0V9       	| 0.81    	| 0.9     	| 0.99    	| V        	|


## 2.2 RK3568 USB OTG 인터페이스 하드웨어 회로

RK3568 OTG 포트 하드웨어 설계시 고려사항.

- DP/DM 의 anti-pressure/anti-static capability를 향상 시키려면, 2.2Ω resistors 에 연결해야 합니다.
- USB device의 동적 플러그 감지 및 충전 유형을 감지를 지원하려면 VBUSDET 핀을 USB 인터페이스에 연결해야 합니다.
- USB 장치 동적 플러그 감지 및 충전 유형 감지 기능을 사용 하지 않는 경우, VBUSDET 핀을 최대 3.3V로 pull-up하거나 floating 상태로 둘수 있습니다.(3.3V pullup 추천)
  RK3568의 maskrom USB의 경우, VBUSDET 핀이 floating 상태로 남아있어도 정상적으로 작동하고 펌웨어 다운로드가 가능합니다.

 
RK3568의 OTG 는 일반적으로 아래 3가지 타입으로 설계됩니다.

### 2.2.1. RK3568 OTG 포트 : Micro-B 인터페이스 회로 설계
### 2.2.2. RK3568 OTG 포트 : Type-A 인터페이스 회로 설계
  - USB2.0 Type-A 인터페이스 : (rk3568-poc)
  - USB3.0 Type-A 인터페이스 
### 2.2.3. RK3568 OTG 포트 : Type-C 인터페이스 회로 설계

## 2.3 RK3568 USB 3.0 HOST1 인터페이스 하드웨어 회로

RK3568 USB 3.0 HOST Type-A 인터페이스 하드웨어 회로는 OTG 포트 Type-A 인터페이스 회로와 유사하지만 차이점은 Rk3568 USB 3.0 HOST 에는 VBUSDET 핀과  ID 핀이 없습니다.

## 2.4 RK3568 HOST2/HOST3 인터페이스 하드웨어 회로


-----

# 3. RK3568 USB DTS configuration 

RK3568 USB 하드웨어 회로는 다양한 특성, 특히 USB OTG 포트의 유연한 하드웨어 회로와 복잡한 USB 3.0/SATA/QSGMII Combo PHY 다중화 관계를 가지고 있습니다. 


## 3.1 RK3568 OTG configuration

RK3568 OTG 의 DTS node 이름은 다음과 같이 정의되어져 있습니다.

| **usbdrd30**               	| **usbdrd_dwc3**           	| **usb2phy0**                                     	| **u2phy0_otg**         	| **combphy0_us**  	|
|----------------------------	|---------------------------	|--------------------------------------------------	|------------------------	|------------------	|
| usb controller parent node 	| usb controller child node 	| usb 2.0 PHY parent node (shared with HOST1 port) 	| usb 2.0 PHY child node 	| usb 3.0 PHY node 	|

🚩 note : RK3568 OTG 포트는 USB2.0 및 USB3.0 기능을 지원하며 동일한 USB 컨트롤러에 속하며 DTS node 이름은 usbdrd30 및 usbdrd_dwc3 입니다.  


### 3.1.2. RK3568 OTG 으로 구성된 RK3568 OTG

USB3.0 으로 사용되는 RK3568 OTG의 DTS 구성은 아래와 같습니다.

```dtb
&combphy0_us {				// usb 3.0 phy node
	status = "okay";
};

&u2phy0_otg {				// usb 2.0 phy child node
	vbus-supply = <&vcc5v0_otg>;
	status = "okay";
};

&usb2phy0 {					// usb 2.0 phy parent node 
	status = "okay";
};

&usbdrd_dwc3 {				// usb controller child node
	dr_mode = "otg";
	extcon = <&usb2phy0>;
	status = "okay";
};

&usbdrd30 {					// usb controller parent node
	status = "okay";
};
```

- u2phy0_otg의 vbus-supply는 OTG 포트의 VBUS configuration 입니다.
- OTG 포트에 HOST/DEVICE 전환 기능이 필요하지만 기본적으로 호스트 모드에서 작동해야 하는 경우, usbdrd_dwc3에서 dr_mode를 otg 로 구성한다음 전환 명령에 따라 동작을 취합니다.
  (예를 들어, 초기화에서 init.rc의 명령을 사용하여 OTG포트의 USB 모드를 HOST로 전환합니다.)

### 3.1.3. USB 2.0 으로 configuration

USB2.0 인터페이스로 구성된 RK3568 OTG의 DTS configuration 은 아래와 같습니다.
(rk3568 poc)

```dtb
&combphy0_us {				// usb 3.0 phy node
	rockchip,dis-u3otg0-port;
	/* OTG 와 SATA0 에서 combphy0_us을 사용하지 않으면 비활성화 합니다. */
	status = "okay";
};

&u2phy0_otg {				// usb 2.0 phy child node
	vbus-supply = <&vcc5v0_otg>;
	status = "okay";
};

&usb2phy0 {					// usb 2.0 phy parent node
	status = "okay";
};

&usbdrd_dwc3 {				// usb controller child node
	dr_mode = "otg";
	phys = <&u2phy0_otg>;
	phy-names = "usb2-phy";
	extcon = <&usb2phy0>;
	maximum-speed = "high-speed";
	snps,dis_u2_susphy_quirk;
	status = "okay";
};

&usbdrd30 {					// usb controller parent node
	status = "okay";
};
```

- combphy0_us 노드는 OTG USB3.0 PHY와 SATA0에 의해 다중화 되기 때문에, OTG USB3.0 PHY가 combphy0_us 를 사용하지 않고 SATA0 에서 combphy0_us을 사용하는 경우, DTS의 OTG3.0 PHY 의 구성에 따라 combphy0_us을 구성해야 합니다. 
  SATA0 에서 combphy0_us을 사용하지 않는 경우, combphy0_us의 하드웨어 회로에 전원이 공급되지 않으므로 DTS에서 combphy0_us 의 configuration 을 꺼야 합니다. 
- u2phy0_otg의 vbus-supply는 OTG 포트의 VBUS 전원 configuration입니다. 


## 3.2. RK3568 HOST1 configuration
 RK3568 HOST1의 DTS 노드이름은 아래와 같이 정의 됩니다.

| **usbhost30**              	| **usbhost_dwc3**          	| **usb2phy0**                                  	| **u2phy0_host**        	| **combphy1_usq** 	|
|----------------------------	|---------------------------	|-----------------------------------------------	|------------------------	|------------------	|
| usb controller parent node 	| usb controller child node 	| usb2.0 PHY parent node (shared with OTG port) 	| usb 2.0 PHY child node 	| usb 3.0 PHY node 	|

### 3.2.1. USB3.0 으로 구성된 RK3568 HOST1 HOST3.0 으로 사용되는 RK3568 HOST1의 DTS configuration 은 아래와 같습니다.

```dtb
&combphy1_usq {				// usb 3.0 phy node
	status = "okay";
};

&u2phy0_host {				// usb 2.0 phy child node
	phy-supply = <&vcc5v0_host>;
	status = "okay";
};

&usb2phy0 {					// usb2.0 phy parent node
	status = "okay";
};

&usbhost_dwc3 {				// usb controller child node
	status = "okay";
};

&usbhost30 {				// usb controller parent node
	status = "okay";
};
```

- u2phy0_host 의 phy-supply는 Host1 포트의 VBUS 전원과  구성합니다.

### 3.2.2. RK3568 HOST1 이 USB2.0 으로만 사용되는 경우.
 RK3568 의 HOST1 인터페이스가 USB2.0으로만 사용되는 경우, DTS configuration 입니다.

```dtb
&combphy1_usq {				// usb 3.0 phy node
	rockchip,dis-u3otg1-port;
	/* HOST1, SATA1, QSGMII는 combphy1_usq를 사용하며, 사용하지 않은 경우, disabled */
	status = "okay";
};

&u2phy0_host {				// usb 2.0 phy child node
	phy-supply = <&vcc5v0_host>;
	status = "okay";
};

&usb2phy0 {					// usb 2.0 phy parent node
	status = "okay";
};

&usbhost_dwc3 {				// usb controller child node
	phys = <&u2phy0_host>;
	phy-names = "usb2-phy";
	maximum-speed = "high-speed";
	status = "okay";
};

&usbhost30 {				// usb controller parent node
	status = "okay";
};

```

- combphy1_usq node는 HOST1의 USB3.0 PHY와 SATA1/QSGMII에 의해 다중화합니다.  HOST1 및 SATA1/QSGMII의 USB3.0 PHY가 combphy1_usq를 사용하지 않는 경우, 비활성화 해야합니다.
- HOST1을 사용하지 않는 경우, 제거하면 됩니다. 하지만, usb2phy0 노드는  OTG 와 공유가 되며, 기본적으로  OTG포트를 사용하므로 함께 확인이 필요합니다.


## 3.3. RK3568 HOST2 configuration

| **usb_host0_ehci**     	| **usb_host0_ochi**        	| **usb2phy1**                           	| **u2phy1_otg**  	|
|------------------------	|---------------------------	|----------------------------------------	|-----------------	|
| sub HS controller node 	| usb FS/LS controller node 	| usb phy parent node(shared with host3) 	| usb phy subnode 	|

Rk3568 HOST2 dts configuration

```dtb
&u2phy1_otg {
	phy-supply = <&vcc5v0_host>;
	status = "okay";
};

&usb2phy1 {
	status = "okay";
};

&usb_host0_ehci {
	status = "okay";
};

&usb_host0_ohci {
	status = "okay";
};
```

- u2phy1_otg의 phy-supply는 HOST2 포트의 VBUS 전원 구성입니다. 
- HOST2가 하드웨어 사용되지 않는 경우, 위의 구성을 제거하면 닫힙니다. 하지만  usb2phy1 노드는 HOST3 과 공유되며 즉, HOST2, HOST3이 모두 사용되지 않는 경우 닫습니다.

## 3.4. RK3568 HOST3 configuration

| **usb_host1_ehci**     	| **usb_host1_ochi**        	| **usb2phy1**                           	| **u2phy1_host**  	|
|------------------------	|---------------------------	|----------------------------------------	|-----------------	|
| sub HS controller node 	| usb FS/LS controller node 	| usb phy parent node(shared with host2) 	| usb phy subnode 	|

Rk3568 HOST3 dts configuration

```dtb
&u2phy1_host {
	phy-supply = <&vcc5v0_host>;
	status = "okay";
};

&usb2phy1 {
	status = "okay";
};

&usb_host1_ehci {
	status = "okay";
};

&usb_host1_ohci {
	status = "okay";
};
```

- HOST3이 하드웨어에서 사용되지 않는 경우 configuration을 제거 하십시오. usb2phy1 노드는 HOST2와 공유되며 HOST2 및 HOST3 이 모두 사용되지 않는 경우에만 닫습니다.


## USB VBUS configuration
 Rockchip 플랫폼의 USB VBUS 제어 회로에는 일반적으로 GPIO control power supply voltage regulator chip output, Rockchip PMIC output, hardware direct outpu(software로 제어되지 않음.)과 같은 여러 방식이 포함됩니다.


### 3.5.1. GPIO control power supply voltage retgulator chip output VBUS
 이 솔루션을 통하여 일반적으로 충전 솔루션이 없는 USB Host 포트 및 OTG 포트에 적용가능하며, DTS configuration을 다음과 같습니다.

```dtb
vcc5v0_otg: vcc5v0-otg-regulator {
	compatible = "regulator-fixed";
	enable-active-high;
	gpio = <&gpio0 RK_PA5 GPIO_ACTIVE_HIGH>;
	pinctrl-names = "default";
	pinctrl-0 = <&vcc5v0_otg_en>;
	regulator-name = "vcc5v0_otg";
};


&pinctrl {
	...
	usb {
	vcc5v0_otg_en: vcc5v0-otg-en {
		rockchip,pins = <0 RK_PA5 RK_FUNC_GPIO &pcfg_pull_none>;
	};
};
...
```

### 3.5.2. Rockchip의 PMIC VBUS output
 이 솔루션은 일반적으로 충전 솔루션이 있는 OTG 포트에 적용되며 DTS configuration 은 아래와 같습니다.

```dtb
rk817: pmic@20 {
	...
	regulators {
		otg_switch: OTG_SWITCH {
			regulator-name = "otg_switch";
			regulator-state-mem {
				regulator-off-in-suspend;
			};
		};
	};
	...
};
```

- Rk817에서 configuation되었습니다.


-----

# 4. RK3568 USB OTG mode switch command
 RK3568 SDK는 USB 2.0/3.0 OTG의 forced setting을 지원하며, USB 하드웨어 회로 또는 Type-C 인터페이스의 OTG ID 레벨에 영향을 받지 않고, 소프트웨어 방식을 통해 Host / Peripheral mode 로 전환합니다.

 RK3568 Linux-4.19 kernel 에서 Peripher mode 또는 Host mode 스위칭 USB 컨트롤러 방법.

```bash
#1.Force host mode
echo host > /sys/devices/platform/fe8a0000.usb2-phy/otg_mode

#2.Force peripheral mode
echo peripheral > /sys/devices/platform/fe8a0000.usb2-phy/otg_mode

#3.Force otg mode
echo otg > /sys/devices/platform/fe8a0000.usb2-phy/otg_mode

```


🚩 note  : 일부 응용프로그램에서 기본적으로  OTG 포트가 HOST 모드로 작동하게 하려면, DTS의 dr_mode를 기본적으로 "otg"로 구성한 다음, **Force host mode** 명령을 사용하는 것이 좋습니다.
(as init.rc)


-----
🚩 note 

✔ usb interface   

**(OTG0_HS/FS/LS)**
  * USB3_OTG0_DP
  * USB3_OTG0_DM

**(HOST1_HS/FS/LS)**
  * USB3_HOST1_DP
  * USB3_HOST1_DM

**(USB2.0 HOST)**
  * USB2_HOST2_DP
  * USB2_HOST2_DM

  * USB2_HOST3_DP
  * USB2_HOST3_DM

**(USB3.0 OTG0_SS)**
  * USB3_OTG0_SSTXP
  * USB3_OTG0_SSTXN
  * USB3_OTG0_SSRXP
  * USB3_OTG0_SSRXN

**(USB30 HOST1_SS)**
  * USB3_HOST1_SSTXP
  * USB3_HOST1_SSTXN
  * USB3_HOST1_SSRXP
  * USB3_HOST1_SSRXN



-----

✔ 용어 설명

- USB 2.0 : PC의 각종 주변 장치들을 연결하기 위한 인터페이스 규격 중 하나.   
  다양한 버전이 있으며, 버전별로 속도가 다르다.(2.0의 경우, 480Mbit/s 의 데이터 속도)  
- SSUSB : SuperSpeed USB는 버전 3을 일컷는 말이다.  
  버전3은 부르는게 다양한데 3.0=3.1GEN1=3.2GEN1 같은 말이다.   
  (2~20Gbps의 전송속도를 가지고 있다.)  
- Critical Signals  
  * DP : USB 2.0 differential data pair, positive, D+
  * DM : USB 2.0 differential data pair, negative, D-
  * SSTXP : SSUSB differential data pair, TX, positive, D+
  * SSTXN : SSUSB differential data pair, TX, negative, D+
  * SSRXP : SSUSB differential data pair, RX, positive, D-
  * SSRXN : SSUSB differential data pair, RX, negative, D-

	  
-----


✔ 커넥터
- USB 3.0 커넥터

  ![](./images/USB_01.png)

- USB 2.0 커넥터

  ![](./images/USB_02.png)
