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
    
    var center: SCNVector3
    var normal: SCNVector3
    var boundary: (width: Float, height: Float)
    
    // MARK: - Initialization
    
    init(center: SCNVector3, normal: SCNVector3, boundary: (width: Float, height: Float)) {
        self.center = center
        self.normal = normal
        self.boundary = boundary
        
        super.init()
        
        self.geometry = SCNPlane(width: CGFloat(self.boundary.width), height: CGFloat(self.boundary.height))
        self.geometry?.firstMaterial?.diffuse.contents =  UIColor(red: CGFloat(arc4random()) / CGFloat(UINT32_MAX), green: CGFloat(arc4random()) / CGFloat(UINT32_MAX), blue: CGFloat(arc4random()) / CGFloat(UINT32_MAX), alpha: 0.5)
        self.look(at: normal)
        self.position = center
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
        let d = -(normal.x * center.x + normal.y * center.y + normal.z * center.z)
        let dist = abs(normal.x * other.center.x + normal.y * other.center.y + normal.z * other.center.z + d) / sqrtf(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z)
        
        guard dist < 0.1 else { return false }
//        guard distance(startPos: self.center, endPos: other.center) < 0.1 else { return false }
        
        return true
    }
    
    func updatePlane(other: VerticalPlane) {
//        let newCenter = (self.center + other.center) / 2
//        let newBoundary = ((self.boundary.width + other.boundary.width) / 2,
//                           (self.boundary.height + other.boundary.height) / 2)
//        let newNormal = (self.normal + other.normal).normalized()
//
//        self.center = newCenter
//        self.boundary = newBoundary
//        self.geometry = SCNPlane(width: CGFloat(self.boundary.width), height: CGFloat(self.boundary.height))
//        self.geometry?.firstMaterial?.diffuse.contents =  UIColor(red: CGFloat(arc4random()) / CGFloat(UINT32_MAX), green: CGFloat(arc4random()) / CGFloat(UINT32_MAX), blue: CGFloat(arc4random()) / CGFloat(UINT32_MAX), alpha: 0.5)
//        self.normal = newNormal
    }
}
