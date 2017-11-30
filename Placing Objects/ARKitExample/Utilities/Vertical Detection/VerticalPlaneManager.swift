//
//  VerticalPlaneDetector.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 10..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit

class VerticalPlaneManager {
    var delegate: VerticalPlaneManagerDelegate?
    
    var sceneView: ARSCNView
    var verticalPlanes: [VerticalPlane] = []
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
    }

    func updatePlane(newVerticalPlane: VerticalPlane) {
        
        var isUpdate = false
        
        // TODO: 유사도 정의
        // 생성하려는 위치에 이미 '유사도가 높은' 평면이 있다면, 해당 평면 업데이트.
        verticalPlanes.forEach {
            // center
            if $0.similarity(other: newVerticalPlane) {
                $0.updatePlane(other: newVerticalPlane)
                delegate?.verticalPlaneManager(didUpdate: $0)
                isUpdate = true
            }
        }
        
        if isUpdate { return }
        
        addPlane(verticalPlane: newVerticalPlane)
    }
    
    private func addPlane(verticalPlane: VerticalPlane) {
        // 새로운 vertical plane 생성
        sceneView.scene.rootNode.addChildNode(verticalPlane)
        verticalPlanes.append(verticalPlane)
        delegate?.verticalPlaneManager(didAdd: verticalPlane)
    }
    
}

protocol VerticalPlaneManagerDelegate: class {
    func verticalPlaneManager(didAdd node: SCNNode)
    func verticalPlaneManager(didUpdate node: SCNNode)
    func verticalPlaneManager(didRemove node: SCNNode)
}

