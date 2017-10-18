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
        if index == 0 {
            print("furniture mode")
        } else {
            print("measure mode")
        }
    }
    
}
