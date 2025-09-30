OverlayFS 
=====

<br/>
<br/>
<br/>
<br/>
<hr>

# OverlayFS 기본 구조

OverlayFS 는 3가지 디렉토리를 조합해서 최종 뷰(merged)를 생성함.  
- lowerdir : 읽기전용 원본(ex /system/etc)
- upperdir : 수정/삭제/추가 결과가 기록되는 디렉토리
- workdir : OverlayFS 내부 동작을 위한 작업 디렉토리

 즉, 최종적으로는

```bash
 lowerdir (원본)
   + upperdir (수정/삭제 기록)
   = merged (최종 뷰)
```
 이런 구조가 됨.  

<br/>
<br/>
<br/>
<br/>
<hr>

# /data 를 upper/work 로 쓰려고 했을때,

/data 하위 디렉토리를 upperdir, workdir 로 사용 시도 시, 아래와 같은 dmesg 로그가 출력  

```bash
overlayfs : filesystem on '/data/overlay/system_etc_upper' not supported
```

 -> 즉, 커널이 /data 의 파일 시스템(f2fs) 에 대해서 "upper 로 사용하는 것" 을 지원하지 않는다.  
 안드로이드의 보안 정책으로 특정 파티션(/data 같은 사용자 데이터 영역)을 upperdir 로 금지하는 경우가 있음.  
 이유는  

  - 신뢰성 문제(jounaling 충돌, writeback 문제)   
  - 보안 정책(system과 data의 파일 도메인을 섞지 않도록 )  
  - AOSP 빌드 시, mount 옵션 제한  

<br/>
<br/>
<br/>
<br/>
<hr>

# tmpfs를 쓰면 어떤점이 달라지는가 ? 

 tmpfs 는 메모리에 올라가는 임시 파일시스템.  

 특징 : 
 - 커널에서 OverlayFS 상부(upper/work) 로 사용하는 것을 항상 지원  
 - 깨끗한 쓰기 가능한 공간(빈 메모리 공간이므로 충돌 없음) 
 - 재부팅 시, 내용이 사라짐.  -> "런타임에만 overlay 적용"  하기에 적함.  
 
 즉, upper/work를 tmpfs로 만들면, 
 - 커널이 지원불가라고 거부하지 않으며,  
 - overlayfs가 정상적으로 작동할 수있는 "write 가능 filesystem"을 제공  

<br/>
<br/>
<br/>
<br/>
<hr>

# 실제 동작 예시

1. /mnt/ovl_tmp에 tmpfs 마운트.
```bash
 mount -t tmpfs tmpfs /mnt/ovl_tmp
```

 -> 이제 /mnt/ovl_tmp는 깨끗한 RAM기반 파일 시스템  

2. 그 안에 upper, work 디렉토리 생성

```bash
 mkdir /mnt/ovl_tmp/upper /mnt/ovl_tmp/work
```

3. overlay 마운트

```bash
mount -t overlay oerlay \
  -o lowerdir=/system/etc, upperdir=/mnt/ovl_tmp/upper, workdir=/mnt/ovl_tmp/work \
  /mnt/merged_etc
```

4. /mnt/merged_etc에서 /system/etc/와 동일한 내용이 보임. 

 이 상태에서 passwd, shadow 를 rm하면, 실제 삭제는 아니고, upperdir안에 .wh.passwd, .wh.shadow 라는 화이트아웃 파일이 생김.  
 -> merged 뷰에서는 해당 파일이 **존재 하지 않는 것처럼** 동작.  

5. 마지막으로 /mnt/merged_etc를 /system/etc 위에 바인드 마운트 ->  시스템 전체에서 passwd, shadow가 사라진 것처럼 보이게 됨.  

<br/>
<br/>
<br/>
<br/>
<hr>

# 정리

```bash
          ┌─────────────────────────┐
          │        lowerdir         │
          │  /system/etc (읽기전용) │
          │  ├─ passwd              │
          │  ├─ shadow              │
          │  └─ ...                 │
          └─────────────────────────┘
                       │
                       ▼
          ┌─────────────────────────┐
          │        upperdir         │
          │  /mnt/ovl_tmp/upper     │
          │  ├─ .wh.passwd   ← 화이트아웃
          │  ├─ .wh.shadow   ← 화이트아웃
          │  └─ (변경사항 저장)     │
          └─────────────────────────┘
                       │
                       ▼
          ┌─────────────────────────┐
          │        workdir          │
          │  /mnt/ovl_tmp/work      │
          │  (overlay 내부 작업용)  │
          └─────────────────────────┘
                       │
                       ▼
          ┌─────────────────────────┐
          │        merged           │
          │  /mnt/merged_etc        │
          │  └─ passwd, shadow 없음 │
          │  └─ 나머지는 lower 복사 │
          └─────────────────────────┘

```

