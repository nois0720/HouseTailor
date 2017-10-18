//
//  ModeSelectionViewController.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 18..
//  Copyright © 2017년 Apple. All rights reserved.
//

import UIKit

// MARK: - ObjectCell

class ModeCell: UITableViewCell {
    
    static let reuseIdentifier = "ModeCell"
    @IBOutlet weak var modeNameLabel: UILabel!
}

// MARK: - VirtualObjectSelectionViewControllerDelegate

protocol ModeSelectionViewControllerDelegate: class {
    func modeSelectionViewController(_: ModeSelectionViewController, didSelectModeAt index: Int)
}

class ModeSelectionViewController: UITableViewController {
    
    weak var delegate: ModeSelectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 130, height: tableView.contentSize.height)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.modeSelectionViewController(self, didSelectModeAt: indexPath.row)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ModeCell.reuseIdentifier, for: indexPath) as? ModeCell else {
            fatalError("Expected `ObjectCell` type for reuseIdentifier \(ModeCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        
        var text = ""
        switch indexPath.row {
        case 0:
            text = "Furniture"
        case 1:
            text = "Measure"
        default:
            text = "nil"
        }
        
        cell.modeNameLabel.text = text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
    
}
