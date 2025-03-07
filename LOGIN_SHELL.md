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

[v] /system/etc/passwd
 - 다음 명령어를 사용하여 생성
```bash
echo "root:x:0:0:root:/:/system/bin/sh" > /system/etc/passwd
echo "shell:x:2000:2000:shell:/sdcard:/system/bin/sh" > /system/etc/passwd
```
 - Android build script 에서 복사하도록 함
 - system의 모든 사용자 계정 정보를 저장 하는 파일. 
 - 각 사용자 계정은 한줄로 표현, 콜론(:)으로 필드 구분. 
```bash
username:x:uid:gid:gecos:home_directory:shell
 - username : 사용자 이름
 - x : 암호 필드(shadow 파일에 저장)
 - uid : 사용자 ID
 - gid : 그룹 ID
 - gecos ; 사용자 정보(사용자 이름 및 전화번호)
 - home_directory : 사용자의 홈 디렉토리 경로
 - shell : 사용자의 기본 쉘정보 
```

[v] /system/etc/shadow
 - 다음 명령어를 사용하여 생성
```bash
echo "root:nekRqsl.wW3HU:20152:0:99999:7:::" > /system/etc/shadow
echo "shell
```
 - Android build script 에서 복사하도록 함
   * build시, 에러발생. previously defined at build/make/core/base_rules.mk
 - 사용자 계정의 암호 정보를 저장함. passws 파일보다 더 엄격한 권한을 가지고 있음. 
```bash
username:password:last_change:min:max:warn:inactive:expire
 - username : 사용자 이름
 - password : 암호 해시
 - last_change : 마지막 암호 변경 날짜
 - min : 암호 변경 최소 일 수
 - max : 암호 변경 최대 일 수
 - warn : 암호 만료 경고 일수
 - inactive : 비활성화 기간
 - expire : 계정 만료 날짜
```

[v] /system/bin/getty
 - Android build script 에서 복사하도록 함

[v] /system/bin/login
 - Android build script 에서 복사하도록 함

[ ] [option] adb shell chmod 4777 /dev/ttyFIQ0 ; adb shell chmod 4777 /system/bin/login  ;
ueventd.rc 파일에 적용 > /odm/etc/ueventd.rc 파일로 복사됨:



