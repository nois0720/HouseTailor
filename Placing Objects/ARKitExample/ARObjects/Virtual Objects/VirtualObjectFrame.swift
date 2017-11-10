//
//  VirtualObjectFrame.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 26..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit

class VirtualObjectFrame: SCNNode {
    
    //    (n7)-(n8)
    //    /    / |
    //   /    /  |
    // (n5)-(n6) (n4)
    //  |    |  /
    //  |    | /
    // (n1)-(n2)
    
    // bottom nodes
    private var n1: SCNNode!
    private var n2: SCNNode!
    private var n3: SCNNode!
    private var n4: SCNNode!
    
    // top nodes
    private var n5: SCNNode!
    private var n6: SCNNode!
    private var n7: SCNNode!
    private var n8: SCNNode!
    
    private var nodeColor: UIColor = .red   // 노드 색
    private var lineColor: UIColor = .black // 라인 색
    private var textColor: UIColor = .black // 텍스트 색
    private let nodeRadius: CGFloat = 0.01  // 1cm
    private let textDepth: CGFloat = 0.1    // 10cm
    
    init?(virtualObject: VirtualObject) {
        super.init()
        if virtualObject.definition.modelName == "sofa" {
            boundingBox = virtualObject.boundingBox
        } else {
            if let boundingBox = virtualObject.childNode(withName: "\(virtualObject.definition.modelName)Model", recursively: true)?.boundingBox {
                self.boundingBox = boundingBox
            }
        }
        
        let sphere = SCNSphere(radius: 0.5)
        sphere.firstMaterial?.diffuse.contents = nodeColor
        sphere.firstMaterial?.lightingModel = .constant
        
        let (boundingBoxMin, boundingBoxMax) = boundingBox
        
        self.n1 = SCNNode(geometry: sphere)
        self.n1.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        self.n1.position = SCNVector3(boundingBoxMin.x, boundingBoxMin.y, boundingBoxMin.z)
        self.addChildNode(n1)
        
        self.n2 = SCNNode(geometry: sphere)
        self.n2.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        self.n2.position = SCNVector3(boundingBoxMax.x, boundingBoxMin.y, boundingBoxMin.z)
        self.addChildNode(n2)
        
        self.n3 = SCNNode(geometry: sphere)
        self.n3.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        self.n3.position = SCNVector3(boundingBoxMin.x, boundingBoxMin.y, boundingBoxMax.z)
        self.addChildNode(n3)
        
        self.n4 = SCNNode(geometry: sphere)
        self.n4.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        self.n4.position = SCNVector3(boundingBoxMax.x, boundingBoxMin.y, boundingBoxMax.z)
        self.addChildNode(n4)
        
        self.n5 = SCNNode(geometry: sphere)
        self.n5.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        self.n5.position = SCNVector3(boundingBoxMin.x, boundingBoxMax.y, boundingBoxMin.z)
        self.addChildNode(n5)
        
        self.n6 = SCNNode(geometry: sphere)
        self.n6.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        self.n6.position = SCNVector3(boundingBoxMax.x, boundingBoxMax.y, boundingBoxMin.z)
        self.addChildNode(n6)
        
        self.n7 = SCNNode(geometry: sphere)
        self.n7.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        self.n7.position = SCNVector3(boundingBoxMin.x, boundingBoxMax.y, boundingBoxMax.z)
        self.addChildNode(n7)
        
        self.n8 = SCNNode(geometry: sphere)
        self.n8.scale = SCNVector3(nodeRadius, nodeRadius, nodeRadius)
        self.n8.position = SCNVector3(boundingBoxMax.x, boundingBoxMax.y, boundingBoxMax.z)
        self.addChildNode(n8)
        
        //    (n7)---(n8)
        //    /      / |
        //   /      /  |
        // (n5)---(n6)(n4)
        //  |      |  /
        //  |      | /
        //  |      |/
        // (n1)---(n2)         
        
        // bottom line
        let line1 = lineSCNNode(from: n1.position, to: n2.position)
        let line2 = lineSCNNode(from: n1.position, to: n3.position)
        let line3 = lineSCNNode(from: n2.position, to: n4.position)
        let line4 = lineSCNNode(from: n4.position, to: n3.position)
        
        // middle line
        let line5 = lineSCNNode(from: n1.position, to: n5.position)
        let line6 = lineSCNNode(from: n2.position, to: n6.position)
        let line7 = lineSCNNode(from: n3.position, to: n7.position)
        let line8 = lineSCNNode(from: n4.position, to: n8.position)
        
        // top line
        let line9 = lineSCNNode(from: n5.position, to: n6.position)
        let line10 = lineSCNNode(from: n5.position, to: n7.position)
        let line11 = lineSCNNode(from: n6.position, to: n8.position)
        let line12 = lineSCNNode(from: n7.position, to: n8.position)
        
        self.addChildNode(line1)
        self.addChildNode(line2)
        self.addChildNode(line3)
        self.addChildNode(line4)
        self.addChildNode(line5)
        self.addChildNode(line6)
        self.addChildNode(line7)
        self.addChildNode(line8)
        self.addChildNode(line9)
        self.addChildNode(line10)
        self.addChildNode(line11)
        self.addChildNode(line12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func projectPoints() -> [SCNVector3] {
        
        // (n3)-(n4)
        //  |    |
        //  |    |
        // (n1)-(n2)
        
        // n1, n2, n4, n3순인 이유는 CALayer를 사용하기 때문에 그리는 순서가 중요.
        let pos1 = n1.worldPosition
        let pos2 = n2.worldPosition
        let pos3 = n4.worldPosition
        let pos4 = n3.worldPosition
        
        let vectors: [SCNVector3] = [pos1, pos2, pos3, pos4]
        return vectors
    }
    
}

