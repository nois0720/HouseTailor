/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Convenience extensions on ARSCNView for hit testing
*/

import ARKit

extension ARSCNView {
    
    func setup() {
        automaticallyUpdatesLighting = false
        
        preferredFramesPerSecond = 60
        contentScaleFactor = 2.0
        
        if let camera = pointOfView?.camera {
            camera.automaticallyAdjustsZRange = true
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
            camera.maximumExposure = 3
        }
    }
    
    // hitTests
    
    func rayFromScreenPos(_ point: CGPoint) -> Ray? {
        guard let frame = session.currentFrame else { return nil }

        let cameraPos = SCNVector3.positionFromTransform(frame.camera.transform)

        // Note: z: 1.0 will unproject() the screen position to the far clipping plane.
        let positionVec = SCNVector3(x: Float(point.x), y: Float(point.y), z: 1.0)
        let screenPosOnFarClippingPlane = unprojectPoint(positionVec)

        var rayDirection = screenPosOnFarClippingPlane - cameraPos
        rayDirection.normalize()

        return Ray(origin: cameraPos, direction: rayDirection)
    }
    
    func hitTestToVerticalPlane(at point: CGPoint) -> VerticalPlane? {
        func isVerticalPlane(_ node: SCNNode) -> VerticalPlane? {
            if let verticalPlane = node as? VerticalPlane { return verticalPlane }
            if node.parent != nil { return isVerticalPlane(node.parent!) }
            
            return nil
        }
        
        let hitTestResults: [SCNHitTestResult] = hitTest(point, options: [:])
        let verticalPlane = hitTestResults.lazy.flatMap { result in
           isVerticalPlane(result.node)
        }.first
        
        return verticalPlane
    }
    
//
//    @objc func createTriangle() {
//        if let screenCenter = screenCenter,
//            let ray = rayFromScreenPos(screenCenter) {
//            var d: Float = 2.0
//            if ray.direction.z < 0 { d = -2.0 }
//
//            let t = -(ray.origin.x * ray.direction.x + ray.origin.y * ray.direction.y + ray.origin.z * ray.direction.z + d) / (ray.direction.x * ray.direction.x + ray.direction.y * ray.direction.y + ray.direction.z * ray.direction.z)
//
//            let newOrigin = ray.direction * t + ray.origin
//
//            let planeNormalVector = ray.direction.normalized() * -1
//
//            let newDirY = planeNormalVector.cross(SCNVector3(1, 0, 0)).normalized()
//            let newDirX = newDirY.cross(planeNormalVector).normalized()
//
//            guard let features = self.session.currentFrame?.rawFeaturePoints else {
//                return
//            }
//
//            let points = features.__points
//            var htFeatureVertexs: [HTFeatureVertex] = []
//
//            for i in 0...features.__count {
//                let feature = points.advanced(by: Int(i))
//                let featurePos = SCNVector3(feature.pointee)
//
//                let t2 = -(featurePos.x * ray.direction.x + featurePos.y * ray.direction.y + featurePos.z * ray.direction.z + d) / (ray.direction.x * ray.direction.x + ray.direction.y * ray.direction.y + ray.direction.z * ray.direction.z)
//
//                let newFeaturePos = newOrigin - (ray.direction * t2 + featurePos)
//
//                let newX = newFeaturePos.x / newDirX.x
//                let newY = (newFeaturePos - (newDirX * newX)).y / newDirY.y
//
//                let vertex = Vertex(x: Double(newX), y: Double(newY))
//                let htFeatureVertex = HTFeatureVertex(vertex: vertex, originPosition: featurePos)
//                htFeatureVertexs.append(htFeatureVertex)
//            }
//
//            let triangles = Delaunay.triangulate(htFeatureVertexs)
//
//            if triangles.count > 0 {
//                dtRootNode.childNodes.forEach {
//                    $0.removeFromParentNode()
//                }
//            }
//
//            triangles.forEach {
//                var vertices: [SCNVector3] = []
//                vertices.append($0.vertex1)
//                vertices.append($0.vertex2)
//                vertices.append($0.vertex3)
//
//                let hue = CGFloat( CGFloat(arc4random()) / CGFloat(UINT32_MAX) )  // 0.0 to 1.0
//                let saturation: CGFloat = 0.5  // 0.5 to 1.0, away from white
//                let brightness: CGFloat = 1.0  // 0.5 to 1.0, away from black
//                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 0.5)
//
//                dtRootNode.addChildNode(polygonSCNNode(vertices: vertices, color: color))
//            }
//        }
//    }
    
}
