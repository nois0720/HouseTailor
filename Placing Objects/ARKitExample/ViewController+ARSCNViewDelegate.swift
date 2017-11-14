/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 ARSCNViewDelegate interactions for `ViewController`.
 */

import ARKit

extension ViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate
    
    func startTimer () {
        let _ =  Timer.scheduledTimer(
            timeInterval: TimeInterval(0.8),
            target      : self,
            selector    : #selector(verticalDetect),
            userInfo    : nil,
            repeats     : true)
    }
    
    @objc func verticalDetect() {
        guard let screenCenter = screenCenter else { return }
        
        verticalPlaneDetector.detectVerticalPlane(point: screenCenter)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        updateFocusSquare()
        
        if mode == Mode.loadFloorPlan {
            textManager.showMessage("\(selectCount)번째 좌표를 찍어주세요", autoHide: true)
            return
        }
        
        if isMeasuring {
            guard let hitPosition = sceneView.hitTestToVerticalPlane(at: self.screenCenter!) else {
                return
            }
            
            self.currentLine?.update(to: hitPosition)
            
//
//            let planeHitTestResults = self.sceneView.hitTest(self.screenCenter!, types: .existingPlane)
//            guard let result = planeHitTestResults.first else { return }
//
//            let hitPosition2 = SCNVector3.positionFromTransform(result.worldTransform)
//
//            self.currentLine?.update(to: hitPosition2)
        }
        
        if isMeasuringFP {
            let planeHitTestResults = self.sceneView.hitTest(self.screenCenter!, types: .existingPlane)
            guard let result = planeHitTestResults.first,
                let FPCurrentLine = FPCurrentLine else { return }
            
            let hitPosition = SCNVector3.positionFromTransform(result.worldTransform)
            FPCurrentLine.update(to: hitPosition)
            
            for i in FPLines.indices.dropLast() {
                if FPCurrentLine.isIntersect(other: FPLines[i]) {
                    FPCurrentLine.setCategory(number: 1)
                    textManager.showMessage("다른 선과 겹칩니다.", autoHide: true)
                    break
                } else {
                    FPCurrentLine.setCategory(number: 2)
                }
            }
            
            if FPLines.count > 1, let firstNodeStartPos = FPLines.first?.startNodePos() {
                if distance(startPos: hitPosition, endPos: firstNodeStartPos) < 0.04 {
                    FPCurrentLine.update(to: firstNodeStartPos)
                    isComplete = true
                }
                else {
                    isComplete = false
                }
            }
        }
        
        // If light estimation is enabled, update the intensity of the model's lights and the environment map
        if let lightEstimate = session.currentFrame?.lightEstimate {
            sceneView.scene.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40)
        } else {
            sceneView.scene.enableEnvironmentMapWithIntensity(40)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        updateQueue.async {
            self.addPlane(node: node, anchor: planeAnchor)
            self.virtualObjectManager.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        updateQueue.async {
            self.updatePlane(anchor: planeAnchor)
            self.virtualObjectManager.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        updateQueue.async {
            self.removePlane(anchor: planeAnchor)
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        textManager.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable:
            fallthrough
        case .limited:
            textManager.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            textManager.cancelScheduledMessage(forType: .trackingStateEscalation)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let arError = error as? ARError else { return }
        
        let nsError = error as NSError
        var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
        if let recoveryOptions = nsError.localizedRecoveryOptions {
            for option in recoveryOptions {
                sessionErrorMsg.append("\(option).")
            }
        }
        
        let isRecoverable = (arError.code == .worldTrackingFailed)
        if isRecoverable {
            sessionErrorMsg += "\nYou can try resetting the session or quit the application."
        } else {
            sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
        }
        
        displayErrorMessage(title: "We're sorry!", message: sessionErrorMsg, allowRestart: isRecoverable)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        textManager.blurBackground()
        textManager.showAlert(title: "Session Interrupted", message: "The session will be reset after the interruption has ended.")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        textManager.unblurBackground()
        session.run(worldTrackingConfiguration, options: [.resetTracking, .removeExistingAnchors])
        restartExperience(self)
        textManager.showMessage("세션 재 시작")
    }
}
