//
//  Polygon.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 25..
//  Copyright © 2017년 Apple. All rights reserved.
//

import UIKit

class Polygon {
    
    var startPoint: CGPoint
    var movePoints: [CGPoint] = []
    
    init(lines: [Line]) {
        
        self.startPoint = lines.first!.toCGPoint()
        
        lines.forEach { movePoints.append($0.toCGPoint()) }
        movePoints.remove(at: 0)
    }

}
