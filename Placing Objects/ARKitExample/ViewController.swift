/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController {
    
    // MARK: - ARKit Config Properties
    
    var screenCenter: CGPoint?

    let session = ARSession()
    let worldTrackingConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }()
    
    // MARK: delaunay triangle rootnode
    let dtRootNode: SCNNode = SCNNode()
    
    // MARK: AR Measure Properties
    
    var startNode: SCNNode?
    var endNode: SCNNode?
    var lines: [Line] = []
    var currentLine: Line?
    var isMeasuring: Bool = false
    
    // MARK: AR Floor Plan Properties
    
    var FPStartNode: SCNNode?
    var FPLines: [Line] = []
    var FPCurrentLine: Line?
    var isMeasuringFP: Bool = false
    var isComplete: Bool = false
    
    // MARK: for load
    
    var floorPlanDefinition: FloorPlanDefinition?
    var selectCount: Int = 0
    var vec: SCNVector3 = SCNVector3(0, 0, 0)
    var vec2: SCNVector3 = SCNVector3(0, 0, 0)
    var betweenAngle: Float = 0
    var firstPoint = SCNVector3(0, 0, 0)
    var rootFPNode = SCNNode()
    
    // MARK: VerticalPlane Detection
    
    var verticalPlaneDetector: VerticalPlaneDetector!
    
    // MARK: - Virtual Object Manipulation Properties
    
    var virtualObjectManager: VirtualObjectManager!
    
    var isLoadingObject: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.settingsButton.isEnabled = !self.isLoadingObject
                self.addObjectButton.isEnabled = !self.isLoadingObject
                self.restartExperienceButton.isEnabled = !self.isLoadingObject
            }
        }
    }
    
    // MARK: - Other Properties
    
    var textManager: TextManager!
    var restartExperienceButtonIsEnabled = true
    var mode = Mode.furniture {
        willSet {
            if newValue == Mode.furniture {
                pinView.isHidden = true
            } else {
                pinView.isHidden = false
            }
        }
    }
    
    // MARK: - UI Elements
    
    var spinner: UIActivityIndicatorView?
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messagePanel: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var addObjectButton: UIButton!
    @IBOutlet weak var restartExperienceButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var pinView: UIView!
    
    // MARK: - Queue
    
	let updateQueue = DispatchQueue(label: "serialSceneKitQueue")
	
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUIControls()
        setupScene()
        setupSCNTechnique()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true

		if ARWorldTrackingConfiguration.isSupported {
			// Start the ARSession.
			resetTracking()
		} else {
			// This device does not support 6DOF world tracking.
			let sessionErrorMsg = "This app requires world tracking. World tracking is only available on iOS devices with A9 processor or newer. " +
			"Please quit the application."
			displayErrorMessage(title: "Unsupported platform", message: sessionErrorMsg, allowRestart: false)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
        print("ViewController viewWillDisappear")
		super.viewWillDisappear(animated)
		session.pause()
	}
	
    // MARK: - Setup
    
    func setupUIControls() {
        textManager = TextManager(viewController: self)
        
        // Set appearance of message output panel
        messagePanel.layer.cornerRadius = 3.0
        messagePanel.clipsToBounds = true
        messagePanel.isHidden = true
        messageLabel.text = ""
        
        // set pinView. it is circle for setting pin
        pinView.layer.cornerRadius = 3.0
        pinView.clipsToBounds = true
        pinView.isHidden = true
        
        // hide navi bar
        self.navigationController?.isNavigationBarHidden = true
    }
    
	func setupScene() {
        // Synchronize updates via the `serialQueue`.
        virtualObjectManager = VirtualObjectManager(updateQueue: updateQueue)
        virtualObjectManager.delegate = self
		
        verticalPlaneDetector = VerticalPlaneDetector(sceneView: sceneView)
        verticalPlaneDetector.delegate = self
		// set up scene view
		sceneView.setup()
		sceneView.delegate = self
		sceneView.session = session
        
        sceneView.scene.rootNode.addChildNode(dtRootNode)
        /* debuging options */
//         sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // sceneView.showsStatistics = true
		
		sceneView.scene.enableEnvironmentMapWithIntensity(25)
		setupFocusSquare()
		
        // ttt
        startTimer()
        
        self.screenCenter = self.sceneView.bounds.mid
	}
    
    func setupSCNTechnique() {
        guard let path = Bundle.main.path(forResource: "NodeTechnique", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) else {
            return
        }
        
        let dict2 = dict as! [String: AnyObject]
        let technique = SCNTechnique(dictionary:dict2)
        sceneView.technique = technique
    }
	
    // MARK: - Gesture Recognizers
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesBegan(touches, with: event, in: self.sceneView)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesMoved(touches, with: event)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesEnded(touches, with: event)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesCancelled(touches, with: event)
	}
	
    // MARK: - Planes
	
	var planes = [ARPlaneAnchor: Plane]()
	
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        let plane = Plane(anchor)
		planes[anchor] = plane
        
		node.addChildNode(plane)
		
		textManager.cancelScheduledMessage(forType: .planeEstimation)
		textManager.showMessage("평면 감지 완료")
		if virtualObjectManager.virtualObjects.isEmpty {
			textManager.scheduleMessage("+ 버튼을 눌러 물체를 배치하세요", inSeconds: 7.5, messageType: .contentPlacement)
		}
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
        // 세션이 처음 실행될 때에는 옵션 효과는 없음.
        session.run(worldTrackingConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
		textManager.scheduleMessage("물체를 배치하기 위해서 표면을 감지해야 합니다.",
		                            inSeconds: 7.5,
		                            messageType: .planeEstimation)
	}

    // MARK: - Focus Square
    
    var focusSquare: FocusSquare?
	
    func setupFocusSquare() {
        updateQueue.async {
            self.focusSquare?.isHidden = true
            self.focusSquare?.removeFromParentNode()
            self.focusSquare = FocusSquare()
            self.sceneView.scene.rootNode.addChildNode(self.focusSquare!)
        }
        
		textManager.scheduleMessage("카메라를 좌우로 이동해주세요", inSeconds: 5.0, messageType: .focusSquare)
    }
	
	func updateFocusSquare() {
		guard let screenCenter = screenCenter else { return }
		
		DispatchQueue.main.async {
            var objectVisible = false
            for object in self.virtualObjectManager.virtualObjects {
                if self.sceneView.isNode(object, insideFrustumOf: self.sceneView.pointOfView!) {
                    objectVisible = true
                    break
                }
            }

            if objectVisible { self.focusSquare?.hide() }
            else { self.focusSquare?.unhide() }
			
            let (worldPos, planeAnchor, _)
                = self.virtualObjectManager.worldPositionFromScreenPosition(screenCenter,
                                                                            in: self.sceneView)
			if let worldPos = worldPos {
                self.updateQueue.async {
                    self.focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
                }
				self.textManager.cancelScheduledMessage(forType: .focusSquare)
			}
		}
	}
    
	// MARK: - Error handling
    
	func displayErrorMessage(title: String, message: String, allowRestart: Bool = false) {
		// Blur the background.
		textManager.blurBackground()
		
		if allowRestart {
			// Present an alert informing about the error that has occurred.
			let restartAction = UIAlertAction(title: "Reset", style: .default) { _ in
				self.textManager.unblurBackground()
				self.restartExperience(self)
			}
			textManager.showAlert(title: title, message: message, actions: [restartAction])
		} else {
			textManager.showAlert(title: title, message: message, actions: [])
		}
	}
    
}
