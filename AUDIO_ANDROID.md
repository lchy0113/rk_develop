AUDIO ANDROID
=====
> Android의 Audio에 대한 문서.


 ![](./images/AUDIO_ANDROID_01.png)

 - APPLICATION FRAMEWORK : android.media API를 사용하여 오디오 하드웨어와 상호작용하는 앱 코드가 존재.  
 - JNI : android.media와 연결된 JNI코드는 오디오 하드웨어에 액세스 하기 위해 하위 수준의 기본 코드를 호출.  
	 JNI는 frameworks/base/core/jni/ 및 framewworks/base/media/jni 에 존재.  
 - NATIVE FRAMEWORK : 기본 프레임워크는 android.media 패키지와 동일한 기본 기능을 제공하며,   
     바인더 IPC 프록시를 호출하여 미디어 서버의 오디오 관련 서비스에 액세스한다.  
	 기본 프레임워크 코드는 frameworks/av/media/libmedia에 존재.  
 - BINDER IPC : 바인더 IPC 프록시는 프로세스 경계를 통한 통신을 용이하게 한다.  
	 frameworks/av/media/libmedia에 존재하며 I로 시작한다.  
 - MEDIA SERVER : 미디어 서버는 HAL 구현과 상호작용하는 실제 코드인 오디오 서비스가 포함되어 있다.  
     frameworks/av/services/audioflinger에 존재  
 - HAL : HAL은 오디오 서비스가 호출하고 오디오 하드웨어가 올바르게 작동하기 위해 구현해야 하는 표준 인터페이스를 정의  
  [audio HAL interface](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/audio/) 
 - LINUX KERNEL : 오디오 드라이버는 하드웨어 및 HAL 구현과 상호 작용한다.  
    ALSA, OSS 또는 사용자 지정 드라이버를 사용할 수 있다.




# reference 

 - AOSP : https://source.android.com/docs/core/audio
