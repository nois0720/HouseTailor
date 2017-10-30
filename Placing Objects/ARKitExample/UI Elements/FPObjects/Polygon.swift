//
//  Polygon.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 25..
//  Copyright © 2017년 Apple. All rights reserved.
//

import UIKit

class Polygon: Codable {
    
    struct LengthText: Codable {
        var length: CGFloat
        var pos: CGPoint
        
        init(length: CGFloat, pos: CGPoint) {
            self.length = length
            self.pos = pos
        }
    }
    
    var startPoint: CGPoint
    var movePoints: [CGPoint] = []
    var lengthTexts: [LengthText] = []
    
    init(lines: [Line]) {
        
        // get approximate offset vector
        var originPoints: [CGPoint] = []
        lines.forEach { originPoints.append(SCNVector3toGridCGPoint(vec: $0.startNodeWorldPos())) }
        
        var avgX = CGFloat(0)
        var avgY = CGFloat(0)
        
        originPoints.forEach {
            avgX = avgX + $0.x
            avgY = avgY + $0.y
        }
        
        avgX = avgX / CGFloat(originPoints.count)
        avgY = avgY / CGFloat(originPoints.count)
//        let center = UIScreen.main.bounds.mid
//        let offsetVector = center - CGPoint(x: avgX, y: avgY)
        
        // init properties
        self.startPoint = SCNVector3toGridCGPoint(vec: lines.first!.startNodeWorldPos())
        // + offsetVector
        originPoints.forEach { self.movePoints.append($0) }
//        originPoints.forEach { self.movePoints.append($0 + offsetVector) }
        
        for (index, point) in movePoints.enumerated() {
            var point2: CGPoint
            
            if index == movePoints.endIndex - 1 { point2 = movePoints[0] }
            else { point2 = movePoints[index + 1] }
            
            let length = point.distanceTo(point2)
            let pos = point.midpoint(point2)
            lengthTexts.append(LengthText(length: length, pos: pos))
        }
        
        movePoints.remove(at: 0)
    }

}
