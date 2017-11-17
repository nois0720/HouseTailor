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
        textManager.showMessage("수직 평면이 탐지되었습니다")
        
        print("add verticalPlane")
    }
    
    func verticalPlaneDetector(didUpdate node: SCNNode) {
        textManager.showMessage("수직 평면이 업데이트되었습니다")
        
        print("update verticalPlane")
    }
    
    func verticalPlaneDetector(didRemove node: SCNNode) {
        print("remove verticalPlane")
    }
}
