//
//  Ray.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 7..
//  Copyright © 2017년 Apple. All rights reserved.
//

import SceneKit

struct Ray {
    let origin: SCNVector3
    let direction: SCNVector3
    
    func intersectionPosition(with verticalPlane: VerticalPlane) -> SCNVector3 {
        
        let d = -(verticalPlane.normal.x * verticalPlane.position.x +
            verticalPlane.normal.y * verticalPlane.position.y +
            verticalPlane.normal.z * verticalPlane.position.z)
        
        let numerator = -(verticalPlane.normal.x * self.origin.x +
            verticalPlane.normal.y * self.origin.y +
            verticalPlane.normal.z * self.origin.z + d)
        let denominator = (verticalPlane.normal.x * self.direction.x +
            verticalPlane.normal.y * self.direction.y +
            verticalPlane.normal.z * self.direction.z)
        
        let t = numerator / denominator
        
        return self.origin + self.direction * t
    }
}
