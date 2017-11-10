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
            selector    : #selector(createTriangle),
            userInfo    : nil,
            repeats     : true)
    }
    
    func rayFromScreenPos(_ point: CGPoint) -> Ray? {

        guard let frame = sceneView.session.currentFrame else {
            return nil
        }

        let cameraPos = SCNVector3.positionFromTransform(frame.camera.transform)

        // Note: z: 1.0 will unproject() the screen position to the far clipping plane.
        let positionVec = SCNVector3(x: Float(point.x), y: Float(point.y), z: 1.0)
        let screenPosOnFarClippingPlane = sceneView.unprojectPoint(positionVec)

        var rayDirection = screenPosOnFarClippingPlane - cameraPos
        rayDirection.normalize()

        return Ray(origin: cameraPos, direction: rayDirection)
    }
    
    @objc func createTriangle() {
        guard let screenCenter = screenCenter,
            let ray = rayFromScreenPos(screenCenter),
            let features = self.session.currentFrame?.rawFeaturePoints else {
                return
        }
        
        var d: Float = 10.0 // distance
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
        
        let points = features.__points
        var htFeatureVertexs: [HTFeatureVertex] = []
        
        // for test
        var prevVertexNewPos: SCNVector3 = SCNVector3(0, 0, 0)
        
        for i in 0...features.__count {
            let feature = points.advanced(by: Int(i))
            let featurePos = SCNVector3(feature.pointee)
            
            // 10cm 이하로 가까운 점들은 패스.
            if distance(startPos: featurePos, endPos: ray.origin) < 0.1 { continue }
            
            let t2 = -(featurePos.x * ray.direction.x + featurePos.y * ray.direction.y + featurePos.z * ray.direction.z + d) / (ray.direction.x * ray.direction.x + ray.direction.y * ray.direction.y + ray.direction.z * ray.direction.z)
//            print(10 - t2)
            
            let newFeaturePos = (ray.direction * t2 + featurePos)
            if i == 0 { prevVertexNewPos = newFeaturePos }
            
            // 이전 점과 35cm 이상 떨어져있다면 패스
            if distance(startPos: newFeaturePos, endPos: prevVertexNewPos) > 0.35 { continue }
            
            let newFeature2DPos = newCoordinateSystem.newPos(pos: newFeaturePos)
            
            let vertex = Vertex(x: newFeature2DPos.x, y: newFeature2DPos.y)
            let htFeatureVertex = HTFeatureVertex(vertex: vertex, originPosition: featurePos)
            htFeatureVertexs.append(htFeatureVertex)
            
            prevVertexNewPos = newFeaturePos
        }
        
        // new2DOrigin에서 가까운 순서로 정렬
//        htFeatureVertexs.sort {
//            return $0.vertex.distance(other: new2DOrigin) < $1.vertex.distance(other: new2DOrigin)
//        }
        
        if htFeatureVertexs.count >= 30 + 3 {
            htFeatureVertexs.removeLast(htFeatureVertexs.count - 30)
        }
        
        let triangles = Delaunay.triangulate(htFeatureVertexs)
        
        if triangles.count > 0 {
            dtRootNode.childNodes.forEach {
                $0.removeFromParentNode()
            }
        }
        
        var dot: Float = 0
        
        triangles.forEach {
            dot = dot + $0.dotWithYAxis()
            
            var vertices: [SCNVector3] = []
            vertices.append($0.vertex1)
            vertices.append($0.vertex2)
            vertices.append($0.vertex3)
            
            let hue = CGFloat( CGFloat(arc4random()) / CGFloat(UINT32_MAX) )  // 0.0 to 1.0
            let saturation: CGFloat = 0.5  // 0.5 to 1.0, away from white
            let brightness: CGFloat = 1.0  // 0.5 to 1.0, away from black
            let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 0.5)
            
            dtRootNode.addChildNode(polygonSCNNode(vertices: vertices, color: color))
            
            //                let polygonNode = polygonSCNNode(vertices: vertices, color: color)
            //                let line1 = lineSCNNode(from: $0.vertex1, to: $0.vertex2)
            //                let line2 = lineSCNNode(from: $0.vertex1, to: $0.vertex3)
            //                let line3 = lineSCNNode(from: $0.vertex3, to: $0.vertex1)
            //                polygonNode.addChildNode(line1)
            //                polygonNode.addChildNode(line2)
            //                polygonNode.addChildNode(line3)
            //
            //                dtRootNode.addChildNode(polygonNode)
        }
        
        dot = dot / Float(triangles.count)
        let absDot = abs(dot)
        var avgNormal = SCNVector3(0, 0, 0)
        
        triangles.forEach {
            avgNormal += $0.normal
        }
        avgNormal = avgNormal / Float(triangles.count)
        
        if absDot < 0.2 { // vertical
            avgNormal.y = 0
            avgNormal.normalize()
            textManager.showMessage("\(avgNormal) vertical!!")
        } else { // horizontal
            avgNormal.normalize()
            textManager.showMessage("\(avgNormal) horizontal!!")
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        updateFocusSquare()
        
        if mode == Mode.loadFloorPlan {
            textManager.showMessage("\(selectCount)번째 좌표를 찍어주세요", autoHide: true)
            return
        }
        
        if isMeasuring {
//            guard let screenCenter = screenCenter,
//                let ray = rayFromScreenPos(screenCenter),
//                let pointCloud = session.currentFrame?.rawFeaturePoints else {
//                    return
//            }
//
//            let hitPosition = virtualObjectManager.verticalHitTest(ray: ray, pointCloud: pointCloud)
//
//            if let _hitPosition = hitPosition {
//                self.currentLine?.update(to: _hitPosition)
//                return
//            }
            
            let planeHitTestResults = self.sceneView.hitTest(self.screenCenter!, types: .existingPlane)
            guard let result = planeHitTestResults.first else { return }
            
            let hitPosition2 = SCNVector3.positionFromTransform(result.worldTransform)

            self.currentLine?.update(to: hitPosition2)
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
