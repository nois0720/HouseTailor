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
}

struct FeatureHitTestResult {
    let hitPosition: SCNVector3
    let distanceFromRayOrigin: Float
    let featurePos: SCNVector3
    let featureDistanceFromHitResult: Float
}
