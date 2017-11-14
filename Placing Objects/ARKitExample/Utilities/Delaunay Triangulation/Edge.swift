//
//  Edge.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 8..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit
import Foundation

struct Edge {
    let vertex1: HTFeatureVertex
    let vertex2: HTFeatureVertex
}

extension Edge: Equatable {
    static func ==(lhs: Edge, rhs: Edge) -> Bool {
        return (lhs.vertex1.vertex == rhs.vertex1.vertex && lhs.vertex2.vertex == rhs.vertex2.vertex) ||
            (lhs.vertex1.vertex == rhs.vertex2.vertex && lhs.vertex2.vertex == rhs.vertex1.vertex)
    }
}
