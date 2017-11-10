//
//  VerticalPlane.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 10..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit

class VerticalPlaneAnchor : ARAnchor {
//    var center: vector_float3
    
    override init(transform: matrix_float4x4) {
//        center = .init(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        super.init(transform: transform)
    }
}

class VerticalPlane: SCNNode {
    
    // MARK: - Properties
    
    var anchor: VerticalPlaneAnchor
    var normal: SCNVector3
    
    // MARK: - Initialization
    
    init(_ anchor: VerticalPlaneAnchor, _ normal: SCNVector3) {
        self.anchor = anchor
        self.normal = normal
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ARKit
    
    func update(_ anchor: VerticalPlaneAnchor) {
        self.anchor = anchor
    }
    
}
