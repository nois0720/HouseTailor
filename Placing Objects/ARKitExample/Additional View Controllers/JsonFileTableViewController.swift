//
//  JsonFileTableViewController.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 31..
//  Copyright © 2017년 Apple. All rights reserved.
//

import UIKit

// MARK: - FloorPlanSelectDelegate

protocol FloorPlanSelectDelegate: class {
    func floorPlanSelect(didSelectDefinition definition: FloorPlanDefinition)
}


class JsonFileTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: FloorPlanSelectDelegate?
    private var floorPlanDefinitions: [FloorPlanDefinition] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Load Logic
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("FloorPlans.json")
        
            let data = try Data(contentsOf: fileURL)
            self.floorPlanDefinitions = try JSONDecoder().decode([FloorPlanDefinition].self, from: data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
}

extension JsonFileTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let definition = floorPlanDefinitions[indexPath.row]
        
        let alertController = UIAlertController(title: definition.name,
                                                message: "해당 평면도를 불러오시겠습니까?",
                                                preferredStyle: .alert)
        
        let discardAction = UIAlertAction(title: "취소",
                                          style: .destructive,
                                          handler: nil)
        
        let saveAction = UIAlertAction(title: "확인",
                                       style: .default,
                                       handler: { (action) in
                                        if let navigationController = self.navigationController {
                                            navigationController.popViewController(animated: true)
                                            self.delegate?.floorPlanSelect(didSelectDefinition: definition)
                                        } else {
                                            self.dismiss(animated: true, completion: nil)
                                            self.delegate?.floorPlanSelect(didSelectDefinition: definition)
                                        }
        })
        
        alertController.addAction(discardAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.floorPlanDefinitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = floorPlanDefinitions[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
}
