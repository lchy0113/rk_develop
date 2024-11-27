# GPIO 

<br/>
<br/>
<br/>
<hr>

## GPIO Pin to calculate

RK3568 은 5 개의 GPIO bank 를 가지고 있습니다. (GPIO1, GPIO2, GPIO3, GPIO4, GPIO5)  
각각의 그룹은 A0-A7, B0-B7, C0-C7, D0-D7 으로 넘버링 되며, 아래 공식은 GPIO pin number 를 계산하는데 사용됩니다. 

```bash
GPIO pin calculation formula : pin = bank * 32 + number
GPIO group number calculation formula : number = group * 8 + X
```

예) GPIO4_D5 의 경우 아래와 같습니다.
- bank = 4;  //  GPIO4_D5 => 4,bank ∈ [0,4]
- group = 3; //  GPIO4_D5 => 3,group ∈ {(A=0), (B=1), (C=2), (D=3)}
- X = 5;     //  GPIO4_D5 => 5,X ∈ [0,7]

  * number = group * 8 + X = 3 * 8 + 5 = 29
  * pin = bank * 32 + number = 4 * 32 + number = 4 * 32 + 29 = 157;


GPIO0_C0 의 경우 아래와 같습니다.
- bank  =  0    //  GPIO0_C0 -> 0, bank ∈ [0,4]  
- group =  2    //  GPIO0_C0 -> 2, group ∈ {(A=0), (B=1), (C=2), (D=3)}  
- X     =  0    //  GPIO0_C0 -> 0, X ∈ [0,7]  

  * number = group * 8 + X = 2 * 8 + 0 = 16
  * pin = bank * 32 + number = 0 * 32 + 16 = 16


GPIO0_D0 의 경우 아래와 같습니다.
- bank  = 0    //    GPIO0_D0 -> 0, bank ∈ [0,4] 
- group = 3    //    GPIO0_D0 -> 3, group ∈ {(A=0), (B=1), (C=2), (D=3)}
- X     = 0    //    GPIO0_D0 -> 0, X ∈ [0,7] 

  * number = group * 8 + X = 3 * 8 + 0 = 24
  * pin = bank * 32 + number = 0 * 32 + 24 = 24

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

include/dt-bindings/pinctrl/rockchip.h 에 macro 정의
GPIO0_C0은 <&gpio0 RK_PC0 GPIO_ACTIVE_HIGH>으로 기술. 

```c
#define RK_GPIO0    0
#define RK_GPIO1    1
#define RK_GPIO2    2
#define RK_GPIO3    3
#define RK_GPIO4    4
#define RK_GPIO6    6

#define RK_PA0      0
#define RK_PA1      1
#define RK_PA2      2
#define RK_PA3      3
#define RK_PA4      4
#define RK_PA5      5
#define RK_PA6      6
#define RK_PA7      7
#define RK_PB0      8
#define RK_PB1      9
#define RK_PB2      10
#define RK_PB3      11
#define RK_PB4      12
#define RK_PB5      13
#define RK_PB6      14
#define RK_PB7      15
#define RK_PC0      16
```

GPIO0_C0 은 다른 Function 으로 사용 가능함.  
아래 예제는 GPIO0_C0 핀이 다른 peripherals으로 사용되지 않을 때, export하여 사용하는 예제. 

```c
ls /sys/class/gpio/
echo 16 > /sys/class/gpio/export
```

<br/>
<br/>
<br/>
<hr>

## pinctrl

 pinctrl 은 mux, driver strength, pull-up, pull-down, etc 를 포함.

 driver file

```bash
drivers/pinctrl/devicetree.c
```

 driver dts node 구성에서 probe 시, "default"에 해당하는 그룹


 - pinctrl 전환 

> pinctrl_lookup_state() 특정 상태를 찾는 함수
> pinctrl_select_state() 특정 상태를 선택하여 핀의 동작 모드를 변경

   * pinctrl_lookup_state()
 주어진 pinctrl 핸들에서 특정 상태를 찾는다.
 상태는 보통 device tree에 정의.

```c
struct pinctrl_state *pinctrl_lookup_state(struct pinctrl *p, const char *name)
 /**
  * p : pinctrl 핸들.
  * name : 찾고자 하는 상태 이름
  * return : 성공 시 상태에 대한 포인터, 실패 시 오류 포인터 반환(IS_ERR macro를 통해 확인)
  */
struct pinctrl_state *state;
state = pinctrl_lookup_state(pinctrl, "default");
if (IS_ERR(state)) {
    dev_err(dev, "Failed to lookup pinctrl state\n");
    return PTR_ERR(state);
}
```

   * pinctrl_select_state()
 주어진 pinctrl 핸들에서 특정 상태를 선택. 
 선택된 상태는 핀의 동작 모드를 변경한다. 

```c
int pinctrl_select_state(struct pinctrl *p, struct pinctrl_state *state)
 /**
  * p : pinctrl 핸들
  * state : 성택할 상태에 대한 포인터.
  * return : 성공시 0, 실패시 음수 오류 코드
  */

int ret;
ret = pinctrl_select_state(pinctrl, state);
if(ret) {
   dev_err(dev, "Failed to select pinctrl state\n");
   return ret;
}

```

