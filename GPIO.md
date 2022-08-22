# GPIO 

## GPIO Pin to calculate

RK3568 은 5 개의 GPIO bank 를 가지고 있습니다. (GPIO1, GPIO2, GPIO3, GPIO4, GPIO5)  
각각의 그룹은 A0-A7, B0-B7, C0-C7, D0-D7 으로 넘버링 되며, 아래 공식은 GPIO pin number 를 계산하는데 사용됩니다. 

```bash
GPIO pin calculation formula : pin = bank * 32 + number
GPIO group number calculation formula : number = group * 8 + X
```

예) GPIO4_D5 의 경우 아래와 같습니다.
- bank		=	4;	//	GPIO4_D5 => 4,bank ∈ [0,4]
- group		=	3;	//	GPIO4_D5 => 3,group ∈ {(A=0), (B=1), (C=2), (D=3)}
- X			=	5;	//  GPIO4_D5 => 5,X ∈ [0,7]

  * number = group * 8 + X = 3 * 8 + 5 = 29
  * pin = bank * 32 + number = 4 * 32 + number = 4 * 32 + 29 = 157;




GPIO0_C0 의 경우 아래와 같습니다.
- bank		=	0	//	GPIO0_C0 -> 0, bank ∈ [0,4]  
- group		=	2	//	GPIO0_C0 -> 2, group ∈ {(A=0), (B=1), (C=2), (D=3)}  
- X 		=	0	//	GPIO0_C0 -> 0, X ∈ [0,7]  

  * number = group * 8 + X = 2 * 8 + 0 = 16
  * pin = bank * 32 + number = 0 * 32 + 16 = 16


GPIO0_C0 의 dts property는 아래와 같이 정의 되어 있습니다. 
> arch/arm64/boot/dts/rockchip/rk3568-evb.dtsi

```dts
	leds: leds {
		compatible = "gpio-leds";
		work_led: work {
			gpios = <&gpio0 RK_PC0 GPIO_ACTIVE_HIGH>;
			linux,default-trigger = "heartbeat";
		};
	};
```

include/dt-bindings/pinctrl/rockchip.h 에 macro 정의가 있습니다. GPIO0_C0은 <&gpio0 RK_PC0 GPIO_ACTIVE_HIGH>으로 기술될 수 있습니다. 
```c
#define RK_GPIO0	0
#define RK_GPIO1	1
#define RK_GPIO2	2
#define RK_GPIO3	3
#define RK_GPIO4	4
#define RK_GPIO6	6

#define RK_PA0		0
#define RK_PA1		1
#define RK_PA2		2
#define RK_PA3		3
#define RK_PA4		4
#define RK_PA5		5
#define RK_PA6		6
#define RK_PA7		7
#define RK_PB0		8
#define RK_PB1		9
#define RK_PB2		10
#define RK_PB3		11
#define RK_PB4		12
#define RK_PB5		13
#define RK_PB6		14
#define RK_PB7		15
#define RK_PC0		16
```

GPIO0_C0 은 다른 Function 으로 사용될 수 있습니다.  
아래 예제는 GPIO0_C0 핀이 다른 peripherals으로 사용되지 않을 때, export하여 사용하는 예제 입니다. 
```c
ls /sys/class/gpio/
echo 16 > /sys/class/gpio/export

```
