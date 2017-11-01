//
//  Mode.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 25..
//  Copyright © 2017년 Apple. All rights reserved.
//

import Foundation

enum Mode {
    case furniture
    case measure
    case floorPlan
    case loadFloorPlan
}

extension Mode {
    static func string(index: Int) -> String {
        switch index {
        case 0:
            return "Furniture Mode"
        case 1:
            return "Measure Mode"
        case 2:
            return "FloorPlan Mode"
        case 3:
            return "Load FloorPlan Mode"
        default:
            return "Furniture Mode"
        }
    }
    
    static func string(mode: Mode) -> String {
        switch mode {
        case .furniture:
            return "Furniture Mode"
        case .measure:
            return "Measure Mode"
        case .floorPlan:
            return "FloorPlan Mode"
        case .loadFloorPlan:
            return "Load FloorPlan Mode"
        }
    }
    
    static func getMode(at index: Int) -> Mode {
        switch index {
        case 0:
            return .furniture
        case 1:
            return .measure
        case 2:
            return .floorPlan
        case 3:
            return .loadFloorPlan
        default:
            return .furniture
        }
    }
}
