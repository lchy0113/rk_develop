KERNEL PATCH
=====


<br/>
<br/>
<br/>
<br/>
<hr>

# ASB 
  ASB(Android Security Bulletin) 은 Google이 발표하는 Android 보안 공지.   
  ASB는 안드로이드 운영체제와 관련된 보안 취약점과 그에 대한 패치 정보를 제공.  
  각 ASB는 특정 날짜에 발표되며, 해당 날짜에 대한 보안 패치와 수정 사항을 포함.  

- base : git@gitlab.com:kdiwin/rk_kernel.git 
- remote : https://android.googlesource.com/kernel/common 
  * tag : ASB(Android Security Board) 에 대응하는 릴리즈. 
  * [ASB-2025-01-05_4.19-stable](https://android.googlesource.com/kernel/common/+/refs/tags/ASB-2025-01-05_4.19-stable) 태그는  
   Android 공통 커널 저장소의 4.19 안정 버전에 대한 2025년 01월 05일자 Android Security Board에 대응하는 릴리즈를 나타냄.   
   4.19.325 커널 버전 기반
  
> base, remote 비교  : base 는 remote 의 b33f66a commit 에서 분기 됨.

```css
 A : {android_kernel/ASB-2025-01-05_4.19-stable}    
 B: {master}
 

    A        B
    |        |
    +        |    (4f94b88) <ASB-2024-12-05_4.19-stable> Merge 4.19.324 into android-4.19-stable
    |        |
    |        |
    +        |    (b6d1b4b) <ASB-2022-05-05_4.19-stable> (...)
    |        +    (1e39451) <android-12.1-mid-rkr7> drm/rockchip: dbc_dev: release version v4.03
    |        |
    +        |    (22fdca5) <ASB-2022-04-05_4.19-stable> (...)
    |        |
    +--------+    (3c7840d) Merge tag 'ASB-2022-03-05_4.19-stable' of https://android.googlesource.com/kernel/common
    +             (b33f661) <ASB-2022-03-05_4.19-stable> Merge 4.19.232 into android-4.19-stable


```


- guide

 * rebase 
 1. checkout *ASB-2025-01-05_4.19-stable* branch  
 2. rebase *master* branch  
 3. rebaes 가 완료되면 *master* branch로 돌아간 후, rebase 된 *ASB-2025-01-05_4.19-stable* branch 병합  

 * merge
 1. checkout *master* branch  
 2. merge *AEB_2025-01-05_4.19-stable* branch to *master* branch  

<br/>
<br/>
<br/>
<br/>
<hr>

# CVE
  CVE(Common Vulnerabilities and Exposures) 는 보안 취약점을 식별하고 추적하기 위한 표준화된 명명체계.  
  각 CVE 항목은 고유한 식별 번호를 가지며, 해당 취약점에 대한 상세한 정보와 수정 방법을 제공.  
  CVE는 MITRE Corporation이 주관하고, 미국 정부의 지원을 받아 운영되는 비영리 조직.   
  - [CVE 공식 웹 사이트](https://cve.mitre.org)  
  - [NVD(National Vulnerability Database)](https://nvd.nist.gov)  



