/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A type which controls the manipulation of virtual objects.
*/

import Foundation
import ARKit

class VirtualObjectManager {
	
	weak var delegate: VirtualObjectManagerDelegate?
	
	var virtualObjects = [VirtualObject]()
    
    var lastUsedObject: VirtualObject? {
        willSet {
            newValue?.setCategoryBitMask(2)
        }
        didSet {
            if lastUsedObject == oldValue { return }
            oldValue?.setCategoryBitMask(1)
        }
    }
    
    /// The queue with updates to the virtual objects are made on.
    var updateQueue: DispatchQueue
    
    init(updateQueue: DispatchQueue) {
        self.updateQueue = updateQueue
    }
	
	// MARK: - Resetting objects
	
    static let availableObjects: [VirtualObjectDefinition] = {
        guard let jsonURL = Bundle.main.url(forResource: "VirtualObjects", withExtension: "json") else {
                fatalError("Missing 'VirtualObjects.json' in bundle.")
        }
        
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            return try JSONDecoder().decode([VirtualObjectDefinition].self, from: jsonData)
        } catch {
            fatalError("Unable to decode VirtualObjects JSON: \(error)")
        }
    }()

	func removeAllVirtualObjects() {
		for object in virtualObjects {
			unloadVirtualObject(object)
		}
		virtualObjects.removeAll()
	}
	
	func removeVirtualObject(at index: Int) {
		let definition = VirtualObjectManager.availableObjects[index]
        guard let object = virtualObjects.first(where: { $0.definition == definition })
            else { return }
        
		unloadVirtualObject(object)
		if let pos = virtualObjects.index(of: object) {
			virtualObjects.remove(at: pos)
		}
	}
    
    func removeVirtualObject(at item: VirtualObject) {
        guard let object = virtualObjects.first(where: { $0 == item })
            else { return }
        
        unloadVirtualObject(object)
        if let pos = virtualObjects.index(of: object) {
            virtualObjects.remove(at: pos)
        }
    }
	
	private func unloadVirtualObject(_ object: VirtualObject) {
        object.unload()
        object.removeFromParentNode()
        if self.lastUsedObject == object {
            self.lastUsedObject = nil
            
            // 삭제 후 lastUsedObject 선택
            if self.virtualObjects.count > 1 {
                self.lastUsedObject = self.virtualObjects[0]
            }
        }
	}
	
	// MARK: - Loading object
	
	func loadVirtualObject(_ object: VirtualObject, to position: float3, cameraTransform: matrix_float4x4) {
		self.virtualObjects.append(object)
		self.delegate?.virtualObjectManager(self, willLoad: object)
		
        object.load()
        
        self.updateQueue.async {
            self.setNewVirtualObjectPosition(object, to: position, cameraTransform: cameraTransform)
            self.delegate?.virtualObjectManager(self, didLoad: object)
            
            guard let frame = VirtualObjectFrame(virtualObject: object) else {
                return
            }
            
            object.setFrame(frame: frame)
        }
	}
	
	// MARK: - React to gestures
	
	private var currentGesture: Gesture?
	
	func reactToTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, in sceneView: ARSCNView) {
		if virtualObjects.isEmpty { return }
		
		if currentGesture == nil { // single
			currentGesture = Gesture.startGestureFromTouches(touches, sceneView, lastUsedObject, self)
		} else { // single to multi
			currentGesture = currentGesture!.updateGestureFromTouches(touches, .touchBegan)
		}

        if let newObject = currentGesture?.lastUsedObject {
            lastUsedObject = newObject
        } else {
            lastUsedObject = nil
        }
	}
	
	func reactToTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if virtualObjects.isEmpty { return }
		
		currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchMoved)
        if let newObject = currentGesture?.lastUsedObject {
            lastUsedObject = newObject
        }
		
		if let gesture = currentGesture, let object = gesture.lastUsedObject {
			delegate?.virtualObjectManager(self, transformDidChangeFor: object)
		}
	}
	
	func reactToTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if virtualObjects.isEmpty { return }
		currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchEnded)
		if let newObject = currentGesture?.lastUsedObject {
			lastUsedObject = newObject
		}
		
		if let gesture = currentGesture, let object = gesture.lastUsedObject {
			delegate?.virtualObjectManager(self, transformDidChangeFor: object)
		}
	}
	
	func reactToTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		if virtualObjects.isEmpty {
			return
		}
		currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchCancelled)
	}
	
	// MARK: - Update object position
	
	func translate(_ object: VirtualObject, in sceneView: ARSCNView, basedOn screenPos: CGPoint) {
		DispatchQueue.main.async {
            guard let ray = sceneView.rayFromScreenPos(screenPos),
                let pointCloud = sceneView.session.currentFrame?.rawFeaturePoints else {
                return
            }
            
            let hitPosition = self.verticalHitTest(ray: ray, pointCloud: pointCloud)
            
            guard hitPosition == nil else {
                self.delegate?.virtualObjectManager(self, couldNotPlaceVerticalPlane: object)
                return
            }
            
			let result = self.worldPositionFromScreenPosition(screenPos, in: sceneView)
			
			guard let newPosition = result.position else {
				self.delegate?.virtualObjectManager(self, couldNotPlace: object)
				return
			}
			
			guard let cameraTransform = sceneView.session.currentFrame?.camera.transform else {
				return
			}
			
			self.updateQueue.async {
				self.setPosition(for: object,
									  position: newPosition,
				                      filterPosition: !result.hitAPlane,
				                      cameraTransform: cameraTransform)
			}
		}
	}
	
    func setPosition(for object: VirtualObject, position: float3, filterPosition: Bool, cameraTransform: matrix_float4x4) {
        updateVirtualObjectPosition(object, to: position, filterPosition: filterPosition, cameraTransform: cameraTransform)
    }
	
	private func setNewVirtualObjectPosition(_ object: VirtualObject, to pos: float3, cameraTransform: matrix_float4x4) {
		let cameraWorldPos = cameraTransform.translation
		var cameraToPosition = pos - cameraWorldPos
		
        // 배치할 위치와 카메라와의 거리를 10미터로 제한.
        if simd_length(cameraToPosition) > 10 {
            cameraToPosition = simd_normalize(cameraToPosition)
            cameraToPosition *= 10
        }

		object.simdPosition = cameraWorldPos + cameraToPosition
		object.recentVirtualObjectDistances.removeAll()
	}
	
	private func updateVirtualObjectPosition(_ object: VirtualObject, to pos: float3, filterPosition: Bool, cameraTransform: matrix_float4x4) {
		let cameraWorldPos = cameraTransform.translation
		var cameraToPosition = pos - cameraWorldPos
		
        // 배치할 위치와 카메라와의 거리를 10미터로 제한.
        if simd_length(cameraToPosition) > 10 {
            cameraToPosition = simd_normalize(cameraToPosition)
            cameraToPosition *= 10
        }

        object.simdPosition = pos

        
//        // 카메라와 virtual object의 최근 10개의 거리값을 이용하여, 평균값을 구함.
//        // average값 사용하게 되면서 plane detection이 되지 않더라도 이동에 큰 문제는 없어보이도록 구현할 수 있음.
//        let hitTestResultDistance = simd_length(cameraToPosition)
//
//        object.recentVirtualObjectDistances.append(hitTestResultDistance)
//        object.recentVirtualObjectDistances.keepLast(10)
//
//        // hitTest에서 Plane과 hit되지 못한경우, 카메라로부터 떨어져있던 거리의 평균값 사용.
//        if filterPosition, let averageDistance = object.recentVirtualObjectDistances.average {
//            let averagedDistancePos = cameraWorldPos + simd_normalize(cameraToPosition) * averageDistance
//            object.simdPosition = averagedDistancePos
//        } else {
//            object.simdPosition = pos
//        }
	}
	
	func checkIfObjectShouldMoveOntoPlane(anchor: ARPlaneAnchor, planeAnchorNode: SCNNode) {
		for object in virtualObjects {
			// plane 좌표계상에서의 object position을 얻음.
			let objectPos = planeAnchorNode.convertPosition(object.position, from: object.parent)
			
			if objectPos.y == 0 {
				return; // 오브젝트가 이미 평면상에 존재
			}
			
			//  --------
            // | ------ㄱ|
            // |ㄴ------ |
            //  --------
            // 외부 사각형이 tolerance 적용한 사각혐.
            // 10% 여유있게 확인
            
			let tolerance: Float = 0.1
			
			let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
			let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
			let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
			let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance
			
            // 이 사각형 외부에 있으면 return
			if objectPos.x < minX || objectPos.x > maxX || objectPos.z < minZ || objectPos.z > maxZ {
				return
			}
			
			//  만약, y좌표값을 비교하여 5센치 이내이면 오브젝트를 평면 위로 이동.
			let verticalAllowance: Float = 0.05
			let epsilon: Float = 0.001 // 1mm 이내이면 안움직임.
            
            // TODO: 평면도 로드 시 오브젝트 아래로 내려가는 문제 수정
			let distanceToPlane = abs(objectPos.y)
            
            // (1mm < distance < 50mm)?
			if distanceToPlane > epsilon && distanceToPlane < verticalAllowance {
				delegate?.virtualObjectManager(self, didMoveObjectOntoNearbyPlane: object)
				
				SCNTransaction.begin()
                
                // ex) distanceToPlane == '0.03'이라고 했을 때, 0.03 * 500 = 15초간 애니메이션 함.
                // 3cm / 15s = 30mm / 15s = 2mm/s
                // 즉, 초당 2mm 이동시키는 애니메이션
                SCNTransaction.animationDuration = CFTimeInterval(distanceToPlane * 500)
				SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
				object.position.y = anchor.transform.columns.3.y
				SCNTransaction.commit()
			}
		}
	}
	
	func transform(for object: VirtualObject, cameraTransform: matrix_float4x4) -> (distance: Float, rotation: Int, scale: Float) {
        
		let cameraPos = cameraTransform.translation
		let vectorToCamera = cameraPos - object.simdPosition
		
		let distanceToUser = simd_length(vectorToCamera)
		
		var angleDegrees = Int((object.eulerAngles.y * 180) / .pi) % 360
		if angleDegrees < 0 {
			angleDegrees += 360
		}
		
		return (distanceToUser, angleDegrees, object.scale.x)
	}
	
    func verticalHitTest(ray: Ray, pointCloud: ARPointCloud) -> SCNVector3? {
        var d: Float = 10.0
        if ray.direction.z < 0 { d = d * -1 }
        
        // 카메라 원점으로부터 ray direction 방향벡터의 't'배 만큼 떨어진 평면
        let t = -(ray.origin.x * ray.direction.x + ray.origin.y * ray.direction.y + ray.origin.z * ray.direction.z + d) / (ray.direction.x * ray.direction.x + ray.direction.y * ray.direction.y + ray.direction.z * ray.direction.z)

        // 카메라 원점의 가상 평면으로의 정사영
        let newOrigin = ray.direction * t + ray.origin

        // 평면의 normal vector는 카메라가 보는 반대방향으로 형성
        let planeNormalVector = ray.direction.normalized() * -1

        let newDirY = planeNormalVector.cross(SCNVector3(1, 0, 0)).normalized()
        let newDirX = newDirY.cross(planeNormalVector).normalized()
        let newCoordinateSystem = CoordinateSystem2D(xAxis: newDirX, yAxis: newDirY)
        let new2DOrigin = newCoordinateSystem.newPos(pos: newOrigin)
        
        let points = pointCloud.__points
        var htFeatureVertexs: [HTFeatureVertex] = []

        for i in 0...pointCloud.__count {
            let feature = points.advanced(by: Int(i))
            let featurePos = SCNVector3(feature.pointee)
            
            let t2 = -(featurePos.x * ray.direction.x + featurePos.y * ray.direction.y + featurePos.z * ray.direction.z + d) / (ray.direction.x * ray.direction.x + ray.direction.y * ray.direction.y + ray.direction.z * ray.direction.z)
            
            let newFeaturePos = (ray.direction * t2 + featurePos)
            let new2DPos = newCoordinateSystem.newPos(pos: newFeaturePos)
            
            let vertex = Vertex(x: Double(new2DPos.x), y: Double(new2DPos.y))
            let htFeatureVertex = HTFeatureVertex(vertex: vertex, originPosition: featurePos)
            htFeatureVertexs.append(htFeatureVertex)
        }
        
        htFeatureVertexs.sort {
            return $0.vertex.distance(other: new2DOrigin) < $1.vertex.distance(other: new2DOrigin)
        }
        
        guard htFeatureVertexs.count >= 3 else {
            print("점의 갯수가 3개 이하입니다.")
            return nil
        }
        
        if htFeatureVertexs.count >= 30 + 3 {
            htFeatureVertexs.removeLast(htFeatureVertexs.count - 30)
        }
        
        let triangles = Delaunay.triangulate(htFeatureVertexs)
        var dots: Float = 0
        
        triangles.forEach {
            dots = dots + $0.dotWithYAxis()
        }
        
        dots = dots / Float(triangles.count)
        
        guard abs(dots) < 0.1 else { return nil }
        
        let hitTestResult = ray.origin + (ray.direction * ray.direction.dot(htFeatureVertexs.first!.originPosition))
        return hitTestResult
    }
    
	func worldPositionFromScreenPosition(_ position: CGPoint, in sceneView: ARSCNView) -> (position: float3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
            
		var planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
		if let result = planeHitTestResults.first {
			
			let planeHitTestPosition = result.worldTransform.translation
			let planeAnchor = result.anchor
			
			return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
		}

        planeHitTestResults = sceneView.hitTest(position, types: .estimatedHorizontalPlane)

        if let result = planeHitTestResults.first {

            let planeHitTestPosition = result.worldTransform.translation
            let planeAnchor = result.anchor

            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, false)
        }
        
        planeHitTestResults = sceneView.hitTest(position, types: .existingPlane)
        
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = result.worldTransform.translation
            let planeAnchor = result.anchor
            
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        
        return (nil, nil, false)
	}
}

// MARK: - Delegate

protocol VirtualObjectManagerDelegate: class {
	func virtualObjectManager(_ manager: VirtualObjectManager, willLoad object: VirtualObject)
	func virtualObjectManager(_ manager: VirtualObjectManager, didLoad object: VirtualObject)
	func virtualObjectManager(_ manager: VirtualObjectManager, transformDidChangeFor object: VirtualObject)
	func virtualObjectManager(_ manager: VirtualObjectManager, didMoveObjectOntoNearbyPlane object: VirtualObject)
	func virtualObjectManager(_ manager: VirtualObjectManager, couldNotPlace object: VirtualObject)
    func virtualObjectManager(_ manager: VirtualObjectManager, couldNotPlaceVerticalPlane object: VirtualObject)
}

// Optional protocol methods
extension VirtualObjectManagerDelegate {
    func virtualObjectManager(_ manager: VirtualObjectManager, transformDidChangeFor object: VirtualObject) {}
    func virtualObjectManager(_ manager: VirtualObjectManager, didMoveObjectOntoNearbyPlane object: VirtualObject) {}
}
