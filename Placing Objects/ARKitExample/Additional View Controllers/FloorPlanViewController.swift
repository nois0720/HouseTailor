//
//  FloorPlanViewController.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 25..
//  Copyright © 2017년 Apple. All rights reserved.
//

import UIKit

class FloorPlanViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var floorPlaneView: UIView!
    var polygon: Polygon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 3.0
        self.scrollView.contentSize = CGSize(width: 1280, height: 960)
        self.scrollView.delegate = self
        
        let shape = CAShapeLayer()
        floorPlaneView.addSubview(GridView(frame: view.frame))
        floorPlaneView.layer.addSublayer(shape)
        
        shape.lineWidth = 2
        shape.opacity = 0.9
        shape.lineJoin = kCALineJoinMiter
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor(red: 0.3, green: 0.52, blue: 0.6, alpha: 1).cgColor

        let path = UIBezierPath()

        path.move(to: polygon.startPoint)
        polygon.movePoints.forEach { path.addLine(to: $0) }
        path.close()
        shape.path = path.cgPath
        
        // for simulator
//        shape.lineWidth = 2
//        shape.opacity = 0.9
//        shape.lineJoin = kCALineJoinMiter
//        shape.strokeColor = UIColor.black.cgColor
//        shape.fillColor = UIColor(red: 0.3, green: 0.52, blue: 0.6, alpha: 1).cgColor
//
//        let path = UIBezierPath()
//
//        path.move(to: CGPoint(x: 100, y: 160))
//        path.addLine(to: CGPoint(x: 300, y: 160))
//        path.addLine(to: CGPoint(x: 300, y: 450))
//        path.addLine(to: CGPoint(x: 160, y: 470))
//        path.close()
//        shape.path = path.cgPath
    }
    
    @IBAction func backToMain(_ button: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension FloorPlanViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return floorPlaneView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("zoom")
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        print("scroll to top")
    }
}
