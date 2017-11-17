/*
See LICENSE folder for this sample’s licensing information.

Abstract:
UI Actions for the main view controller.
*/

import UIKit
import SceneKit
import ReplayKit

extension ViewController: UIPopoverPresentationControllerDelegate, RPPreviewViewControllerDelegate {
    
    enum SegueIdentifier: String {
        case showObjects
        case showModes
        case showFloorPlan
    }
    
    // MARK: - Interface Actions
    @IBAction func startRecord(_ button: UIButton) {
        guard #available(iOS 10.0, *) else { return }
        
        let sharedRecorder = RPScreenRecorder.shared()
        if sharedRecorder.isRecording {
            stopRecordAction(recorder: sharedRecorder)
        } else {
            startRecordAction(recorder: sharedRecorder)
        }
    }
    
    // (+) 버튼
    @IBAction func chooseObject(_ button: UIButton) {
        // Abort if we are about to load another object to avoid concurrent modifications of the scene.
        if isLoadingObject { return }
        
        switch mode {
        case .furniture:
            textManager.cancelScheduledMessage(forType: .contentPlacement)
            performSegue(withIdentifier: SegueIdentifier.showObjects.rawValue, sender: button)
        case .measure:
            if isMeasuring { stopMeasuring() }
            else { startMeasuring() }
        case .floorPlan:
            if isComplete { stopMeasuringFP() }
            else if isMeasuringFP { continueMeasuringFP() }
            else { startMeasuringFP() }
        case .loadFloorPlan:
            let planeHitTestResults = self.sceneView.hitTest(self.screenCenter!, types: .existingPlane)
            guard let result = planeHitTestResults.first else { return }

            let hitPosition = SCNVector3.positionFromTransform(result.worldTransform)
            
            let sphere = SCNSphere(radius: 0.5)
            sphere.firstMaterial?.diffuse.contents = UIColor.red.cgColor
            sphere.firstMaterial?.lightingModel = .constant
            
            let pin1 = SCNNode(geometry: sphere)
            pin1.scale = SCNVector3(0.01, 0.01, 0.01)
            pin1.position = hitPosition
            sceneView.scene.rootNode.addChildNode(pin1)
            
            if selectCount == 0 {
                firstPoint = hitPosition
                vec2 = hitPosition
                selectCount = selectCount + 1
                return
            } else if selectCount == 1 {
                vec2 -= hitPosition
                selectCount = selectCount + 1
                vec2 = vec2 * -1
            }
            
            betweenAngle = acos(vec.dot(vec2) / (vec.length() * vec2.length()))
            
            guard let definition = floorPlanDefinition else { return }
            
            let rootFPNode = SCNNode()
            rootFPNode.name = "rootFPNode"
            sceneView.scene.rootNode.addChildNode(rootFPNode)
            
            let subOffset = definition.floorPlaneInfo.first!
            
            for (index, point) in definition.floorPlaneInfo.enumerated() {
                var nextPoint: SCNVector3
                
                if index == definition.floorPlaneInfo.endIndex - 1 { nextPoint = definition.floorPlaneInfo[0] }
                else { nextPoint = definition.floorPlaneInfo[index + 1] }
                
                let startPoint = point - subOffset
                let endPoint = nextPoint - subOffset
                let line = Line(sceneView: sceneView, startNodePos: startPoint, rootNode: rootFPNode)
                line.update(to: endPoint)
                
                rootFPNode.addChildNode(line)
            }
            
            definition.virtualObjectCoding.forEach {
                let virtualObject = VirtualObject(definition: $0.virtualObjectDefinition)
                virtualObject.position = $0.position - subOffset
                virtualObject.eulerAngles = $0.eulerAngle
                virtualObject.scale = $0.scale
                rootFPNode.addChildNode(virtualObject)
                
                virtualObjectManager.virtualObjects.append(virtualObject)
                // Load the content asynchronously.
                DispatchQueue.global(qos: .userInitiated).async {
                    virtualObject.load()
                    
                    // Immediately place the object in 3D space.
                    self.updateQueue.async {
                        guard let frame = VirtualObjectFrame(virtualObject: virtualObject) else {
                            return
                        }
                        
                        virtualObject.setFrame(frame: frame)
                    }
                }
                
                if virtualObject.parent == nil {
                    updateQueue.async {
                        self.sceneView.scene.rootNode.addChildNode(virtualObject)
                    }
                }
            }

            rootFPNode.position = firstPoint
            rootFPNode.eulerAngles.y = -betweenAngle
            
            mode = .furniture
        }
    }

    // 모드 선택
    @IBAction func chooseMode(_ button: UIButton) {
        textManager.cancelScheduledMessage(forType: .contentPlacement)
        performSegue(withIdentifier: SegueIdentifier.showModes.rawValue, sender: button)
    }
    
    /// - Tag: restartExperience
    @IBAction func restartExperience(_ sender: Any) {
        guard restartExperienceButtonIsEnabled, !isLoadingObject else { return }
        lines.forEach { $0.delete() }
        lines.removeAll()
        
        DispatchQueue.main.async {
            self.restartExperienceButtonIsEnabled = false
            
            self.textManager.cancelAllScheduledMessages()
            self.textManager.dismissPresentedAlert()
            self.textManager.showMessage("세션 재 시작")
            
//            self.virtualObjectManager.removeAllVirtualObjects()
            self.addObjectButton.setImage(#imageLiteral(resourceName: "add"), for: [])
            self.addObjectButton.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])
            self.focusSquare?.isHidden = true
            
            self.resetTracking()
            
            self.restartExperienceButton.setImage(#imageLiteral(resourceName: "restart"), for: [])
            
            // Show the focus square after a short delay to ensure all plane anchors have been deleted.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.setupFocusSquare()
            })
            
            // Disable Restart button for a while in order to give the session enough time to restart.
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                self.restartExperienceButtonIsEnabled = true
            })
        }
    }
    
    @IBAction func deleteObject(_ sender: Any) {
        guard let lastUsedObject = virtualObjectManager.lastUsedObject else {
            return
        }
        
        virtualObjectManager.removeVirtualObject(at: lastUsedObject)
    }
    
    // MARK: - private functions

    private func stopRecordAction(recorder: RPScreenRecorder) {
        recorder.stopRecording(handler: { (previewController, error) in
            let alertController = UIAlertController(title: "Recording",
                                                    message: "녹화한 내용을 확인하시겠습니까?",
                                                    preferredStyle: .alert)
            let discardAction = UIAlertAction(title: "삭제",
                                              style: .destructive) { (action) in
                                                recorder.discardRecording(handler: {
                                                    // discard
                                                })
            }
            
            let viewAction = UIAlertAction(title: "보기",
                                           style: .default,
                                           handler: { (action) in
                                            previewController?.previewControllerDelegate = self
                                            self.present(previewController!,
                                                         animated: true,
                                                         completion: nil)
            })
            
            alertController.addAction(discardAction)
            alertController.addAction(viewAction)
            
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    private func startRecordAction(recorder: RPScreenRecorder) {
        guard recorder.isAvailable else {
            print("Recording is not available")
            return
        }
        // apple replaykit sample source
        // startCapture
        recorder.startRecording { (error) in
            guard error == nil else {
                return
            }
            print("record start")
        }
    }
    
    private func startMeasuring() {
        guard let screenCenter = screenCenter else {
            return
        }
        
        if let verticalPlane = sceneView.hitTestToVerticalPlane(at: screenCenter),
            let ray = sceneView.rayFromScreenPos(screenCenter) {
            let startPos = ray.intersectionPosition(with: verticalPlane)
            currentLine = Line(sceneView: sceneView,
                               startNodePos: startPos,
                               rootNode: sceneView.scene.rootNode,
                               verticalPlane: verticalPlane)
            isMeasuring = true
            // vertical only for test
            return
        }
        
        let planeHitTestResults = sceneView.hitTest(view.center, types: .existingPlaneUsingExtent)

        guard let result = planeHitTestResults.first else { return }

        let hitPosition = SCNVector3.positionFromTransform(result.worldTransform)
        currentLine = Line(sceneView: sceneView, startNodePos: hitPosition, rootNode: sceneView.scene.rootNode)
        isMeasuring = true
    }
    
    private func stopMeasuring() {
        isMeasuring = false
        
        if let currentLine = currentLine {
            lines.append(currentLine)
            self.currentLine = nil
        }
    }
    
    private func startMeasuringFP() {
        let planeHitTestResults = sceneView.hitTest(view.center, types: .existingPlaneUsingExtent)
        
        guard let result = planeHitTestResults.first else { return }
        
        let hitPosition = SCNVector3.positionFromTransform(result.worldTransform)
        isMeasuringFP = true
        FPCurrentLine = Line(sceneView: sceneView, startNodePos: hitPosition, rootNode: sceneView.scene.rootNode)
    }
    
    private func continueMeasuringFP() {
        if let FPCurrentLine = FPCurrentLine {
            FPLines.append(FPCurrentLine)
            self.FPCurrentLine = Line(sceneView: sceneView, startNodePos: FPCurrentLine.endNodePos(), rootNode: sceneView.scene.rootNode)
        }
    }
    
    private func stopMeasuringFP() {
        isMeasuringFP = false
        isComplete = false
        
        if let FPCurrentLine = FPCurrentLine {
            FPLines.append(FPCurrentLine)
            self.FPCurrentLine = nil
        }
        
        let alertController = UIAlertController(title: "평면도",
                                                message: "측정한 평면도를 사용하시겠습니까?",
                                                preferredStyle: .alert)
        let discardAction = UIAlertAction(title: "삭제",
                                          style: .destructive) { [unowned self] (action) in
                                            self.FPLines.forEach { $0.delete() }
                                            self.FPLines = []
        }
        
        let viewAction = UIAlertAction(title: "보기",
                                       style: .default,
                                       handler: { [unowned self] (action) in
                                        self.FPLines.forEach { $0.delete() }
                                        self.performSegue(withIdentifier: SegueIdentifier.showFloorPlan.rawValue, sender: nil)
        })
        
        alertController.addAction(discardAction)
        alertController.addAction(viewAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - RPPreviewViewControllerDelegate
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
    
    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        if activityTypes.contains("com.apple.UIKit.activity.SaveToCameraRoll") {
            print("aa")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // All popover segues should be popovers even on iPhone.
        if let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton {
            popoverController.delegate = self
            popoverController.sourceRect = button.bounds
        }
        
        if let floorPlanViewController = segue.destination as? FloorPlanViewController {
            floorPlanViewController.delegate = self
        }
        
        guard let identifier = segue.identifier, let segueIdentifer = SegueIdentifier(rawValue: identifier) else { return }
        if segueIdentifer == .showObjects, let objectsViewController = segue.destination as? VirtualObjectSelectionViewController {
            objectsViewController.delegate = self
        }
        if segueIdentifer == .showModes, let modeSelectionViewController = segue.destination as? ModeSelectionViewController {
            modeSelectionViewController.delegate = self
        }
        if segueIdentifer == .showFloorPlan, let floorPlanViewController = segue.destination as? FloorPlanViewController {

            var lineStartPoints: [SCNVector3] = []
            FPLines.forEach { lineStartPoints.append($0.startNodeWorldPos()) }
            
            floorPlanViewController.floorPlan = FloorPlan(floorPlanVectors: lineStartPoints,
                                                          virtualObjects: virtualObjectManager.virtualObjects)
        }
        
    }
}
