# WRITE SN


[Overview](#overview)

<br/>
<br/>
<br/>
<br/>
<hr>


## Overview

 Rockchip 플랫폼에서는 *RKDevInfoWriteTool* 을 제공한다.   
 해당 Tool은 사용자가 정의한 데이터를 VendorStorage partition에 저장하는 용도로 사용.  
 저장되는 데이터는 *SN*, *Wi-Fi*, *IMEI*, 그외 Data이며, 장치가 Factory Reset 후에도 손실되지 않는다.

 2개의 device mode 를 통해 제공함.   
 
 - maskrom mode
	 maskrom mode 는 *FLASH CLK pin *을 shrot 후, MiniLoaderAll.bin 을 사용하여 진입.  

```bash
DevNo=1 Vid=0x2207,Pid=0x350a,LocationID=13     Mode=Maskrom    SerialNo=

```
  
 - loader mode
	 *adb reboot loader* 명령어을 통해 진입.
	 (기존에 이미지가 장치에 저장되어 있어야 함.)

   * uboot(next-dev branch version)은 *RPMB* 에 write만 제공함.  

```bash
DevNo=1 Vid=0x2207,Pid=0x350a,LocationID=13     Mode=Loader     SerialNo=richgold
```


<br/>
<br/>
<br/>
<br/>
<hr>


