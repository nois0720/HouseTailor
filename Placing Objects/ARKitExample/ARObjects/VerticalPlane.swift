//
//  VerticalPlane.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 10..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit

class VerticalPlane: SCNNode {
    
    // MARK: - Properties
    var normal: SCNVector3
    var boundary: (width: Float, height: Float)
    
    // MARK: - Initialization
    
    init(position: SCNVector3, normal: SCNVector3, boundary: (width: Float, height: Float)) {
        self.normal = normal
        self.boundary = boundary
        
        super.init()
        
        self.geometry = SCNPlane(width: CGFloat(self.boundary.width), height: CGFloat(self.boundary.height))
        self.geometry?.firstMaterial?.diffuse.contents =  UIColor(red: CGFloat(arc4random()) / CGFloat(UINT32_MAX), green: CGFloat(arc4random()) / CGFloat(UINT32_MAX), blue: CGFloat(arc4random()) / CGFloat(UINT32_MAX), alpha: 0.5)
        self.geometry?.firstMaterial?.isDoubleSided = true
        
        self.look(at: normal)
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contain(vec: SCNVector3) -> Bool {
        return false
    }
    
    // return value: 0 to 1
    func similarity(other: VerticalPlane) -> Bool {
        // 1에 가까울수록 두 벡터가 이루는 각은 0도에 가까워짐.
        guard self.normal.dot(other.normal) > 0.95 else { return false }
        
        // self: aX + bY + cZ + d = 0
        let d = -(normal.x * position.x + normal.y * position.y + normal.z * position.z)
        
        // 두 평면사이의 거리
        let dist = abs(normal.x * other.position.x + normal.y * other.position.y + normal.z * other.position.z + d) / sqrtf(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z)
        
        guard dist < 0.05 else { return false }
//        guard distance(startPos: self.center, endPos: other.center) < 0.1 else { return false }
        
        return true
    }
    
    func updatePlane(other: VerticalPlane) {
//        return
        let dist = self.position - other.position
        let deltaHeight = abs(dist.y)
        let deltaWidth = sqrtf(dist.length() * dist.length() - deltaHeight * deltaHeight)
        let newBoundary = ((self.boundary.width + other.boundary.width) / 2 + deltaWidth,
                           (self.boundary.height + other.boundary.height) / 2 + deltaHeight)
        
        // check no intersection
        if newBoundary.0 < self.boundary.width || newBoundary.0 < other.boundary.width { return }
        if newBoundary.1 < self.boundary.height || newBoundary.1 < other.boundary.height { return }
        
        var t: Float = 0
        
        if other.boundary.width - self.boundary.width > 0 {
            t = self.boundary.width / (self.boundary.width + other.boundary.width)
        } else {
            t = other.boundary.width / (self.boundary.width + other.boundary.width)
        }
        
//        print(self.boundary)
//        print(other.boundary)
//        print(newBoundary)
        
        let newPosition = self.position + dist * -t
        let newNormal = (self.normal + other.normal).normalized()

//        print(self.position)
//        print(other.position)
//        print(newPosition)

        self.geometry = SCNPlane(width: CGFloat(newBoundary.0), height: CGFloat(newBoundary.1))
        self.position = newPosition
        self.normal = newNormal
        self.geometry?.firstMaterial?.diffuse.contents =  UIColor(red: CGFloat(arc4random()) / CGFloat(UINT32_MAX), green: CGFloat(arc4random()) / CGFloat(UINT32_MAX), blue: CGFloat(arc4random()) / CGFloat(UINT32_MAX), alpha: 0.5)
        self.geometry?.firstMaterial?.isDoubleSided = true
//        let newCenter = (self.center + other.center) / 2
//        let newBoundary = ((self.boundary.width + other.boundary.width) / 2,
//                           (self.boundary.height + other.boundary.height) / 2)
//        let newNormal = (self.normal + other.normal).normalized()
//
//        self.center = newCenter
//        self.boundary = newBoundary
//        self.normal = newNormal
    }
}
