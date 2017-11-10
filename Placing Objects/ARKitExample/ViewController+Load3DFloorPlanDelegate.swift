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
        floorPlanDefinition = definition
        vec = definition.floorPlaneInfo[1] - definition.floorPlaneInfo[0]
        
        mode = .loadFloorPlan
    }
    
}
