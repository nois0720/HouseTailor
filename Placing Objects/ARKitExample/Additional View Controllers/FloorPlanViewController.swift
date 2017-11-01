//
//  FloorPlanViewController.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 25..
//  Copyright © 2017년 Apple. All rights reserved.
//

import UIKit
import ARKit

// MARK: - FloorPlanSelectDelegate

protocol Load3DFloorPlanDelegate: class {
    func load3DFloorPlan(didSelectDefinition definition: FloorPlanDefinition)
}

class FloorPlanViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var floorPlaneView: UIView!
    
    var layerArray = NSMutableArray()
    var floorPlan: FloorPlan?
    var delegate: Load3DFloorPlanDelegate?
    
    private var floorPlanDefinitions: [FloorPlanDefinition] = []
    
    private let fileManager = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // for test
//        inputTestData()
        
        loadJson()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        removeFloorPlanUI()
        // Load Logic
        if let floorPlan = self.floorPlan { floorPlan.draw(on: floorPlaneView, with: layerArray) }

        // draw FloorPlan on view
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        print("viewDidDisappear")
//
//        removeFloorPlanUI()
//    }
    
    // Mark: -Actions
    
    @IBAction func backToMain(_ button: UIButton) {
        if let floorPlanDefinition = floorPlan?.floorPlanDefinition {
            delegate?.load3DFloorPlan(didSelectDefinition: floorPlanDefinition)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    var textField: UITextField?
    
    @IBAction func exportJson(_ button: UIButton) {
        let alertController = UIAlertController(title: nil,
                                                message: "평면도의 이름을 작성해주세요",
                                                preferredStyle: .alert)
        
        let discardAction = UIAlertAction(title: "취소",
                                          style: .destructive,
                                          handler: nil)
        
        let saveAction = UIAlertAction(title: "저장",
                                       style: .default,
                                       handler: { [weak self] (action) in
                                        self?.writeFile(name: self?.textField?.text ?? "no name")
        })
        
        alertController.addTextField(configurationHandler: { (textField) in
            self.textField = textField
        })
        
        alertController.addAction(discardAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func writeFile(name: String) {
        guard floorPlan?.floorPlanDefinition != nil else { return }
        
        let jsonEncoder = JSONEncoder()
        
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("FloorPlans.json")
            
            floorPlan!.floorPlanDefinition.name = name
            self.floorPlanDefinitions.append(floorPlan!.floorPlanDefinition)
            
            try jsonEncoder.encode(floorPlanDefinitions).write(to: fileURL)
            
            let alertController = UIAlertController(title: nil,
                                                    message: "저장이 완료되었습니다",
                                                    preferredStyle: .alert)
            
            let completeAction = UIAlertAction(title: "완료",
                                           style: .default,
                                           handler: nil)
            
            alertController.addAction(completeAction)
            self.present(alertController, animated: true, completion: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
}


// Setup codes
extension FloorPlanViewController {
    func setupUI() {
        self.scrollView.minimumZoomScale = 0.5
        self.scrollView.maximumZoomScale = 3.0
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.contentSize = CGSize(width: 750, height: 1336)
        self.scrollView.delegate = self
        
        floorPlaneView.addSubview(GridView(frame: view.frame))
    }
    
    func inputTestData() {
        // dummy data for test
        let p1 = SCNVector3(3.2, 0, 0.4)
        let p2 = SCNVector3(0.2, 0, 5.8)
        let p3 = SCNVector3(-1.5, 0, -1.8)
        let p4 = SCNVector3(4.5, 0, -0.2)
        
        self.floorPlan = FloorPlan(floorPlanVectors: [p1, p2, p3, p4])
    }
    
    func loadJson() {
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("FloorPlans.json")
            
            guard fileManager.fileExists(atPath: fileURL.path) else { return }
            
            let data = try Data(contentsOf: fileURL)
            self.floorPlanDefinitions = try JSONDecoder().decode([FloorPlanDefinition].self, from: data)
        } catch {
            fatalError("Unable to decode VirtualObjects JSON: \(error)")
        }
    }
    
    func removeFloorPlanUI() {
        floorPlaneView.layer.sublayers?.forEach {
            if layerArray.contains($0) {
                $0.removeFromSuperlayer()
                layerArray.remove($0)
            }
        }
        
        layerArray.forEach {
            if let view = $0 as? UIView {
                view.removeFromSuperview()
            }
        }
        
        layerArray.removeAllObjects()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination.navigationController?.childViewControllers.first
            as? JsonFileTableViewController{
            vc.delegate = self
        }
        
        if let vc = segue.destination as? JsonFileTableViewController {
            print("for no naviController test")
            vc.delegate = self
        }
    }
}

extension FloorPlanViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return floorPlaneView
    }
}

extension FloorPlanViewController: FloorPlanSelectDelegate {
    func floorPlanSelect(didSelectDefinition definition: FloorPlanDefinition) {
        print("floorPlanSelectDelegate: didSelectDefinition")
        self.floorPlan = FloorPlan(definition: definition)
    }
}
