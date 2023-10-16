ANDROID_PERFORMANCE
=====

> 특정 어플리케이션의 성능을 향상 시키는 방법에 대해 설명(on rockchip platform)

# method

## 활성화 및 비활성화

 - 설정 파일은 device/rockchip/rk356x/package_performance.xml 경로에 위치.
 - 어플리케이션 패키지 네임을 추가한다.

```xml
	<app package="the package name" mode="whether to enable the speed up, 1 means enable, 0 means disable"/>
```
 
 예)

```xml
	<app package="com.antutu.ABenchMark" mode="1"/>
	<app package="com.antutu.benchmark.full" mode="1"/>
```

 - 추가한 패키지 파일은 compiling 시 이미지에 추가된다.

## compiling 결과

 - 컴파일 후, 설정 파일은 odm partition ($OUT/odm/etc/) 파일을 출력한다. 


