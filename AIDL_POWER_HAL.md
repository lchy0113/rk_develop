AIDL Power HAL
====

# Structure Overview

> Framework 가 성능을 요청하면, Power HAL 이 Linux sysfs 를 변경하여 CPU/GPU/DDR 등을 제어하는 구조

```
Framework
    │
    │ Binder(AIDL)
    ▼
android.hardware.power.IPower/default
    │
    ▼
Power HAL (vendor)
    │
    ▼
Power.cpp
    │
    ├── CPU Governor
    ├── CPU Frequency
    ├── GPU Frequency
    ├── DDR Frequency
    ├── VOP Frequency
    └── UFS Frequency
            │
            ▼
        sysfs
```

## Code 

```
/hardware/rockchip/power_aidl/
  Android.bp* [RO]
  cscope.in.out* [RO]
  cscope.out* [RO]
  cscope.po.out* [RO]
  gistfile1.sh* [RO]
  main.cpp* [RO]
  power-aidl-rockchip.rc* [RO]
  power-aidl-rockchip.xml* [RO]
  Power.cpp* [RO]
  Power.h* [RO]
  PowerHintSession.cpp* [RO]
  PowerHintSession.h* [RO]
  tags* [RO]
```

 - Android.bp 

 빌드 정의  

```
cc_binary {
    name: "android.hardware.power-service.rockchip", // -> /vendor/bin/hw/android.hardware.power-service.rockchip
    init_rc: ["power-aidl-rockchip.rc"],             // -> /vendor/etc/init/power-aidl-rockchip.rc 
    vintf_fragments: ["power-aidl-rockchip.xml"],    // -> /vendor/etc/vintf/manifest/power-aidl-rockchip.xml
```

 - power-aidl-rockchip.xml

VINTF Manifest
 이 디바이스는 *android.hardware.power.IPower/default*  서비스를 제공 합니다. 
 Framework는 이 Manifest를 보고, 
 ServiceManager에게 요청합니다. 

```
<manifest version="1.0" type="device">
    <hal format="aidl">
        <name>android.hardware.power</name>
        <version>4</version>
        <fqname>IPower/default</fqname>
    </hal>
</manifest>
```

 - power-aidl-rockchip.rc
 
 init Service

 *interface aidl android.hardware.power.IPower/default*  라인이 존재해야지,
 *ctl.interface_start* 가 동작함. 
```
service vendor.power-aidl-rockchip /vendor/bin/hw/android.hardware.power-service.rockchip
    class hal
    user root
    group system
    capabilities DAC_OVERRIDE
    interface aidl android.hardware.power.IPower/default
```

 즉, 아래 Flow가 동작됨. 

```
SurfaceFlinger
      │
      ▼
ServiceManager
      │
ctl.interface_start
      │
init
      │
vendor.power-aidl-rockchip
```


 - main.cpp

 서비스 시작 코드.
 핵심은 아래와 같음.

```
    std::shared_ptr<Power> vib = ndk::SharedRefBase::make<Power>();
 // Power 객체 생성.
 // 그리고, Binder에 등록 (android.hardware.power.IPower/default)
    binder_status_t status = AServiceManager_addService(vib->asBinder().get(), instance.c_str());
```
