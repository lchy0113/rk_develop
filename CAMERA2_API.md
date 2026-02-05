# CAMERA2 API
====


## vendor Tag

>> App(Camera2) → (CaptureRequest에 Vendor Tag 설정) → Camera HAL(각 request에서 tag 읽음) → 커널(v4l2 subdev s_routing 또는 입력 mux 제어)


 - Vendor tag
 Camera2의 Metadata(=키-값 딕셔너리) 체계 안에서, AOSP 표준에 없는 "제조사(벤더) 전용 키" 를 추가하는 방법  
  * 표준 키 예 : *ANDROID_CONTROL_AE_MODE*, *ANDROID_SENSOR_EXPOSURE_TIME* 등  
    Camera2의 표준(CameraMetadata) 키 리스트 :   
       https://developer.android.com/reference/android/hardware/camera2/CameraMetadata
  * 벤더 키 예 : *com.vendor.mycam.feature.enable* 같은 식
 즉, vendor tag는 **벤더가 확장한 metadata key** 이고,   
 앱/프레임워크/HAL이 요청(request)/결과(result)/정적정보(static)형태로 주고 받을 수 있어  

 - setParameters(Camera1) 과 차이
 설정을 넣는다라는 점은 비슷하지만 구조가 완전히 다름.  
  * Camera1 *setParameters()* : 하나의 파라미터 묶음을 던지고 내부가 알아서 반영  
  * Camera2 + Vendor tag : **프레임 단위 request에 키-값을 넣는 방식** (스트리밍 중에도 매 프레임 바뀔수 있음) 
 그리고 Camera2는 "이 키가 유효한가/지원하는가/현재 템플릿과 충돌하는가" 같은 제약이 더 강함 . 

 - vendor tag 로 가능한 제어  
 1. 토글형 기능 : WDR, LDC, EIS, 노이즈 억제 강화, 특정 ISP 파이프라인 선택  
 2. 튜닝 파라미터 : 샤프니스/NR레벨, anti-flicker 커스텀  
 3. 라우팅/입력 선택 : 멀티 입력(MIPI/디코더/VIN) 중 어떤 걸 쓸지.  
 4. 진단/디버그 : 특정 통계/히스토그램/레지스터 dump 트리거



## attachment

 - ![dumpsys media.camera](./attachment/dumpsys_media.camera.txt)
