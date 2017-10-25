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
        
//        self.startPoint = SCNVector3toCGPoint(vec: lines.first!.startNodePos())
        
        var originPoints: [CGPoint] = []
        lines.forEach { originPoints.append(SCNVector3toCGPoint(vec: $0.startNodePos())) }
        
        var avgX = CGFloat(0)
        var avgY = CGFloat(0)
        
        originPoints.forEach {
            avgX = avgX + $0.x
            avgY = avgY + $0.y
        }
        
        avgX = avgX / CGFloat(originPoints.count)
        avgY = avgY / CGFloat(originPoints.count)
        let center = UIScreen.main.bounds.mid
        let offsetVector = center - CGPoint(x: avgX, y: avgY)
        
        originPoints.remove(at: 0)
        self.startPoint = SCNVector3toCGPoint(vec: lines.first!.startNodePos()) + offsetVector
        originPoints.forEach { movePoints.append($0 + offsetVector) }
    }

}
