//
//  FloorPlanDefinition.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 31..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit
import UIKit

struct VirtualObjectCoding: Codable {
    
    // definition of virtualObject
    let virtualObjectDefinition: VirtualObjectDefinition
    
    // transform of virtualObject
    let position: SCNVector3
    let eulerAngle: SCNVector3
    let scale: SCNVector3
    let virtualObjectProjectPoints: [SCNVector3]?
    
    init(virtualObjectDefinition: VirtualObjectDefinition,
         position: SCNVector3,
         eulerAngle: SCNVector3,
         scale: SCNVector3,
         virtualObjectProjectPoints: [SCNVector3]? = nil) {
        
        self.virtualObjectDefinition = virtualObjectDefinition
        self.position = position
        self.eulerAngle = eulerAngle
        self.scale = scale
        self.virtualObjectProjectPoints = virtualObjectProjectPoints
    }
}

struct FloorPlanDefinition: Codable {
    
    var name: String
    let virtualObjectCoding: [VirtualObjectCoding]
    let floorPlaneInfo: [SCNVector3]
    
    init(name: String,
         virtualObjectCoding: [VirtualObjectCoding],
         floorPlaneInfo: [SCNVector3]) {
        self.name = name
        self.virtualObjectCoding = virtualObjectCoding
        self.floorPlaneInfo = floorPlaneInfo
    }
    
    mutating func setName(_ name: String) {
        self.name = name
    }
}

struct FloorPlan {
    
    var floorPlanDefinition: FloorPlanDefinition!
    
    private var virtualObjectProjectPoints: [[SCNVector3]] = []
    private var floorPlanVectors: [SCNVector3] = []
    
    private var floorPlanShape: CAShapeLayer {
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.lineWidth = 2
        shapeLayer.opacity = 0.9
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.strokeColor = UIColor(red: 1, green: 0.7, blue: 0, alpha: 0.8).cgColor
        shapeLayer.fillColor = UIColor(red: 0.3, green: 0.52, blue: 0.6, alpha: 1).cgColor
        
        return shapeLayer
    }
    
    private var virtualObjectShape: CAShapeLayer {
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.lineWidth = 1
        shapeLayer.opacity = 0.9
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        shapeLayer.fillColor = UIColor(red: CGFloat(arc4random()) / CGFloat(UINT32_MAX), green: CGFloat(arc4random()) / CGFloat(UINT32_MAX), blue: CGFloat(arc4random()) / CGFloat(UINT32_MAX), alpha: 1.0).cgColor
        
        return shapeLayer
    }
    
    init(definition: FloorPlanDefinition) {
        
        self.floorPlanDefinition = definition
        
        definition.virtualObjectCoding.forEach {
            if let projectPoints = $0.virtualObjectProjectPoints {
                self.virtualObjectProjectPoints.append(projectPoints)
            }
        }
        
        self.floorPlanVectors = definition.floorPlaneInfo
    }
    
    init(floorPlanVectors: [SCNVector3], virtualObjects: [VirtualObject]? = nil) {
        
        self.floorPlanVectors = floorPlanVectors
        
        var virtualObjectCodings: [VirtualObjectCoding] = []
        virtualObjects?.forEach {
            let virtualObjectCoding =
                VirtualObjectCoding(virtualObjectDefinition: $0.definition,
                                    position: $0.position,
                                    eulerAngle: $0.eulerAngles,
                                    scale: $0.scale,
                                    virtualObjectProjectPoints: $0.frame?.projectPoints())
            
            virtualObjectCodings.append(virtualObjectCoding)
        }
        
        self.floorPlanDefinition =
            FloorPlanDefinition(name: "",
                                virtualObjectCoding: virtualObjectCodings,
                                floorPlaneInfo: floorPlanVectors)
    }
    
    func draw(on view: UIView, with layerArray: NSMutableArray) {
        
        func drawPolygon(shape: CAShapeLayer, vectors: [SCNVector3]) {
            let path = UIBezierPath()
            for (index, point) in vectors.enumerated() {
                var nextPoint: SCNVector3
                
                if index == vectors.endIndex - 1 { nextPoint = vectors[0] }
                else { nextPoint = vectors[index + 1] }
                
                let length = distance(startPos: point, endPos: nextPoint)
                let pos = SCNVector3ToGridCGPoint(vector: point.mid(other: nextPoint))
                
                let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
                
                textLabel.font = UIFont.init(name: "Helvetica", size: 8)
                textLabel.center = CGPoint(x: pos.x, y: pos.y)
                textLabel.text = String(format: "%.2fm", length)
                textLabel.textAlignment = .center
                textLabel.minimumScaleFactor = 0.5
                textLabel.adjustsFontSizeToFitWidth = true
                layerArray.add(textLabel)
                view.addSubview(textLabel)
            }
            
            var pathPoints = vectors.map { return SCNVector3ToGridCGPoint(vector: $0) }
            path.move(to: pathPoints.first!)
            pathPoints.remove(at: 0)
            
            pathPoints.forEach { path.addLine(to: $0) }
            path.close()
            shape.path = path.cgPath
            layerArray.add(shape)
        }
        
        func drawVirtualObject() {
            let shape = virtualObjectShape
            view.layer.addSublayer(shape)
            
            virtualObjectProjectPoints.forEach {
                drawPolygon(shape: shape, vectors: $0)
            }
        }
        
        func drawFloorPlan() {
            let shape = floorPlanShape
            view.layer.addSublayer(shape)
            
            drawPolygon(shape: shape, vectors: floorPlanVectors)
        }
        
        drawFloorPlan()
        drawVirtualObject()
    }
    
    private func SCNVector3ToCGPoint(vector: SCNVector3) -> CGPoint {
    
        let x = CGFloat(vector.x)
        let y = CGFloat(vector.z)
        
        return CGPoint(x: x, y: y)
    }
    
    private func SCNVector3ToGridCGPoint(vector: SCNVector3) -> CGPoint {
        
        let screen = UIScreen.main.bounds
        let screenWidth = screen.width / 2
        let screenHeight = screen.height / 2
        
        let x = CGFloat(vector.x * 50) + screenWidth
        let y = CGFloat(vector.z * 50) + screenHeight
        
        return CGPoint(x: x, y: y)
    }
}
