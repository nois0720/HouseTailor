//
//  FPUtils.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 25..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit

func SCNVector3toGridCGPoint(vec: SCNVector3) -> CGPoint {
    let screen = UIScreen.main.bounds
    let screenWidth = screen.width / 2
    let screenHeight = screen.height / 2
    
    let x = CGFloat(vec.x * 50.0) + screenWidth
    let y = CGFloat(vec.z * 50.0) + screenHeight

    return CGPoint(x: x, y: y)
}

func eulerToQuaternion(pitch: Double, roll: Double, yaw: Double) -> SCNQuaternion {
    
    // Abbreviations for the various angular functions
    let cy: CGFloat = cos(CGFloat(yaw) * 0.5);
    let sy: CGFloat = sin(CGFloat(yaw) * 0.5);
    let cr: CGFloat = cos(CGFloat(roll) * 0.5);
    let sr: CGFloat = sin(CGFloat(roll) * 0.5);
    let cp: CGFloat = cos(CGFloat(pitch) * 0.5);
    let sp: CGFloat = sin(CGFloat(pitch) * 0.5);
    
    var quaternion: SCNQuaternion = SCNQuaternion()
    quaternion.w = Float(cy * cr * cp + sy * sr * sp)
    quaternion.x = Float(cy * sr * cp - sy * cr * sp)
    quaternion.y = Float(cy * cr * sp + sy * sr * cp)
    quaternion.z = Float(sy * cr * cp - cy * sr * sp)
    
    return quaternion
}

func quaternionToEulerAngle() {
    
}

//def quaternion_to_euler_angle(w, x, y, z):
//ysqr = y * y
//
//t0 = +2.0 * (w * x + y * z)
//t1 = +1.0 - 2.0 * (x * x + ysqr)
//X = math.degrees(math.atan2(t0, t1))
//
//t2 = +2.0 * (w * y - z * x)
//t2 = +1.0 if t2 > +1.0 else t2
//t2 = -1.0 if t2 < -1.0 else t2
//Y = math.degrees(math.asin(t2))
//
//t3 = +2.0 * (w * z + x * y)
//t4 = +1.0 - 2.0 * (ysqr + z * z)
//Z = math.degrees(math.atan2(t3, t4))
//
//return X, Y, Z

//func SCNVector3toMeterUnitCGPoint(vec: SCNVector3) -> CGPoint {
//    let screen = UIScreen.main.bounds
//    let screenWidth = screen.width / 2
//    let screenHeight = screen.height / 2
//    
//    let x = CGFloat(vec.x * 100.0) + screenWidth
//    let y = CGFloat(vec.z * 100.0) + screenHeight
//    
//    return CGPoint(x: x, y: y)
//}

