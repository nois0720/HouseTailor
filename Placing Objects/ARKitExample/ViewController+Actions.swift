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
        case showSettings
        case showObjects
        case showModes
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
    
    @IBAction func chooseObject(_ button: UIButton) {
        // Abort if we are about to load another object to avoid concurrent modifications of the scene.
        if isLoadingObject { return }
        
        if mode == .furniture {
            textManager.cancelScheduledMessage(forType: .contentPlacement)
            performSegue(withIdentifier: SegueIdentifier.showObjects.rawValue, sender: button)
        } else {
            createPin()
        }
    }

    @IBAction func chooseMode(_ button: UIButton) {
        textManager.cancelScheduledMessage(forType: .contentPlacement)
        performSegue(withIdentifier: SegueIdentifier.showModes.rawValue, sender: button)
    }
    
    private func stopRecordAction(recorder: RPScreenRecorder) {
        recorder.stopRecording(handler: { (previewController, error) in
            print("stop")
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
                print(error!)
                return
            }
            print("record start")
        }
    }
    
    private func createPin() {
        if isMeasuring {
            // @IBAction
            // ViewController's lines(Array)에 line 추가
            isMeasuring = false
            
            if let currentLine = currentLine {
                lines.append(currentLine)
                self.currentLine = nil
            }
        } else {
            let planeHitTestResults = sceneView.hitTest(view.center, types: .existingPlaneUsingExtent)
            if let result = planeHitTestResults.first {
                let hitPosition = SCNVector3.positionFromTransform(result.worldTransform)
                currentLine = Line(sceneView: sceneView, startNodePos: hitPosition)
                isMeasuring = true
            }
        }
    }
    
    /// - Tag: restartExperience
    @IBAction func restartExperience(_ sender: Any) {
        guard restartExperienceButtonIsEnabled, !isLoadingObject else { return }
        
        DispatchQueue.main.async {
            self.restartExperienceButtonIsEnabled = false
            
            self.textManager.cancelAllScheduledMessages()
            self.textManager.dismissPresentedAlert()
            self.textManager.showMessage("STARTING A NEW SESSION")
            
            self.virtualObjectManager.removeAllVirtualObjects()
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
        
        guard let identifier = segue.identifier, let segueIdentifer = SegueIdentifier(rawValue: identifier) else { return }
        if segueIdentifer == .showObjects, let objectsViewController = segue.destination as? VirtualObjectSelectionViewController {
            objectsViewController.delegate = self
        }
        if segueIdentifer == .showModes, let modeSelectionViewController = segue.destination as? ModeSelectionViewController {
            modeSelectionViewController.delegate = self
        }
    }
}
