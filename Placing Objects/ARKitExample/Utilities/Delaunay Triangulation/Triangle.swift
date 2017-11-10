//
//  Triangle.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 8..
//  Copyright © 2017년 Apple. All rights reserved.
//

//import CoreGraphics
import ARKit

/// A simple struct representing 3 vertices
public struct Triangle {
    
    public init(vertex1: SCNVector3, vertex2: SCNVector3, vertex3: SCNVector3) {
        self.vertex1 = vertex1
        self.vertex2 = vertex2
        self.vertex3 = vertex3
    }
    
    
    func dotWithYAxis() -> Float {
        return normal.normalized().dot(SCNVector3(0, 1, 0))
    }
    
    public let vertex1: SCNVector3
    public let vertex2: SCNVector3
    public let vertex3: SCNVector3
    
    var normal: SCNVector3 {
        let vec1 = self.vertex2 - self.vertex1
        let vec2 = self.vertex3 - self.vertex1
        
        return vec1.normalized().cross(vec2.normalized())
    }
}

