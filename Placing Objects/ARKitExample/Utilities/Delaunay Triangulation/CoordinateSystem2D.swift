//
//  CoordinateSystem2D.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 9..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit

class CoordinateSystem2D {
    
    let xAxis: SCNVector3
    let yAxis: SCNVector3
    
    init(xAxis: SCNVector3, yAxis: SCNVector3) {
        self.xAxis = xAxis
        self.yAxis = yAxis
    }
    
    func newPos(pos: SCNVector3) -> Vertex {
        let newX = pos.x / xAxis.x
        let newY = (pos - (xAxis * newX)).y / yAxis.y
        
        return Vertex(x: Double(newX), y: Double(newY))
    }
    
}
