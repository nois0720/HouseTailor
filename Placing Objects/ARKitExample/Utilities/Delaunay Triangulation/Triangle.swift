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
    
    let vertex1: SCNVector3
    let vertex2: SCNVector3
    let vertex3: SCNVector3
    
    
    init(vertex1: SCNVector3, vertex2: SCNVector3, vertex3: SCNVector3) {
        self.vertex1 = vertex1
        self.vertex2 = vertex2
        self.vertex3 = vertex3
    }
    
    
    func dotWithYAxis() -> Float {
        return normal.normalized().dot(SCNVector3(0, 1, 0))
    }
    
    func isContain(edge: Edge) -> Bool {
        
        if self.vertex1 == edge.vertex1.originPosition {
            if self.vertex2 == edge.vertex2.originPosition {
                return true
            } else if self.vertex3 == edge.vertex2.originPosition {
                return true
            }
        } else if self.vertex2 == edge.vertex1.originPosition {
            if self.vertex1 == edge.vertex2.originPosition {
                return true
            } else if self.vertex3 == edge.vertex2.originPosition {
                return true
            }
        } else if self.vertex3 == edge.vertex1.originPosition {
            if self.vertex1 == edge.vertex2.originPosition {
                return true
            } else if self.vertex2 == edge.vertex2.originPosition {
                return true
            }
        }
        
        return false
    }
    
    var normal: SCNVector3 {
        let vec1 = self.vertex2 - self.vertex1
        let vec2 = self.vertex3 - self.vertex1
        
        return vec1.cross(vec2).normalized()
    }
    
    var center: SCNVector3 {
        return (vertex1 + vertex2 + vertex3) / 3
    }
}

