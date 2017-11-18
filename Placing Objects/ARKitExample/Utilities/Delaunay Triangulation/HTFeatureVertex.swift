//
//  HTFeatureVertex.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 8..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit

/**
 House Tailor Feature Vertex.
 
 해당 클래스의 인스턴스는 특정 feature point의 가상 평면의 2D좌표계와
 Scene상의 3D좌표계 값을 둘다 가지고 있음.
 
 - Properties:
    - distToPlane: asdf
    - vertex:
    - originPosition:
 - Parameter:
 */
class HTFeatureVertex {
    var distToPlane: Float
    var vertex: Vertex
    var originPosition: SCNVector3
    
    init(distToPlane: Float, vertex: Vertex, originPosition: SCNVector3 = SCNVector3(0, 0, 0)) {
        self.distToPlane = distToPlane
        self.vertex = vertex
        self.originPosition = originPosition
    }
}

