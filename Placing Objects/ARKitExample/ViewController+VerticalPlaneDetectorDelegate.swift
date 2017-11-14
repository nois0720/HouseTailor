//
//  ViewController+VerticalPlaneDetectorDelegate.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 13..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit

extension ViewController: VerticalPlaneDetectorDelegate {
    func verticalPlaneDetector(didAdd node: SCNNode) {
        print("add verticalPlane")
    }
    
    func verticalPlaneDetector(didUpdate node: SCNNode) {
        print("update verticalPlane")
    }
    
    func verticalPlaneDetector(didRemove node: SCNNode) {
        print("remove verticalPlane")
    }
}
