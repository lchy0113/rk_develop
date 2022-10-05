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
## gpio iomux 

### 사용 예제
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

### GRF Address Mapping Table
![](./images/DEBUG_01.png)



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
```

---


## error

```bash
rk3368H_64:/ # io -4 -r 0xFF770028                                                                                                      
open /dev/mem: No such file or directory
1|rk3368H_64:/ #
```
커널에서 아래 옵션을 활성화 해야 합니다.

```
CONFIG_DEVMEM=y
CONFIG_DEVKMEM=y
```

---
