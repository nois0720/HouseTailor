/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Manages single finger gesture interactions with the AR scene.
*/

import ARKit
import SceneKit

class SingleFingerGesture: Gesture {
    
    // MARK: - Properties
    
    var initialTouchLocation = CGPoint()
    var latestTouchLocation = CGPoint()
    
    var firstTouchedObject: VirtualObject?

    let translationThreshold: CGFloat = 30
    var translationThresholdPassed = false
    var hasMovedObject = false
    
    var dragOffset = CGPoint()
    
    // MARK: - Initialization
    
    override init(_ touches: Set<UITouch>, _ sceneView: ARSCNView, _ lastUsedObject: VirtualObject?, _ objectManager: VirtualObjectManager) {
        super.init(touches, sceneView, lastUsedObject, objectManager)
        
        let touch = currentTouches.first!
        initialTouchLocation = touch.location(in: sceneView)
        latestTouchLocation = initialTouchLocation
        
        firstTouchedObject = virtualObject(at: initialTouchLocation)
        if firstTouchedObject == nil { self.lastUsedObject = nil }
    }
    
    // MARK: - Gesture Handling
    
    override func updateGesture() {
        super.updateGesture()
        
        guard let virtualObject = firstTouchedObject else {
            lastUsedObject = nil
            return
        }
        
        lastUsedObject = virtualObject
        latestTouchLocation = currentTouches.first!.location(in: sceneView)
        
        if !translationThresholdPassed {
            let initialLocationToCurrentLocation = latestTouchLocation - initialTouchLocation
            let distanceFromStartLocation = initialLocationToCurrentLocation.length()
            if distanceFromStartLocation >= translationThreshold {
                translationThresholdPassed = true
                
                let currentObjectLocation = CGPoint(sceneView.projectPoint(virtualObject.position))
                dragOffset = latestTouchLocation - currentObjectLocation
            }
        }
        
        // A single finger drag will occur if the drag started on the object and the threshold has been passed.
        if translationThresholdPassed {
            
            let offsetPos = latestTouchLocation - dragOffset
            objectManager.translate(virtualObject, in: sceneView, basedOn: offsetPos)
            hasMovedObject = true
        }
    }
    
    func finishGesture() {
    }
    
}
