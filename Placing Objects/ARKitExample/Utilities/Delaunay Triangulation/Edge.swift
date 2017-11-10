//
//  Edge.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 8..
//  Copyright © 2017년 Apple. All rights reserved.
//

import Foundation

struct Edge {
    let vertex1: Vertex
    let vertex2: Vertex
}

extension Edge: Equatable {
    static func ==(lhs: Edge, rhs: Edge) -> Bool {
        return (lhs.vertex1 == rhs.vertex1 && lhs.vertex2 == rhs.vertex2) ||
            (lhs.vertex1 == rhs.vertex2 && lhs.vertex2 == rhs.vertex1)
    }
}
