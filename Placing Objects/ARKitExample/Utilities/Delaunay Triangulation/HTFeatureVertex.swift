//
//  HTFeatureVertex.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 8..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit

class HTFeatureVertex {
    var vertex: Vertex
    var originPosition: SCNVector3
    
    init(vertex: Vertex, originPosition: SCNVector3 = SCNVector3(0, 0, 0)) {
        self.vertex = vertex
        self.originPosition = originPosition
    }
}

//extension Vertex: Hashable {
//    public var hashValue: Int {
//        var seed = UInt(0)
//        hash_combine(seed: &seed, value: UInt(bitPattern: x.hashValue))
//        hash_combine(seed: &seed, value: UInt(bitPattern: y.hashValue))
//        return Int(bitPattern: seed)
//    }
//}

