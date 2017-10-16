//
//  ViewController.swift
//  HouseTailor
//
//  Created by Yoo Seok Kim on 2017. 10. 11..
//  Copyright © 2017년 Nois. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController {
    
    // MARK: - ARKit Config Properties
    
    var screenCenter: CGPoint?
    
    let session = ARSession()
    let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }()
    
    // MARK: - Virtual Object Manipulation Properties
    
    var dragOnInfinitePlanesEnabled = false
//    var virtualObjectManager: VirtualObjectManager!
    
    var isLoadingObject: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.settingButton.isEnabled = !self.isLoadingObject
                self.addObjectButton.isEnabled = !self.isLoadingObject
                self.restartButton.isEnabled = !self.isLoadingObject
            }
        }
    }
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messagePanel: UIVisualEffectView!
    @IBOutlet weak var addObjectButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIControls()
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func setupUIControls() {
        // Set appearance of message output panel
        messagePanel.layer.cornerRadius = 3.0
        messagePanel.clipsToBounds = true
        messagePanel.isHidden = true
        messageLabel.text = ""
    }
    
    func setupScene() {
        // Synchronize updates via the `serialQueue`.
//        virtualObjectManager = VirtualObjectManager(updateQueue: serialQueue)
//        virtualObjectManager.delegate = self
        
        // set up scene view
        sceneView.setup()
        sceneView.delegate = self
        sceneView.session = session
        // sceneView.showsStatistics = true
        
//        sceneView.scene.enableEnvironmentMapWithIntensity(25, queue: serialQueue)
        
//        setupFocusSquare()
        
        DispatchQueue.main.async {
            self.screenCenter = CGPoint(x: self.sceneView.bounds.midX,
                                        y: self.sceneView.bounds.midY)
        }
    }
    
    // MARK: - Planes
    
    var planes = [ARPlaneAnchor: Plane]()
    
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        
        let plane = Plane(anchor)
        planes[anchor] = plane
        node.addChildNode(plane)
        
//        textManager.cancelScheduledMessage(forType: .planeEstimation)
//        textManager.showMessage("SURFACE DETECTED")
//        if virtualObjectManager.virtualObjects.isEmpty {
//            textManager.scheduleMessage("TAP + TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .contentPlacement)
//        }
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
    
    func removePlane(anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
        }
    }
    
    func resetTracking() {
        session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
//        textManager.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT",
//                                    inSeconds: 7.5,
//                                    messageType: .planeEstimation)
    }
    
    // MARK: - Focus Square
    
    var focusSquare: FocusSquare?
    
    func setupFocusSquare() {
//        serialQueue.async {
//            self.focusSquare?.isHidden = true
//            self.focusSquare?.removeFromParentNode()
//            self.focusSquare = FocusSquare()
//            self.sceneView.scene.rootNode.addChildNode(self.focusSquare!)
//        }
        
//        textManager.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
    }
    
//    func updateFocusSquare() {
//        guard let screenCenter = screenCenter else { return }
//
//        DispatchQueue.main.async {
//            var objectVisible = false
//            for object in self.virtualObjectManager.virtualObjects {
//                if self.sceneView.isNode(object, insideFrustumOf: self.sceneView.pointOfView!) {
//                    objectVisible = true
//                    break
//                }
//            }
//            
//            if objectVisible {
//                self.focusSquare?.hide()
//            } else {
//                self.focusSquare?.unhide()
//            }
//            
//            let (worldPos, planeAnchor, _) = self.virtualObjectManager.worldPositionFromScreenPosition(screenCenter,
//                                                                                                       in: self.sceneView,
//                                                                                                       objectPos: self.focusSquare?.simdPosition)
//            if let worldPos = worldPos {
//                self.serialQueue.async {
//                    self.focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
//                }
//                self.textManager.cancelScheduledMessage(forType: .focusSquare)
//            }
//        }
//    }
}
