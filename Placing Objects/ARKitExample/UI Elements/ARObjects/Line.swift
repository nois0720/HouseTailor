//
//  Line.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 18..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit
import SceneKit

class Line {
    private var startNode: SCNNode!     // 시작 노드
    private var endNode: SCNNode!       // 끝 노드
    private var lenText: SCNText!       // 길이 텍스트
    private var lenTextNode: SCNNode!
    private var lineNode: SCNNode?
    
    private var nodeColor: UIColor = .red   // 노드 색
    private var lineColor: UIColor = .black // 라인 색
    private var textColor: UIColor = .black // 텍스트 색
    private let nodeRadius: CGFloat = 0.01  // 1cm
    private let textDepth: CGFloat = 0.1    // 10cm
    
    private let sceneView: ARSCNView!
    
    init(sceneView: ARSCNView, startNodePos: SCNVector3) {
        self.sceneView = sceneView
        
        let sphere = SCNSphere(radius: 0.5)
        sphere.firstMaterial?.diffuse.contents = nodeColor
        sphere.firstMaterial?.lightingModel = .constant
        
        startNode = SCNNode(geometry: sphere)
        startNode.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        startNode.position = startNodePos
        sceneView.scene.rootNode.addChildNode(startNode)
        
        endNode = SCNNode(geometry: sphere)
        endNode.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        
        // length text. unit: meter
        lenText = SCNText(string: "", extrusionDepth: textDepth)
        lenText.font = .systemFont(ofSize: 4)
        lenText.firstMaterial?.diffuse.contents = textColor
        lenText.alignmentMode = kCAAlignmentJustified
        
        // SCNText constraint
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true // roll axis 기준 회전을 막아 pov와 수평을 이루도록 함
        
        let replicatorConstraint = SCNReplicatorConstraint(target: lineNode)
        // Documentation에 따르면, SCNLookAtConstraint를 사용하면, constraint가 적용된 노드의
        // negative z-axis가 constraint의 타겟 노드를 바라보도록 업데이트 됨.
        // 따라서, 업데이트의 영향을 받지 않는 하위 WrapperNode를 만들어 해당 노드의 yaw를 pi만큼 돌려주고
        // 이를 상위 노드에 추가.
        let textWrapperNode = SCNNode(geometry: lenText)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        
        lenTextNode = SCNNode()
        lenTextNode.addChildNode(textWrapperNode)
        lenTextNode.constraints = [constraint, replicatorConstraint]
        sceneView.scene.rootNode.addChildNode(lenTextNode)
    }
    
    func update(to vector: SCNVector3) {
        lineNode?.removeFromParentNode()
        
        lineNode = lineSCNNode(from: startNodePos(), to: vector, color: lineColor)
        lineNode?.categoryBitMask = 2
        sceneView.scene.rootNode.addChildNode(lineNode!)

        lenText.string = String(format: "%.2f m", distance(startPos: startNodePos(), endPos: vector))
        lenTextNode.position = SCNVector3((startNodePos().x + vector.x) / 2.0,
                                          (startNodePos().y + vector.y) / 2.0,
                                          (startNodePos().z + vector.z) / 2.0)

        endNode.position = vector
        if endNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(endNode)
            
        }
    }
    
    func delete() {
        removeFromParentNode()
        self.removeFromParentNode()
    }
    
    func startNodePos() -> SCNVector3 {
        return startNode.position
    }
    
    func endNodePos() -> SCNVector3 {
        return endNode.position
    }
    
    func isIntersect(other: Line) -> Bool {
        let AP1: SCNVector3 = self.startNodePos()
        let AP2: SCNVector3 = self.endNodePos()
        let BP1: SCNVector3 = other.startNodePos()
        let BP2: SCNVector3 = other.endNodePos()
        
        let divider: Double = Double((BP2.z - BP1.z) * (AP2.x - AP1.x) - (BP2.x - BP1.x) * (AP2.z - AP1.z))
        
        let _t: Double = Double((BP2.x - BP1.x) * (AP1.z - BP1.z) - (BP2.z - BP1.z) * (AP1.x - BP1.x))
        let _s: Double = Double((AP2.x - AP1.x) * (AP1.z - BP1.z) - (AP2.z - AP1.z) * (AP1.x - BP1.x))
        
        let t: Double = _t / divider
        let s: Double = _s / divider
        
//        print("t: \(t)")
//        print("s: \(s)")
        if t == 1.0 && s == 0.0 { return false }
        
        if t < 0.0 || t > 1.0 || s < 0.0 || s > 1.0 { return false }
        else if _t == 0 && _s == 0 { return false }
        
        return true
    }
    
    func setCategory(number: Int) {
        lineNode?.categoryBitMask = number
    }
    
    func toCGPoint() -> CGPoint {
        let screen = UIScreen.main.bounds
        let screenWidth = screen.width / 2
        let screenHeight = screen.height / 2
        
        let x = CGFloat(self.startNodePos().x * 100.0) + screenWidth
        let y = CGFloat(self.startNodePos().z * 100.0) + screenHeight
        
        return CGPoint(x: x, y: y)
    }
    
    
    private func removeFromParentNode() {
        startNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
        endNode.removeFromParentNode()
        lenTextNode.removeFromParentNode()
    }
}
