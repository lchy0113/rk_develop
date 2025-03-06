# LOGIN SHELL

Android Platform환경에 전통적인 linux login shell(serial port) 기능을 추가

```
+----------------+
|  System Boot   |
+----------------+
       ↓
+----------------+
|   init (PID 1) |
+----------------+
       ↓
+----------------+
|  getty 실행    |
+----------------+
       ↓
+----------------+
|  사용자 로그인  |
+----------------+
       ↓
+----------------+
|   login 실행   |
+----------------+
       ↓
+----------------+
|  쉘 (bash/sh)  |
+----------------+

```

## require

[v] update busybox: 
> getty, login app을 사용해야함. 

[ ] /system/etc/init/hw/init.rc
> serivce sonsole 실행 시, getty 프로그램 실행하도록 수정

```
service console /system/bin/getty -L ttyFIQ0 115200 
    class core
    console
    disabled
    user root
    group root
    seclabel u:r:shell:s0
    setenv HOSTNAME console
```

[ ] /system/etc/passwd
echo "root:x:0:0:root:/data:/system/bin/sh" > /system/etc/passwd

[ ] /system/etc/shadow
echo "root:nekRqsl.wW3HU:20152:0:99999:7:::" > /system/etc/shadow

[ ] /system/bin/getty

[ ] /system/bin/login

[ ] [option] adb shell chmod 4777 /dev/ttyFIQ0 ; adb shell chmod 4777 /system/bin/login  ;
ueventd.rc 파일에 적용 > /odm/etc/ueventd.rc 파일로 복사됨:



