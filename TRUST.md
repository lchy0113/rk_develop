TRUST 
=====

 > ARM아키텍처의 TRUST 이미지는 ARM 아키텍처(Cortex-A class processor) 기반 디바이스의 보안을 강화하기 위해 사용되는 기술(ARM architecture security extension).
# 1. ARM TrustZone


 TRUST 이미지는 다음과 같은 기능을 제공.

 - 부팅 프로세서의 보안 강화 : TRUST 이미지는 부팅 프로세스를 보호하여 악성 코드의 침입을 방지.
 - 하드웨어 암호화 키의 보호 : TRUST 이미지는 하드웨어 암호화 키를 보호하여 데이터의 안전을 보장.
 - 저장 장치의 보안 강화 : TRUST 이미지는 저장 장치를 보호하여 데이터의 유출을 방지.
 
 ARM 아키텍처 TRUST 이미지는 다음과 같은 두가지 구성 요소로 구성.

 - TrustZone : TrustZone은 ARM아키텍처에서 제공하는 하드웨어 기반 보안 기능. TrustZone은 디바이스의 일부메모리와 CPU를 보안영역으로 분리하여 악성 코드의 침입을 방지.
 - TrustFirmware-A(TF-A) : TF-A는 TrustZone에서 실행되는 펌웨어. TF-A는 부팅 프로세스를 제어하고 하드웨어 암호화 키를 보호하는 등의 역할을 담당.
 
 ARM 아키텍처 TRUST 이미지는 일반적으로 디바이스의 제조업체에서 제공. 
 디바이스를 부팅할 때 TRUST 이미지가 부팅 프로세스를 제어하여 디바이스의 보안을 강화.

 ARM아키텍처 TRUST이미지는 ARM아키텍처 기반 디바이스의 보안을 강화하기 위한 중요한 요소.
 디바이스의 보안을 강화하려는 경우 ARM 아키텍처 TRUST이미지를 사용하는 것이 좋다.


## 1.1 System architecture

 시스템 아키텍처 관점에서 다음은 ARM TrustZone 기술이 활성화된 64비트 플랫폼 시스템 아키텍처 다이어그램이다.
 시스템은 두 개의 영역, 즉 왼쪽의 non-secure 영역과 오른쪽의 secure 영역으로 나누어진다.
 secure 영역은 두 세계의 모든 리소스에 액세스할 수 있지만, non-secure 영역은 non-secure 세계의 리소스에만 액세스할 수 있다.
 non-secure 영역에서 secure 영역의 자원에 접근하면 system hardware bus error가 발생하고 자원에 접근할 수 없다.

 이 두 영역간의 상호 작용에는 ARM Trusted Firmware 를 bridge 로 사용해야 한다.
 CPU가 non-secure 영역에 있는 경우, secure 영역으로 들어가려면 먼저 ARM Trusted Firmware(ARM의 SMC command)가 필요하다.
 그 후, ARM Trusted Firmware 내의 Secure Monitor code 는 CPU 를 non-secure ID에서 secure ID로 전환한다.
 전환 후, secure ID를 사용하여 secure 영역으로 들어간다.

 Rockchip Trust는 secure 영역에서 필요한 기능 즉, Secure Monitor의 기능을 구현하는 ARM Trusted Firmware + OP-TEE OS의 기능이 합쳐진 것으로 이해.
 (두 영역 전환의 핵심 코드)

![](./images/TRUST_01.png)

![](./images/TRUST_02.png)

-----

## 1.2 CPU privilege level

 CPU 관점에서 아래 그림은 ARM TruztZone이 활성화 된 standrd CPU privilege mode level 아키텍처 다이어그램이다.
 64 bit CPU 인 경우, privilege level은 EL0, EL1, EL2, EL3으로 나누어지며, 이는 CPU가 속한 영역에 따라 secure EL0, secure EL1 또는 non-secure EL0, non-secure EL1 으로 구분된다.
 32 bit CPU 인 경우, privilege level은 Mon, Hyp, SVC, ABT, IRQ, FIQ, UND, SYS, USER mode로 나뉘며, 그 중 SVC, ABT, IRQ, FIQ, AND, SYS, USER도 64비트와 같으며 secure 모드와 non-secure 모드의 차이가 있다.

![](./images/TRUST_03.png)

-----

<br/>
<br/>
<br/>
<br/>

# 2. Trust on Rockchip platform

## 2.1 Implementation Mechanism

 ARM Trusted Firmware + OP-TEE OS의 구성은 Rockchip 플랫폼의 64비트 SoC 플랫폼에서 사용된다.
 OP-TEE OS는 32비트 SoC 플랫폼에서 사용됩니다.

## 2.2 Boot-up process

 ARM Trusted Firmware architecture 는 전체 system을 EL0, EL1, EL2, EL3의 4 가지 secure level으로 구분한다.
 secure boot의 프로세스 단계는  BL1, Bl2, BL31, BL32, BL33으로 정의되며, BL1, BL2, BL31는 ARM Trusted Firmware source code를 제공한다.
 Rockchip platform은 BL31 기능만 사용한다.
 BL1과 BL2에는 고유한 구현 방법이 있다. 
 Rockchip platform은 일반적으로 ARM Trusted Firmware가 BL31을 참조하고, BL32는 OP-TEE OS를 사용하도록 하는 "default"로 사용 가능하다.

 - Android system boot-up sequence :

```bash
	Maskrom -> Loader -> Trust -> U-Boot -> kernel -> Android
```

![](./images/TRUST_04.png)


## 2.3 firmware obtain

 binary files 로만 제공(source code 미제공).
 binary files of Trust파일은 ~~u-boot~~ rkbin project 을 통해 제공.


-----

<br/>
<br/>
<br/>
<br/>



