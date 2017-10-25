# ARSCNView
3D SceneKit 컨텐츠로 카메라 뷰를 통해 AR 경험을 표시하는 뷰.

* ARSCNView클래스는 가상의 3d contents를 Camera 뷰와 실제 세계를 혼합하여 AR경험을 생성하는 가장 쉬운 방법을 제공한다.
* ARSCNView는 live video feed를 scene background로 자동으로 렌더링함.
* Scenekit Scene의 world 좌표계는 ARSessionConfiguration에 따라서 설정.
* ARKit이 자동으로 SceneKit 공간을 실제 세계와 일치시키기 때문에 가상 객체를 배치할 때 객체의 Scene 상의 위치만 적절히 설정하면 됨.
* ARSCNViewDelegatej메소드를 구현하면 ARKit에 의해 감지된 모든 앵커에 SceneKit 컨텐트를 추가 할 수 있습니다.

# ARSCNViewDelegate
ARSession에서 SceneKit 컨텐츠의 자동 동기화를 중재하기 위해 구현할 수 있는 메서드들.

이 프로토콜을 구현하여 뷰의 AR세션에 의해 추적된 ARAnchor 객체에 대응하는 SceneKit 컨텐트를 제공하거나 해당 컨텐트의 뷰 자동 업데이트를 관리합니다.
이 프로토콜은 ARSessionObserver 프로토콜을 확장하므로 Session 델리게이트는 이러한 메서드를 구현하여 세션 상태의 변경 내용에 응답 할 수 있습니다.

# ARSession
AR 경험에 필요한 카메라 및 모션 처리를 관리하는 shared object.

* ARKit이 수행하는 프로세스를 코디네이트 함.
* 예를 들면, 디바이스 위치나 모션 감지, 데이터 읽기, 카메라 제어 등
* 이런 결과를 종합하여 실제 존재하는 공간과 AR 컨텐츠를 모델링하는 가상 공간간 통신.
* 즉, ARKit으로 구축된 AR프로젝트에는 ARSession객체가 반드시 필요
* ARSCNView나 ARSKView를 이용하고, 뷰 객체에 이 ARSession인스턴스가 포함. (ARSKView - 2D sprite, ARSCNView - 3D model)
* ARSession을 실행하려면 ARSessionConfiguration이 필요함
* ARSessionConfiguration은 device의 위치와 동작을 추적하는 방식을 결정.

# ARConfiguration
ARConfiguration은 추상 클래스.

ARSession을 동작시키려면, 앱에서 사용하려는 AR 환경을 제공하는 ARConfiguration의 Concrete Subclass의 인스턴스를 생성해야 한다. 그리고나서 configuration 객체의 프로퍼티를 설정하고, 세션의 run(_:options:) method에 configuration을 전달해라.

ARKit에는 다음과 같은 configuration이 포함되어 있다.
1. **ARWorldTrackingConfiguration**
후방 카메라를 사용하여 디바이스의 위치, 방향을 정확하게 추적하고 평면 탐지 및 hit test를 제공하는 고품질의 AR 경험을 제공한다.

2. **AROrientationTrackingConfiguration**
후방 카메라를 사용하고, 디바이스의 방향만 추적하는 기본적인 AR 경험을 제공한다. 

3. **ARFaceTrackingConfiguration**
전면 카메라를 사용하는 AR경험을 제공하고, 사용자 얼굴의 움직임과 표현을 추적한다.

# ARWorldTrackingConfiguration
모든 ARConfiguration들은 디바이스가 실제 존재하는 공간과 컨텐트를 모델링 할 수 있는 가상의 3D좌표계 공간 사이에서의 통신을 설정한다. 앱에서 실제 카메라 이미지와 함께 컨텐츠를 표시하면, 가상 컨텐츠가 마치 실제 세계의 한 부분인 것처럼 느끼게 된다.
이러한 대응관계를 생성하고 유지하려면, 디바이스의 모션을 추적해야한다. ARWorldTrackingConfiguration 클래스는  6DOF(six degrees of freedom)를 통해 디바이스의 움직임을 추적한다. (구체적으로, 3개의 rotation 축(roll, pitch, yaw)과 3개의 translation 축들(x, y, z))
이러한 종류의 트래킹은 AR 경험에 몰입감을 생성한다. 가상 오브젝트는 실제 세계속에 동일한 장소에 머물러있는것처럼 보일 수 있다. (심지어 유저가 디바이스를 기울여서 물체의 위 혹은 아래를 보았을 때, 혹은 디바이스를 움직여서 오브젝트의 옆면이나 후면을 보았을 때에도)
만약, planeDetection 셋팅이 활성화되어있으면, ARKit은 실세계의 flat surfaces를 찾기 위해 씬을 분석한다. 각 plane이 감지되면, ARKit은 자동으로 세션에 ARPlaneAnchor 객체를 추가한다.

# ARAnchor
AR Scene에 물체를 배치하는데 사용할 수 있는 실제 위치 및 방향

카메라를 기준으로 실제 혹은 가상 객체의 위치와 방향을 추적하려면, 앵커 객체를 만들고 add(anchor:)메서드를 사용하여 AR 세션에 추가할 수 있음.
ARKit은 WorldTrackingSession에서 planeDetection옵션을 활성화하면 이러한 앵커를 자동으로 추가함.

# ARPlaneAnchor
worldTrackingARSession에서 감지된 실제 평면 위치와 방향에 대한 정보


# ARFrame
ARSession에 의해 캡쳐된 비디오 이미지 그리고 위치 tracking 정보

ARSession의 실행은 디바이스의 카메라로부터 지속적으로 비디오 프레임을 캡처한다. 각 프레임마다, ARKit은 디바이스의 실세계 좌표값을 측정하기 위해 모션 센서 하드웨어로부터 얻은 데이터와 함께 이미지를 분석한다. ARKit은, 이러한 tracking 정보와 imaging 파라미터들을 ARFrame object의 형태로 전달한다.

# ARFrame - rawFeaturePoints: ARPointCloud
카메라 이미지에서 주목할만한 피쳐를 나타낸다. 이러한 feature point의 위치는 3D 월드 좌표 공간에서 ARKit이 디바이스의 위치, 방향, 움직임 들을 정확하게 추적하기 위해 수행하는 이미지 분석의 일부이다.

# Tracking
* Black wall이나 너무 어두운 경우, Tracking Quality가 줄어듦.
* ARCamera 클래스는 tracking state reason information을 제공 -> low quality tracking situation들을 해결
