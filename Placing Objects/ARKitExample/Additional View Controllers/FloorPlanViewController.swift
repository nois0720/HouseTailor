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
    var polygon: Polygon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.minimumZoomScale = 0.5
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.contentSize = CGSize(width: 1280, height: 960)
        self.scrollView.delegate = self
        
//        let shape = CAShapeLayer()
//        view.layer.addSublayer(shape)
//
//        shape.lineWidth = 2
//        shape.opacity = 0.8
//        shape.lineJoin = kCALineJoinMiter
//        shape.strokeColor = UIColor.black.cgColor
//        shape.fillColor = UIColor.blue.cgColor
//
//        let path = UIBezierPath()
//
//        path.move(to: polygon.startPoint)
//        polygon.movePoints.forEach { path.addLine(to: $0) }
//        path.close()
//        shape.path = path.cgPath
        
        let shape = CAShapeLayer()
        view.layer.addSublayer(shape)
        
        shape.lineWidth = 2
        shape.opacity = 0.8
        shape.lineJoin = kCALineJoinMiter
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.blue.cgColor
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 160, y: 300))
        path.addLine(to: CGPoint(x: 180, y: 300))
        path.addLine(to: CGPoint(x: 180, y: 320))
        path.addLine(to: CGPoint(x: 160, y: 320))
        path.close()
        shape.path = path.cgPath
    }
    
    @IBAction func backToMain(_ button: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension FloorPlanViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.view
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("zoom")
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        print("scroll to top")
    }
}
