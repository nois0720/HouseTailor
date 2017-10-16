//
//  Plane.swift
//  HouseTailor
//
//  Created by Yoo Seok Kim on 2017. 10. 13..
//  Copyright © 2017년 Nois. All rights reserved.
//

import ARKit

class Plane: SCNNode {
    
    // MARK: - Properties
    
    var anchor: ARPlaneAnchor
    var focusSquare: FocusSquare?
    
    // MARK: - Initialization
    
    init(_ anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ARKit
    
    func update(_ anchor: ARPlaneAnchor) {
        self.anchor = anchor
    }
    
}
