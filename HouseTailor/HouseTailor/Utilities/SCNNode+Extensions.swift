//
//  SCNNodeExtensions.swift
//  HouseTailor
//
//  Created by Yoo Seok Kim on 2017. 10. 13..
//  Copyright © 2017년 Nois. All rights reserved.
//

import ARKit

// MARK: - SCNNode extension

extension SCNNode {
    func setUniformScale(_ scale: Float) {
        self.simdScale = float3(scale, scale, scale)
    }
    
    func renderOnTop(_ enable: Bool) {
        self.renderingOrder = enable ? 2 : 0
        if let geom = self.geometry {
            for material in geom.materials {
                material.readsFromDepthBuffer = enable ? false : true
            }
        }
        for child in self.childNodes {
            child.renderOnTop(enable)
        }
    }
    
    func setCategoryBitMask(_ bitMask: Int) {
        if self.childNodes.count > 0 {
            self.childNodes.forEach ({ (node) in
                guard !(node.name == "shadowPlane") else { return }
                node.setCategoryBitMask(bitMask)
            })
        }
        self.categoryBitMask = bitMask
    }
}
