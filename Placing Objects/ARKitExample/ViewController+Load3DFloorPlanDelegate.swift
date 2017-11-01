//
//  ViewController+Load3DFloorPlanDelegate.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 1..
//  Copyright © 2017년 Apple. All rights reserved.
//

import UIKit
import SceneKit

extension ViewController: Load3DFloorPlanDelegate {
    
    // MARK: - Load3DFloorPlanDelegate delegate callbacks
    func load3DFloorPlan(didSelectDefinition definition: FloorPlanDefinition) {
        mode = .loadFloorPlan
        
//        for (index, point) in definition.floorPlaneInfo.enumerated() {
//
//            var nextPoint: SCNVector3
//
//            if index == definition.floorPlaneInfo.endIndex - 1 { nextPoint = definition.floorPlaneInfo[0] }
//            else { nextPoint = definition.floorPlaneInfo[index + 1] }
//
//            let line = Line(sceneView: sceneView, startNodePos: point)
//            line.update(to: nextPoint)
//
//            FPLines.append(line)
//        }
//
//        definition.virtualObjectCoding.forEach {
//            let virtualObject = VirtualObject(definition: $0.virtualObjectDefinition)
//            virtualObject.position = $0.position
//            virtualObject.eulerAngles = $0.eulerAngle
//            virtualObject.scale = $0.scale
//
//            // Load the content asynchronously.
//            DispatchQueue.global(qos: .userInitiated).async {
//                virtualObject.load()
//
//                // Immediately place the object in 3D space.
//                self.updateQueue.async {
//                    guard let frame = VirtualObjectFrame(virtualObject: virtualObject) else {
//                        return
//                    }
//
//                    virtualObject.setFrame(frame: frame)
//                }
//            }
//
//            if virtualObject.parent == nil {
//                updateQueue.async {
//                    self.sceneView.scene.rootNode.addChildNode(virtualObject)
//                }
//            }
//        }
    }
    
}
