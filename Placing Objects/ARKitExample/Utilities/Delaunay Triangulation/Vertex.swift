//
//  Vertex.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 8..
//  Copyright © 2017년 Apple. All rights reserved.
//

import SceneKit
import CoreGraphics

public struct Vertex {
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    let x: Double
    let y: Double
    
    func distance(other: Vertex) -> Double {
        return sqrt((self.x - other.x) * (self.x - other.x) + (self.y - other.y) * (self.y - other.y))
    }
    
}

extension Vertex: Equatable {
    static public func ==(lhs: Vertex, rhs: Vertex) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

extension SCNVector3: Equatable {
    static public func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}


extension Vertex: Hashable {
    public var hashValue: Int {
        var seed = UInt(0)
        hash_combine(seed: &seed, value: UInt(bitPattern: x.hashValue))
        hash_combine(seed: &seed, value: UInt(bitPattern: y.hashValue))
        return Int(bitPattern: seed)
    }
}
