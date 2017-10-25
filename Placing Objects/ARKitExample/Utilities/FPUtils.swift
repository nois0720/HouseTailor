//
//  FPUtils.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 25..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit

func SCNVector3toCGPoint(vec: SCNVector3) -> CGPoint {
    let screen = UIScreen.main.bounds
    let screenWidth = screen.width / 2
    let screenHeight = screen.height / 2
    
    let x = CGFloat(vec.x * 50.0) + screenWidth
    let y = CGFloat(vec.z * 50.0) + screenHeight

    return CGPoint(x: x, y: y)
}
