//
//  FloorPlanViewController.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 25..
//  Copyright © 2017년 Apple. All rights reserved.
//

import UIKit
import ARKit

struct FloorPlan: Codable {
    var virtualObjectPolygons: [Polygon] = []
    var floorPlanPolygon: Polygon
    
    init(floorPlanPolygon: Polygon, virtualObjectPolygons: [Polygon]? = nil) {
        if let virtualObjectPolygons = virtualObjectPolygons {
            self.virtualObjectPolygons = virtualObjectPolygons
        }
        self.floorPlanPolygon = floorPlanPolygon
    }
}

class FloorPlanViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var floorPlaneView: UIView!
    
    var floorPlan: FloorPlan!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.minimumZoomScale = 0.5
        self.scrollView.maximumZoomScale = 3.0
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.contentSize = CGSize(width: 750, height: 1336)
        self.scrollView.delegate = self
        
        floorPlaneView.addSubview(GridView(frame: view.frame))
        
//        // for device test
//        drawPolygon(polygon: floorPlanPolygon)
//        virtualObjectPolygons.forEach {
//            drawPolygonWithRandomColor(polygon: $0)
//        }
        // for simulator
        let line1 = Line(startNodePos: SCNVector3(3.2, 0, 0.4), endNodePos: SCNVector3(0.2, 0, 5.8))
        let line2 = Line(startNodePos: SCNVector3(0.2, 0, 5.8), endNodePos: SCNVector3(-1.5, 0, -1.8))
        let line3 = Line(startNodePos: SCNVector3(-1.5, 0, -1.8), endNodePos: SCNVector3(4.5, 0, -0.2))
        let line4 = Line(startNodePos: SCNVector3(4.5, 0, -0.2), endNodePos: SCNVector3(3.2, 0, 0.4))
        let lines: [Line] = [line1, line2, line3, line4]
        let polygon = Polygon(lines: lines)

        floorPlan = FloorPlan(floorPlanPolygon: polygon)
        draw(polygon: polygon)
    }
    
    // Mark: -Actions
    
    @IBAction func backToMain(_ button: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func exportJson(_ button: UIButton) {
        let jsonEncoder = JSONEncoder()
        
        do {
            let data = try jsonEncoder.encode(floorPlan)
            print(data)
        } catch {
            
        }
        
//        jsonEncoder.encode(<#T##value: Encodable##Encodable#>)
    }
    
    func draw(polygon: Polygon) {
        func drawLengthTextLabel() {
            polygon.lengthTexts.forEach {
                let textLabel: UILabel = .init(frame: CGRect(x: $0.pos.x, y: $0.pos.y, width: 80, height: 30))
                textLabel.text = String(format: "%.2fm", $0.length / 100)
                textLabel.textAlignment = .left
                floorPlaneView.addSubview(textLabel)
            }
        }
        
        let shape = CAShapeLayer()
        floorPlaneView.layer.addSublayer(shape)
        
        shape.lineWidth = 2
        shape.opacity = 0.9
        shape.lineJoin = kCALineJoinMiter
        shape.strokeColor = UIColor(red: 1, green: 0.7, blue: 0, alpha: 0.8).cgColor
        shape.fillColor = UIColor(red: 0.3, green: 0.52, blue: 0.6, alpha: 1).cgColor
        
        let path = UIBezierPath()
        
        path.move(to: polygon.startPoint)
        polygon.movePoints.forEach { path.addLine(to: $0) }
        path.close()
        shape.path = path.cgPath
        
        drawLengthTextLabel()
    }
    
    func drawPolygonWithRandomColor(polygon: Polygon) {
        func drawLengthTextLabel() {
            polygon.lengthTexts.forEach {
                let textLabel: UILabel = .init(frame: CGRect(x: $0.pos.x, y: $0.pos.y, width: 80, height: 30))
                
                textLabel.text = String(format: "%.2fm", $0.length / 100)
                textLabel.textAlignment = .left
                floorPlaneView.addSubview(textLabel)
            }
        }
        
        let shape = CAShapeLayer()
        floorPlaneView.layer.addSublayer(shape)
        
        shape.lineWidth = 1
        shape.opacity = 0.9
        shape.lineJoin = kCALineJoinMiter
        
        shape.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        shape.fillColor = UIColor(red: CGFloat(arc4random()) / CGFloat(UINT32_MAX), green: CGFloat(arc4random()) / CGFloat(UINT32_MAX), blue: CGFloat(arc4random()) / CGFloat(UINT32_MAX), alpha: 1.0).cgColor
        
        let path = UIBezierPath()
        
        path.move(to: polygon.startPoint)
        polygon.movePoints.forEach { path.addLine(to: $0) }
        path.close()
        shape.path = path.cgPath
        
        drawLengthTextLabel()
    }
}

extension FloorPlanViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return floorPlaneView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("zoom")
    }
}
