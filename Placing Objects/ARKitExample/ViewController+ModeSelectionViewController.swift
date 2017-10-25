//
//  ViewController+ModeSelectionViewController.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 18..
//  Copyright © 2017년 Apple. All rights reserved.
//

import UIKit
import SceneKit

extension ViewController: ModeSelectionViewControllerDelegate {
    
    // MARK: - VirtualObjectManager delegate callbacks
    func modeSelectionViewController(_: ModeSelectionViewController, didSelectModeAt index: Int) {
        switch index {
        case 0:
            print("furniture mode")
            mode = .furniture
            lines.forEach { $0.delete() }
            lines.removeAll()
        case 1:
            print("measure mode")
            mode = .measure
        case 2:
            print("floorPlan mode")
            mode = .floorPlan
        default:
            print("error")
        }
    }
    
}
