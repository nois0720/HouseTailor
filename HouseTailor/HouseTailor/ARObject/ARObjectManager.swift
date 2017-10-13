//
//  ARObjectManager.swift
//  HouseTailor
//
//  Created by Yoo Seok Kim on 2017. 10. 11..
//  Copyright © 2017년 Nois. All rights reserved.
//
import Foundation
import ARKit

class ARObjectManager {
    
    weak var delegate: ARObjectManagerDelegate?
    
    var ARObjects = [ARObject]()
    
    var lastUsedObject: ARObject?
    
    /// The queue with updates to the AR objects are made on.
    var updateQueue: DispatchQueue
    
    init(updateQueue: DispatchQueue) {
        self.updateQueue = updateQueue
    }
    
    // MARK: - Resetting objects
    
    static let availableObjects: [ARObjectDefinition] = {
        guard let jsonURL = Bundle.main.url(forResource: "ARObjects", withExtension: "json") else {
            fatalError("Missing 'ARObjects.json' in bundle.")
        }
        
        do {
            let jsonData = try Data(contentsOf: jsonURL)
            return try JSONDecoder().decode([ARObjectDefinition].self, from: jsonData)
        } catch {
            fatalError("Unable to decode ARObjects JSON: \(error)")
        }
    }()
    
    func removeAllARObjects() {
        for object in ARObjects {
            unloadARObject(object)
        }
        ARObjects.removeAll()
    }
    
    func removeARObject(at index: Int) {
        let definition = ARObjectManager.availableObjects[index]
        guard let object = ARObjects.first(where: { $0.definition == definition })
            else { return }
        
        unloadARObject(object)
        if let pos = ARObjects.index(of: object) {
            ARObjects.remove(at: pos)
        }
    }
    
    private func unloadARObject(_ object: ARObject) {
        updateQueue.async {
            object.unload()
            object.removeFromParentNode()
            if self.lastUsedObject == object {
                self.lastUsedObject = nil
                if self.ARObjects.count > 1 {
                    self.lastUsedObject = self.ARObjects[0]
                }
            }
        }
    }
    
    // MARK: - Loading object
    
    func loadARObject(_ object: ARObject, to position: float3, cameraTransform: matrix_float4x4) {
        self.ARObjects.append(object)
        self.delegate?.ARObjectManager(self, willLoad: object)
        
        // Load the content asynchronously.
        DispatchQueue.global(qos: .userInitiated).async {
            object.load()
            
            // Immediately place the object in 3D space.
            self.updateQueue.async {
                self.setNewARObjectPosition(object, to: position, cameraTransform: cameraTransform)
                self.lastUsedObject = object
                
                self.delegate?.ARObjectManager(self, didLoad: object)
            }
        }
    }
    
    // MARK: - React to gestures
    
    private var currentGesture: Gesture?
    
    func reactToTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, in sceneView: ARSCNView) {
        if ARObjects.isEmpty {
            return
        }
        
        if currentGesture == nil {
            currentGesture = Gesture.startGestureFromTouches(touches, sceneView, lastUsedObject, self)
            if let newObject = currentGesture?.lastUsedObject {
                lastUsedObject = newObject
            }
        } else {
            currentGesture = currentGesture!.updateGestureFromTouches(touches, .touchBegan)
            if let newObject = currentGesture?.lastUsedObject {
                lastUsedObject = newObject
            }
        }
    }
    
    func reactToTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ARObjects.isEmpty {
            return
        }
        
        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchMoved)
        if let newObject = currentGesture?.lastUsedObject {
            lastUsedObject = newObject
        }
        
        if let gesture = currentGesture, let object = gesture.lastUsedObject {
            delegate?.ARObjectManager(self, transformDidChangeFor: object)
        }
    }
    
    func reactToTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ARObjects.isEmpty {
            return
        }
        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchEnded)
        if let newObject = currentGesture?.lastUsedObject {
            lastUsedObject = newObject
        }
        
        if let gesture = currentGesture, let object = gesture.lastUsedObject {
            delegate?.ARObjectManager(self, transformDidChangeFor: object)
        }
    }
    
    func reactToTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ARObjects.isEmpty {
            return
        }
        currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchCancelled)
    }
    
    // MARK: - Update object position
    
    func translate(_ object: ARObject, in sceneView: ARSCNView, basedOn screenPos: CGPoint, instantly: Bool, infinitePlane: Bool) {
        DispatchQueue.main.async {
            let result = self.worldPositionFromScreenPosition(screenPos, in: sceneView, objectPos: object.simdPosition, infinitePlane: infinitePlane)
            
            guard let newPosition = result.position else {
                self.delegate?.ARObjectManager(self, couldNotPlace: object)
                return
            }
            
            guard let cameraTransform = sceneView.session.currentFrame?.camera.transform else {
                return
            }
            
            self.updateQueue.async {
                self.setPosition(for: object,
                                 position: newPosition,
                                 instantly: instantly,
                                 filterPosition: !result.hitAPlane,
                                 cameraTransform: cameraTransform)
            }
        }
    }
    
    func setPosition(for object: ARObject, position: float3, instantly: Bool, filterPosition: Bool, cameraTransform: matrix_float4x4) {
        if instantly {
            setNewARObjectPosition(object, to: position, cameraTransform: cameraTransform)
        } else {
            updateARObjectPosition(object, to: position, filterPosition: filterPosition, cameraTransform: cameraTransform)
        }
    }
    
    private func setNewARObjectPosition(_ object: ARObject, to pos: float3, cameraTransform: matrix_float4x4) {
        let cameraWorldPos = cameraTransform.translation
        var cameraToPosition = pos - cameraWorldPos
        
        // Limit the distance of the object from the camera to a maximum of 10 meters.
        if simd_length(cameraToPosition) > 10 {
            cameraToPosition = simd_normalize(cameraToPosition)
            cameraToPosition *= 10
        }
        
        object.simdPosition = cameraWorldPos + cameraToPosition
        object.recentARObjectDistances.removeAll()
    }
    
    private func updateARObjectPosition(_ object: ARObject, to pos: float3, filterPosition: Bool, cameraTransform: matrix_float4x4) {
        let cameraWorldPos = cameraTransform.translation
        var cameraToPosition = pos - cameraWorldPos
        
        // Limit the distance of the object from the camera to a maximum of 10 meters.
        if simd_length(cameraToPosition) > 10 {
            cameraToPosition = simd_normalize(cameraToPosition)
            cameraToPosition *= 10
        }
        
        // Compute the average distance of the object from the camera over the last ten
        // updates. If filterPosition is true, compute a new position for the object
        // with this average. Notice that the distance is applied to the vector from
        // the camera to the content, so it only affects the percieved distance of the
        // object - the averaging does _not_ make the content "lag".
        let hitTestResultDistance = simd_length(cameraToPosition)
        
        object.recentARObjectDistances.append(hitTestResultDistance)
        object.recentARObjectDistances.keepLast(10)
        
        if filterPosition, let averageDistance = object.recentARObjectDistances.average {
            let averagedDistancePos = cameraWorldPos + simd_normalize(cameraToPosition) * averageDistance
            object.simdPosition = averagedDistancePos
        } else {
            object.simdPosition = cameraWorldPos + cameraToPosition
        }
    }
    
    func checkIfObjectShouldMoveOntoPlane(anchor: ARPlaneAnchor, planeAnchorNode: SCNNode) {
        for object in ARObjects {
            // Get the object's position in the plane's coordinate system.
            let objectPos = planeAnchorNode.convertPosition(object.position, from: object.parent)
            
            if objectPos.y == 0 {
                return; // The object is already on the plane - nothing to do here.
            }
            
            // Add 10% tolerance to the corners of the plane.
            let tolerance: Float = 0.1
            
            let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
            let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
            let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
            let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance
            
            if objectPos.x < minX || objectPos.x > maxX || objectPos.z < minZ || objectPos.z > maxZ {
                return
            }
            
            // Move the object onto the plane if it is near it (within 5 centimeters).
            let verticalAllowance: Float = 0.05
            let epsilon: Float = 0.001 // Do not bother updating if the different is less than a mm.
            let distanceToPlane = abs(objectPos.y)
            if distanceToPlane > epsilon && distanceToPlane < verticalAllowance {
                delegate?.ARObjectManager(self, didMoveObjectOntoNearbyPlane: object)
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = CFTimeInterval(distanceToPlane * 500) // Move 2 mm per second.
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                object.position.y = anchor.transform.columns.3.y
                SCNTransaction.commit()
            }
        }
    }
    
    func transform(for object: ARObject, cameraTransform: matrix_float4x4) -> (distance: Float, rotation: Int, scale: Float) {
        let cameraPos = cameraTransform.translation
        let vectorToCamera = cameraPos - object.simdPosition
        
        let distanceToUser = simd_length(vectorToCamera)
        
        var angleDegrees = Int((object.eulerAngles.y * 180) / .pi) % 360
        if angleDegrees < 0 {
            angleDegrees += 360
        }
        
        return (distanceToUser, angleDegrees, object.scale.x)
    }
    
    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         in sceneView: ARSCNView,
                                         objectPos: float3?,
                                         infinitePlane: Bool = false) -> (position: float3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        let dragOnInfinitePlanesEnabled = UserDefaults.standard.bool(for: .dragOnInfinitePlanes)
        
        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = result.worldTransform.translation
            let planeAnchor = result.anchor
            
            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        
        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.
        
        var featureHitTestPosition: float3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).
        
        if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {
            
            if let pointOnPlane = objectPos {
                let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
                if pointOnInfinitePlane != nil {
                    return (pointOnInfinitePlane, nil, true)
                }
            }
        }
        
        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }
        
        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.
        
        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        
        return (nil, nil, false)
    }
}

// MARK: - Delegate

protocol ARObjectManagerDelegate: class {
    func ARObjectManager(_ manager: ARObjectManager, willLoad object: ARObject)
    func ARObjectManager(_ manager: ARObjectManager, didLoad object: ARObject)
    func ARObjectManager(_ manager: ARObjectManager, transformDidChangeFor object: ARObject)
    func ARObjectManager(_ manager: ARObjectManager, didMoveObjectOntoNearbyPlane object: ARObject)
    func ARObjectManager(_ manager: ARObjectManager, couldNotPlace object: ARObject)
}
// Optional protocol methods
extension ARObjectManagerDelegate {
    func ARObjectManager(_ manager: ARObjectManager, transformDidChangeFor object: ARObject) {}
    func ARObjectManager(_ manager: ARObjectManager, didMoveObjectOntoNearbyPlane object: ARObject) {}
}
