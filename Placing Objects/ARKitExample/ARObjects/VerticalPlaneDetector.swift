//
//  VerticalPlaneDetector.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 10..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit

class VerticalPlaneDetector {
    var delegate: VerticalPlaneDetectorDelegate?
    
    var sceneView: ARSCNView
    var dist2ProjectionPlane: Float = 10
    var verticalPlanes: [VerticalPlane] = []
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
    }
    
    func detectVerticalPlane(point: CGPoint) {
        
        if let verticalPlane = getVerticalPlane(point: point) {
            
            // check is exist already
            var isUpdate = false
            
            // TODO: 유사도 정의
            // 생성하려는 위치에 이미 '유사도가 높은' 평면이 있다면, 해당 평면 업데이트.
            verticalPlanes.forEach {
                // center
                if $0.similarity(other: verticalPlane) {
                    $0.updatePlane(other: verticalPlane)
                    delegate?.verticalPlaneDetector(didUpdate: $0)
                    isUpdate = true
                }
            }
            
            if isUpdate { return }
            
            // 새로운 vertical plane 생성
            sceneView.scene.rootNode.addChildNode(verticalPlane)
            verticalPlanes.append(verticalPlane)
            delegate?.verticalPlaneDetector(didAdd: verticalPlane)
        }
    }
    
    private func getVerticalPlane(point: CGPoint, maxCount: Int = 30) -> VerticalPlane? {

        guard let ray = sceneView.rayFromScreenPos(point),
            let features = sceneView.session.currentFrame?.rawFeaturePoints else {
                return nil
        }
        
//        // 카메라 원점으로부터 ray direction방향에 있는 ProjectionPlane까지 t 미터 떨어져있다.
//        let t = distanceToProjectionPlane(ray: ray, from: ray.origin)
//
//        // 카메라 원점의 가상 평면으로의 정사영
//        let newOrigin = ray.direction * t + ray.origin
        
        // 평면의 normal vector는 카메라가 보는 반대방향으로 형성
        let planeNormalVector = ray.direction.normalized() * -1
        
        // 새로운 X', Y'축 정의
        var newYAxis = planeNormalVector.cross(SCNVector3(1, 0, 0)).normalized()
        if newYAxis.y < 0 { newYAxis = newYAxis * -1 }
        
        let newXAxis = newYAxis.cross(planeNormalVector).normalized()
        
        // X', Y'축으로 새로운 좌표계 정의
        let newCoordinateSystem = CoordinateSystem2D(xAxis: newXAxis, yAxis: newYAxis)
        
        // for loop
        let points = features.__points
        var htFeatureVertexs: [HTFeatureVertex] = []
        
        for i in 0...features.__count {
            let feature = points.advanced(by: Int(i))
            let featurePos = SCNVector3(feature.pointee)
            
            // 10cm 이하로 가까운 점들은 패스.
            if distance(startPos: featurePos, endPos: ray.origin) < 0.1 { continue }
            
            // featurePos로부터 ProjectionPlane까지 t2미터 떨어져있다.
            let t2 = distanceToProjectionPlane(ray: ray, from: featurePos)
            
            // featurePos의 가상 평면으로의 정사영
            let newFeaturePos = (ray.direction * t2 + featurePos)
            
            // featurePos의 X', Y'축상 좌표
            let newFeature2DPos = newCoordinateSystem.newPos(pos: newFeaturePos)
            
            let vertex = Vertex(x: newFeature2DPos.x, y: newFeature2DPos.y)
            let htFeatureVertex = HTFeatureVertex(distToPlane: t2,
                                                  vertex: vertex,
                                                  originPosition: featurePos)
            htFeatureVertexs.append(htFeatureVertex)
        }
        
        var avgDist: Float = 0
        htFeatureVertexs.forEach { avgDist = avgDist + $0.distToPlane }
        avgDist = avgDist / Float(htFeatureVertexs.count)
        
        // 평균에서 +-10cm 이하로 차이나는 점들만 사용.
        htFeatureVertexs = htFeatureVertexs.filter {
            let delta = abs($0.distToPlane - avgDist)
            return delta < 0.10
        }

        // 점의 개수가 너무 적은 경우, triangle을 만들지 않음.
        guard htFeatureVertexs.count > 10 else { return nil }
        
        let boundary = boundaryRect(htFeatureVertexs: htFeatureVertexs, coordinateSystem: newCoordinateSystem)
        let triangles = Delaunay.triangulate(htFeatureVertexs)

//        let new2DOrigin = newCoordinateSystem.newPos(pos: newOrigin)
//
//        // new2DOrigin에서 가까운 순서로 정렬
//        htFeatureVertexs.sort {
//            return $0.vertex.distance(other: new2DOrigin) < $1.vertex.distance(other: new2DOrigin)
//        }
//
//        // 앞에서부터 maxcount만큼 남기기 (maxcount의 기본값: 30)
//        if htFeatureVertexs.count >= maxCount + 3 {
//            htFeatureVertexs.removeLast(htFeatureVertexs.count - maxCount)
//        }
        
        return verticalPlaneFromTriangles(triangles: triangles, boundary: boundary)
    }
    
    private func verticalPlaneFromTriangles(triangles: [Triangle], boundary: (width: Float, height: Float)) -> VerticalPlane? {
        var avgNormal = SCNVector3Zero
        var center = SCNVector3Zero
        
        triangles.forEach {
            avgNormal = avgNormal + $0.normal
            center = center + $0.center
        }
        
        avgNormal /= Float(triangles.count)
        center /= Float(triangles.count)
        avgNormal.normalize()
        
        let dot = abs(avgNormal.dot(SCNVector3(0, 1, 0)))
        guard dot < 0.2 else { return nil }
        
        // set completely vertical plane
        avgNormal.y = 0
        avgNormal.normalize()
        
        let verticalPlane = VerticalPlane(center: center,
                                          normal: avgNormal,
                                          boundary: boundary)
        
        return verticalPlane
    }
    
    private func distanceToProjectionPlane(ray: Ray, from vec: SCNVector3) -> Float {
        
        var d: Float = dist2ProjectionPlane // distance
        if ray.direction.z < 0 { d = d * -1 }
        
        // 점과 평면의 방정식 사이에서 도출
        return -(vec.x * ray.direction.x + vec.y * ray.direction.y + vec.z * ray.direction.z + d) /
            (ray.direction.x * ray.direction.x + ray.direction.y * ray.direction.y + ray.direction.z * ray.direction.z)
    }
    
    private func boundaryRect(htFeatureVertexs: [HTFeatureVertex], coordinateSystem: CoordinateSystem2D) -> (Float, Float) {
        
        var minX = Double(Int.max)
        var maxX = Double(Int.min)
        var minY = Double(Int.max)
        var maxY = Double(Int.min)
        
        htFeatureVertexs.forEach {
            if $0.vertex.x < minX { minX = $0.vertex.x }
            if $0.vertex.x > maxX { maxX = $0.vertex.x }
            if $0.vertex.y < minY { minY = $0.vertex.y }
            if $0.vertex.y > maxY { maxY = $0.vertex.y }
        }
        
        let v1 = coordinateSystem.originPos(vertex: Vertex(x: maxX, y: maxY))
        let v2 = coordinateSystem.originPos(vertex: Vertex(x: maxX, y: minY))
        let v3 = coordinateSystem.originPos(vertex: Vertex(x: minX, y: maxY))
        
        let width = (v1 - v3).length()
        let height = (v1 - v2).length()
        
        let boundingRect: (width: Float, height: Float) = (width, height)
        return boundingRect
    }
}

protocol VerticalPlaneDetectorDelegate: class {
    func verticalPlaneDetector(didAdd node: SCNNode)
    func verticalPlaneDetector(didUpdate node: SCNNode)
    func verticalPlaneDetector(didRemove node: SCNNode)
}
