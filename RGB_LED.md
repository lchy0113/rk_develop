# RGB LED

dialog 사, slg4ax44714 모듈을 사용하여 Full Color LED driver 구현


<br/>
<br/>
<br/>
<hr>

## device control

 i2c 통신에서 사용되는 Control Bytes 데이터 구조 설명.
 Control Byte는 i2c 통신이 시작 될 때 보내는 첫 번째 데이터 바이트이며, 아래와 같은 정보를 가지고 있음.

 1. Control Byte 의 구성
 Control Byte 는 8 개의 비트로 구성. 
 - 첫 4 비트 : *Control Code*로 불리며, 사용자가 설정하는 코드.
 - 다음 3비트 : (A10, A9, A8) 는  *Block Address* 역할. 
    데이터를 읽거나 쓸때 사용하는 주소의 상위 3비트를 나타냄. 
 - 마지막 1비트 : 데이터 read(1) or write(0)

 2. Control Byte 이후
 Control Byte가 전송된 후, 다음과 같은 과정 진행.
 - ACK 비트(Acknowledge) 
 
 - Word Address: Control Byte의 Block Address와 결합.

```bash
example 
reg<2027>:<2024>
0000 0111 1110 1011


0000  : control code 
011   : block address
1     : read 



```

<br/>
<br/>
<br/>
<hr>

## register control data
 (addr) : (default value)
 - 0x4c : 0x7e (b01111110)
   * bit0 : PWM enable. Default is 0
   * bit1 : R_LED1 enable. Default is 1
   * bit2 : G_LED1 enable. Default is 1
   * bit3 : B_LED1 enable. Default is 1
   * bit4 : R_LED2 enable. Default is 1 (unuse)
   * bit5 : G_LED2 enable. Default is 1 (unuse)
   * bit6 : B_LED2 enable. Default is 1 (unuse)
 - 0x98 : PWM frequency control data.  0xff (b11111111) /* default is 0xff 25kHz */ /* 0x7c 50kHz */
 - 0x9a : PWM control data for R_LED1  0x7f (b01111111) /* default is 0x7f */
 - 0x9c : PWM control data for G_LED1  0x7f (b01111111) /* default is 0x7f */
 - 0x9e : PWM control data for B_LED1  0x7f (b01111111) /* default is 0x7f */
 - 0xa0 : PWM control data for R_LED2  0x7f (b01111111) /* default is 0x7f */ (unuse)
 - 0xa2 : PWM control data for G_LED2  0x7f (b01111111) /* default is 0x7f */ (unuse)
 - 0xa4 : PWM control data for B_LED2  0x7f (b01111111) /* default is 0x7f */ (unuse)


 - example
   * PWM freq to 50kHz     : i2cset -f -y 5 0x08 0x98 0x7c (b0111 1100)
   * PWM to 20% for R_LED1 : i2cset -f -y 5 0x08 0x9a 0x33 (b0011 0011)
   * PWM to 40% for G_LED1 : i2cset -f -y 5 0x08 0x9c 0x66 (b0110 0110)
   * PWM to 80% for B_LED1 : i2cset -f -y 5 0x08 0x9e 0xcc (b1100 1100)
<br/>
<br/>
<br/>
<hr>

## Note

```
i2cdump -y 5 0x08
i2cset -f -y 5 0x08 0x4c 0xff w
i2cget -f -y 5 0x08 0x4c


130|newjeans_sample:/ # i2cdump -y 5 0x08
          0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f    0123456789abcdef
     00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff    ????????????????
     10: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff    ????????????????
     20: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff    ????????????????
     30: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 00    ???????????????.
     40: 00 00 40 00 85 20 24 82 00 00 00 00 7e 10 80 c0    ..@.? $?....~???
     50: 00 a0 44 98 01 38 00 00 00 00 00 00 00 02 00 00    .?D??8.......?..
     60: 00 60 20 00 0c 36 83 80 40 20 10 08 ff ff ff ff    .` .?6??@ ??????
     70: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff    ????????????????
     80: 00 10 00 82 00 50 04 00 a1 00 a0 10 82 20 08 a0    .?.?.P?.?.??? ??
     90: 00 28 08 00 00 01 00 00 ff 80 7f 80 7f 80 7f 80    .(?..?..????????
     a0: 7f 80 7f 80 7f 01 00 7f 7f 00 00 00 00 00 00 00    ??????.??.......
     b0: 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00    ...........?....
     c0: 00 00 ff ff ff ff ff ff ff ff ff ff ff ff ff ff    ..??????????????
     d0: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff    ????????????????
     e0: ff ff ff ff ff ff ff ff ff ff ff ff c3 00 91 92    ?????????????.??
     f0: 00 a8 a5 9d 00 28 00 5a 00 03 03 02 56 31 02 a5    .???.(.Z.???V1??
```


```
흰색   : adb shell "i2cset -y 5 0x08 0x4c 0x0f b"
빨간색 : adb shell "i2cset -y 5 0x08 0x4c 0x03 b"
파란색 : adb shell "i2cset -y 5 0x08 0x4c 0x09 b"

상위로부터 흰색, 빨간색, 파란색, 비활성화에 대한 IOCTL 인터페이스를 제공. 
```
