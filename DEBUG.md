# DEBUG
> Debugging method에 대해 정리합니다.

## io instruction

```bash

rk3568_evb:/ # io
Raw memory i/o utility - $Revision: 1.5 $

io -v -1|2|4 -r|w [-l <len>] [-f <file>] <addr> [<value>]

    -v         Verbose, asks for confirmation
    -1|2|4     Sets memory access size in bytes (default byte)
    -l <len>   Length in bytes of area to access (defaults to
               one access, or whole file length)
    -r|w       Read from or Write to memory (default read)
    -f <file>  File to write on memory read, or
               to read on memory write
    <addr>     The memory address to access
    <val>      The value to write (implies -w)

Examples:
    io 0x1000                  Reads one byte from 0x1000
    io 0x1000 0x12             Writes 0x12 to location 0x1000
    io -2 -l 8 0x1000          Reads 8 words from 0x1000
    io -r -f dmp -l 100 200    Reads 100 bytes from addr 200 to file
    io -w -f img 0x10000       Writes the whole of file to memory

Note access size (-1|2|4) does not apply to file based accesses.

1|rk3568_evb:/ #

```

### 사용 방법

```bash
$ io -4 -r 0x1000				// read the value of 4-bit register starting from 0x1000
$ io -4 -w 0x1000				// write the value of the 4-bit register from 0x1000
```

-----

<br/>
<br/>
<br/>
<br/>

## gpio iomux 

### 사용 예제(GPIO3_C5)
 -  View the multiplexing of GPIO3_C5 pins  
 -  From the datasheet of the master control, the base address of the register corresponding to GPIO3 is: 0xFDC60000 (SYS_GRF) 
 -  The offset of GRF_GPIO3C_IOMUX_H found from the datasheet of the master control is: 0x0054 
 -  The address of the iomux register of GPIO3_C5 is: base address (Operational Base) + offset (offset)=0xFDC60000 + 0x0054=0xFDC60054  
 -  Use the following command to check the multiplexing of GPIO3_C5:  

![](./images/DEBUG_02.png)

```bash

rk3568_poc:/ # io -4 -r -l 0x4 0xfdc60054
fdc60054:  00000001
```


 -  find [6:4] from the datasheet:
```bash
gpio3c5_sel
3'h0: GPIO3_C5
3'h1: PWM15_M0
3'h2: SPDIF_TXM1
3'h3: GMAC1_MDIOM0
3'h4: UART7_RXM1
3'h5: I2S1_LRCKRXM2
```

Therefore, it can be determined that the GPIO is multiplexed as 3'h0: GPIO3_C5.

 - The offset of GPIO_SWPORT_DDR_L(Data direction register) found from the datasheet of the master control is : 0x0008
 - The address of the GPIO3 register of GPIO3_C5 is : base address (Operation base) + offset(offset) = 0xfe760000 + 0x000c = 0xfe76000c

```bash
// set directiron to out
rk3568_edp:/ # io -4 -w 0xfe76000c 0x00202060 

// set value to high
rk3568_edp:/ # io -4 -w 0xfe760004 0x00202060 

// set value to low
rk3568_edp:/ # io -4 -w 0xfe760004 0x00200040 
```


### 사용 예제(GPIO0_B7)
 - View the multiplexing of GPIO0_B7 pins  
 - The offset of GRF_GPIO0B_IOMUX_H found from the datasheet of the master control is: 0x000C
 - The address of the iomux register of GPIO0_B7 is : base address (Operation base) + offset(offset) = 0xFDC60000 + 0x000C = 0xFDC6000C  
	 > pin multiplxing 설정

![](./images/DEBUG_04.png)


```bash

// change to gpio0_b7 
rk3568_poc:/ # io -4 -w 0xfdc6000c 0xf0000111

```

 - The offset of GPIO_SWPORT_DDR_L(Data direction register) found from the datasheet of the master control is : 0x0008
 - The address of the GPIO0 register of GPIO0_B7 is : base address (Operation base) + offset(offset) = 0xFDD60000 +  0x0008
	 > in/out 설정

![](./images/DEBUG_05.png)

```bash
// change to output for gpio0_b7
rk3568_poc:/sys/class/gpio/gpio15 # io -4 -w 0xfdd60008 0x800080A4
rk3568_poc:/sys/class/gpio/gpio15 # cat direction
out
```

 - The offset of GPIO_SWPORT_DR_L(Low/High Output data) foud from the datasheet of the master control is : 0x0000 
 - The address of the GPIO0 register of GPIO0_B7 is : base address (Operation base) + offset(offset) = 0xFDD60000 +  0x0000


![](./images/DEBUG_06.png)
```bash
rk3568_poc:/sys/class/gpio/gpio15 # io -4 -w 0xfdd60000 0x80008000
1|rk3568_poc:/sys/class/gpio/gpio15 # cat value
1
rk3568_poc:/sys/class/gpio/gpio15 #

```

gpio4_c7, gpio4_d1 체크  

```bash
// iomux 
1|rk3568_poc:/ # io -4 -r -l 0x8 0xfdc60074
fdc60074:  00001000 00000001
// set hdmitx_scl, hdmitx_hda
```


### 사용 예제(GPIO0_A4)
 - View the multiplexing of GPIO0_A4 pins  

```bash

// change to gpio0_a4 
rk3568_poc:/ # io -4 -r -l 0x10 0xfdc60004
rk3568_poc:/ # io -4 -w 0xfdc60004 0x00030000

rk3568_poc:/ # io -4 -r -l 0x4 0xfdd60008 
rk3568_poc:/ # io -4 -w 0xfdd60008 

```







### GRF Address Mapping Table
![](./images/DEBUG_01.png)

-----

<br/>
<br/>
<br/>
<br/>

## gpio control
> Rockchip_RK3568_TRM_Part1_V1.1-20210301.pdf 652 page
- gpio pin의 data와 direction control은 GPIO_SWPORT_DR_L/GPIO_SWPORT_DR_H 레지스터에 의해 제어됩니다.
- gpio pin의 direction control 은 GPIO_SWPORT_DDR_L/GPIO_SWPORT_DDR_H 레지스터에 의해 제어 됩니다.

* 레지스터 설명

| **GPIOs** 	| **Register** 	| **address** 	|
|-----------	|--------------	|-------------	|
| GPIO0     	| PD_PMU       	| 0xFDD60000  	|
| GPIO1     	| PD_BUS       	| 0xFE740000  	|
| GPIO2     	| PD_BUS       	| 0xFE750000  	|
| GPIO3     	| PD_BUS       	| 0xFE760000  	|
| GPIO4     	| PD_BUS       	| 0xFE770000  	|


ex)
GPIO4_D2 (gpio number;154)(gpio4_26)

![](./images/DEBUG_03.png)

```bash
# gpio4 bank read value, direction
rk3568_poc:/ # io -4 -r -l 0x10 0xfe770000
fe770000:  00000000 00000400 00000000 00000400
rk3568_poc:/ #


# set out direction to gpio4_26 
rk3568_poc:/ # io -4 -w 0xfe77000c 0x04000400 

# set high value to gpio4_26
rk3568_poc:/ # io -4 -w 0xfe770004 0x04000400 

# set high value to gpio0_a6
rk3568_poc:/ # io -4 -w 0xfdd60000 0x40C040

# set low value to gpio0_a6
rk3568_poc:/ # io -4 -w 0xfdd60000 0x40C000

# set strength value to gpio0_a6 (level 5)
rk3568_poc:/ # io -4 -r -l 0x4 0xfdc6007c
fdc6007c:  00000000
rk3568_poc:/ # io -4 -w 0xfdc6007c 0x3f003f

```


ex)
GPIO0_C5 


```bash
// change to gpio0_c5 
rk3568_edpp01:/ # io -4 -r -l 0x4 0xfdc20014
fdc60014:  00000000
rk3568_edpp01:/ # io -4 -w 0xfdc20014 0x00300000

// set output
rk3568_edpp01:/ # io -4 -w 0xfdd6000c 0x00200020

// set high
rk3568_edpp01:/ # io -4 -w 0xfdd60004 0x00200020

/**
  *  io -4 -w 0xfdc20014 0x00300000; io -4 -w 0xfdd6000c 0x00200020; io -4 -w 0xfdd60004 0x00200020
```

ex)
GPIO1_D6 (gpio number; 62) (gpio1_30)

```bash
io -4 -r -l 0x4 0xfdc6001c
```

ex)
GPIO1_D7 (gpio number; 63) (gpio1_31)

```bash
# GRF_GPIO1D_IOMUX_L 
# Address: Operational Base(SYS_GRF; 0xfdc60000) + offest (0x000c)
io -4 -r -l 0x4 0xfdc6001c
fdc6001c:  00001110



# Port Data Direction Register(High)
# Address: Operation Base(0xfe740000) + offset (0x000c)
# 16 bit is high (output)
io -4 -r -l 0x4 0xfe74000c
fe74000c:  00008000


# set High value to gpio1_d7
io -4 -w 0xfe740004 0x80008000
```
-----

<br/>
<br/>
<br/>
<br/>


## u-boot (dm tree)
> 기능: 모든 device driver 간의 binding 및 probe status를 체크.

```bash
// example
[2023-05-30 15:10:38] => dm tree
[2023-05-30 15:10:39]  Addr        Class      Probed    Driver                   Name
[2023-05-30 15:10:39] -------------------------------------------------------------------------
[2023-05-30 15:10:39]  7bd45db0    root       [ + ]   root_driver                root_driver **
[2023-05-30 15:10:39]  7bd45ec0    rsa_mod_ex [   ]   mod_exp_sw                 |-- mod_exp_sw **
[2023-05-30 15:10:39]  7bd45fb0    ramdisk    [   ]   ramdisk-ro                 |-- ramdisk-ro **
[2023-05-30 15:10:39]  7bd460c0    blk        [   ]   ramdisk_blk                |   `-- ramdisk-ro.blk **
[2023-05-30 15:10:39]  7bd46240    firmware   [   ]   psci                       |-- psci *
[2023-05-30 15:10:39]  7bd46330    sysreset   [   ]   psci-sysreset              |   `-- psci-sysreset **
[2023-05-30 15:10:39]  7bd46420    clk        [   ]   fixed_rate_clock           |-- external-gmac0-clock *
[2023-05-30 15:10:39]  7bd464f0    clk        [   ]   fixed_rate_clock           |-- external-gmac1-clock *
[2023-05-30 15:10:39]  7bd46600    nop        [   ]   dwc3-generic-wrapper       |-- usbdrd *
[2023-05-30 15:10:39]  7bd46740    usb        [   ]   dwc3-generic-host          |   `-- dwc3@fcc00000 *
[2023-05-30 15:10:39]  7bd46810    nop        [   ]   dwc3-generic-wrapper       |-- usbhost **
[2023-05-30 15:10:39]  7bd468f0    usb        [   ]   dwc3-generic-host          |   `-- dwc3@fd000000 **
[2023-05-30 15:10:39]  7bd46a00    syscon     [ + ]   rk3568_syscon              |-- syscon@fdc20000 *
[2023-05-30 15:10:39]  7bd46ab0    syscon     [ + ]   rk3568_syscon              |-- syscon@fdc60000 *
[2023-05-30 15:10:39]  7bd46b60    syscon     [   ]   syscon                     |-- syscon@fdca0000 *
[2023-05-30 15:10:39]  7bd46c10    clk        [ + ]   rockchip_rk3568_pmucru     |-- clock-controller@fdd00000 *
[2023-05-30 15:10:39]  7bd46d00    reset      [   ]   rockchip_reset             |   `-- reset *
[2023-05-30 15:10:39]  7bd46dd0    clk        [ + ]   rockchip_rk3568_cru        |-- clock-controller@fdd20000 *
[2023-05-30 15:10:39]  7bd46e80    sysreset   [   ]   rockchip_sysreset          |   |-- sysreset **
[2023-05-30 15:10:39]  7bd46f50    reset      [   ]   rockchip_reset             |   `-- reset *
[2023-05-30 15:10:39]  7bd47060    mmc        [ + ]   rockchip_rk3288_dw_mshc    |-- dwmmc@fe2b0000 **
[2023-05-30 15:10:39]  7bd47250    blk        [   ]   mmc_blk                    |   `-- dwmmc@fe2b0000.blk **
[2023-05-30 15:10:39]  7bd47390    mmc        [ + ]   rockchip_rk3288_dw_mshc    |-- dwmmc@fe2c0000 **
[2023-05-30 15:10:39]  7bd47580    blk        [   ]   mmc_blk                    |   `-- dwmmc@fe2c0000.blk **
[2023-05-30 15:10:39]  7bd47700    spi        [   ]   rockchip_sfc               |-- sfc@fe300000 **
[2023-05-30 15:10:39]  7bd47850    mtd        [   ]   spi_nand                   |   |-- flash@0 **
[2023-05-30 15:10:39]  7bd47940    blk        [   ]   mtd_blk                    |   |   `-- flash@0.blk **
[2023-05-30 15:10:39]  7bd47ac0    spi_flash  [   ]   spi_flash_std              |   `-- flash@1 **
[2023-05-30 15:10:39]  7bd47bb0    blk        [   ]   mtd_blk                    |       `-- flash@1.blk **
[2023-05-30 15:10:39]  7bd47cf0    mmc        [ + ]   rockchip_sdhci_5_1         |-- sdhci@fe310000 **
[2023-05-30 15:10:39]  7bd47ee0    blk        [ + ]   mmc_blk                    |   `-- sdhci@fe310000.blk **
[2023-05-30 15:10:39]  7bd48020    mtd        [   ]   rk_nandc_v9                |-- nandc@fe330000 **
[2023-05-30 15:10:39]  7bd480f0    blk        [   ]   mtd_blk                    |   `-- nandc@fe330000.blk **
[2023-05-30 15:10:39]  7bd48270    crypto     [ + ]   rockchip_crypto_v2         |-- crypto@fe380000 **
[2023-05-30 15:10:39]  7bd48360    rng        [   ]   rockchip-rng               |-- rng@fe388000 *
[2023-05-30 15:10:39]  7bd48450    serial     [   ]   ns16550_serial             |-- serial@fe660000 *
[2023-05-30 15:10:39]  7bd48520    serial     [   ]   ns16550_serial             |-- serial@fe680000 **
[2023-05-30 15:10:39]  7bd48630    adc        [   ]   rockchip_saradc            |-- saradc@fe720000 *
[2023-05-30 15:10:39]  7bd48760    phy        [   ]   rockchip_usb2phy           |-- usb2-phy@fe8a0000 *
[2023-05-30 15:10:39]  7bd48810    phy        [   ]   rockchip_usb2phy_port      |   |-- host-port *
[2023-05-30 15:10:39]  7bd488c0    phy        [   ]   rockchip_usb2phy_port      |   `-- otg-port *
[2023-05-30 15:10:40]  7bd489b0    pinctrl    [ + ]   rockchip_rk3568_pinctrl    |-- pinctrl *
[2023-05-30 15:10:40]  7bd48aa0    gpio       [   ]   gpio_rockchip              |   |-- gpio@fdd60000 *
[2023-05-30 15:10:40]  7bd48b50    gpio       [   ]   gpio_rockchip              |   |-- gpio@fe740000 *
[2023-05-30 15:10:40]  7bd48c00    gpio       [   ]   gpio_rockchip              |   |-- gpio@fe750000 *
[2023-05-30 15:10:40]  7bd48cf0    pinconfig  [   ]   pinconfig                  |   |-- pcfg-pull-up *
[2023-05-30 15:10:40]  7bd48da0    pinconfig  [   ]   pinconfig                  |   |-- pcfg-pull-none *
[2023-05-30 15:10:40]  7bd48e50    pinconfig  [   ]   pinconfig                  |   |-- pcfg-pull-none-drv-level-1 *
[2023-05-30 15:10:40]  7bd48f00    pinconfig  [   ]   pinconfig                  |   |-- pcfg-pull-none-drv-level-2 *
[2023-05-30 15:10:40]  7bd48fb0    pinconfig  [   ]   pinconfig                  |   |-- pcfg-pull-up-drv-level-1 *
[2023-05-30 15:10:40]  7bd49060    pinconfig  [   ]   pinconfig                  |   |-- pcfg-pull-up-drv-level-2 *
[2023-05-30 15:10:40]  7bd49110    pinconfig  [   ]   pinconfig                  |   |-- eth0 **
```

 - binding된 모든 device driver list.
 - [+] 의미는 현재 driver가 probe 완료 되었음을 나타냄.
 - *  의미는 u-boot dtb 에서 참조된것을 나타냄.(그렇지 않은 경우, kernel dtb 에서 참조됨)

-----

<br/>
<br/>
<br/>
<br/>


-----

<br/>
<br/>
<br/>
<br/>

## ALOGD 로깅 매크로

 Android Log level

 1. ERROR
   - 가장 중요한 로그 레벨입니다.
   - 심각한 오류를 나타내며, 앱이 더 이상 정상적으로 작동하지 않을 수 있습니다.

 2. WARN
   - 경고 레벨의 로그입니다.
   - 잠재적인 문제를 나타내며, 앱은 계속 작동할 수 있지만 주의가 필요합니다.

 3. INFO
   - 일반적인 정보를 나타내는 로그입니다.
   - 앱의 상태, 이벤트, 작업 등을 기록합니다.

 4. DEBUG
   - 디버깅 목적으로 사용되는 로그입니다.
   - 개발자가 앱의 동작을 추적하고 문제를 해결하는 데 도움이 됩니다.

 5. VERBOSE
   - 가장 상세한 로그 레벨입니다.
   - 앱의 내부 동작을 자세히 기록합니다.

```bash
//1.
//setprop 명령을 사용하여 임시로 변경.
//터미널에서 다음 명령 실행
adb shell setprop log.tag.MyAppTag DEBUG

//ex, AudioHardwareTiny 모듈 DEBUG 레벨 출력
setprop log.tag.AudioHardwareTiny DEBUG


//2. 
// /data/local.prop 파일에 로그 레벨을 설정하여 재부팅, 
log.tag.MyApp=VERBOSE
// ex, log.tag.AudioHardwareTiny=VERBOSE

//3. 
// Code 에서 System.setProperty() method를 사용하여 로그 레벨 변경
System.setProperty("log.tag.MyAppTag", "DEBUG");

```
