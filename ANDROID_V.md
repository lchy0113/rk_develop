 Android 15 (VanilaIceCream)
====

>> Android 15 SDK를 사용하여 RK3568 SoC 개발

<br/>
<br/>
<br/>
<br/>
<hr>

# Output Image

컴파일 이후 생성되는 파일 리스트.  
```bash
rockdev/Image-rk3568_u/
    +-> boot-debug.img
boot.img
config.cfg
dtbo.img
MiniLoaderAll.bin
misc.img
parameter.txt
pcba_small_misc.img
pcba_whole_misc.img


```



<br/>
<br/>
<br/>
<br/>
<hr>

# GKI 

 GKI를 선택하는 경우, AB Function을 default로 사용.  


<br/>
<br/>
<br/>
<br/>
<hr>

# rkr3 vs rkr4 

 - rkr4 : android-15.0.0_r17
 - rkr3 : android-15.0.0_r9

<br/>
<br/>
<br/>
<br/>
<hr>

# repo management

```bash
Normal download steps
Create new project folder.
$ mkdir nova; cd nova
Initialize repo project with specifiying the url of this repository.
$ repo init -u ssh://git@git.kdiwin.com:7999/hnnov/nova-manifests -m target/rk3576_v.xml
Synchronize repositories (-j option can be used in specifying count of jobs)
$ repo sync
```

 legacy structure
```bash
target/rk3576_v.xml
    |
    +-> aosp/android-15.0.9_r9.xml
    +-> socs/a15_rkr3.xml
    +-> nova/nova_device.xml
    +-> nova/nova_device_rockchip.xml
    +-> nova/nova_vendor.xml
```

 new structure
```bash
target/rk3576_v_rkr4.xml
target/rk3568_v_rkr4.xml
    |
    +-> target/android_v_rkr4.xml
        |
        +-> aosp/android-15.0.0_r17.xml    // revision이 r9 에서 업데이트
        +-> aosp/a15_rkr4.xml              // revision이 rkr3 에서 업데이트
        +-> nova/nova_device.xml
        +-> nova/nova_device_rockchip.xml
        +-> nova/nova_vendor.xml
```


<br/>
<br/>
<br/>
<br/>
<hr/>

# Note

<br/>
<br/>
<br/>
<hr>

## build rk3576_evb

```bash
lunch rk3576_u-ap4a-userdebug
```
