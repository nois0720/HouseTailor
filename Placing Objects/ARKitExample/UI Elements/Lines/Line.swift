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
    
    // private properties
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
    private let startNodePos: SCNVector3!
    
    init(sceneView: ARSCNView, startNodePos: SCNVector3) {
        self.sceneView = sceneView
        self.startNodePos = startNodePos
        
        let sphere = SCNSphere(radius: 0.5)
        sphere.firstMaterial?.diffuse.contents = nodeColor
        sphere.firstMaterial?.lightingModel = .constant
        
        startNode = SCNNode(geometry: sphere)
        startNode.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        startNode.position = startNodePos
        sceneView.scene.rootNode.addChildNode(startNode)
        
        endNode = SCNNode(geometry: sphere)
        endNode.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        
        lenText = SCNText(string: "", extrusionDepth: textDepth)
        lenText.font = .systemFont(ofSize: 4)
        lenText.firstMaterial?.diffuse.contents = textColor
        lenText.alignmentMode  = kCAAlignmentJustified
        lenText.firstMaterial?.isDoubleSided = true
  
        let textWrapperNode = SCNNode(geometry: lenText)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        
        lenTextNode = SCNNode()
        lenTextNode.addChildNode(textWrapperNode)
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true
        lenTextNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(lenTextNode)
    }
    
    func update(to vector: SCNVector3) {
        lineNode?.removeFromParentNode()
        lineNode = lineSCNNode(from: startNodePos, to: vector, color: lineColor)
        
        sceneView.scene.rootNode.addChildNode(lineNode!)

        lenText.string = String(format: "%.2f m", distance(startPos: startNodePos, endPos: vector))
        lenTextNode.position = SCNVector3((startNodePos.x + vector.x) / 2.0,
                                          (startNodePos.y + vector.y) / 2.0,
                                          (startNodePos.z + vector.z) / 2.0)

        endNode.position = vector
        if endNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(endNode)
        }
    }
    
    func removeFromParentNode() {
        startNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
        endNode.removeFromParentNode()
        lenTextNode.removeFromParentNode()
    }
    
}
