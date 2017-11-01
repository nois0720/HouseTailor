//
//  GridView.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 25..
//  Copyright © 2017년 Apple. All rights reserved.
//

import UIKit

class GridView: UIView {
    
    override init(frame: CGRect) {
        let gridFrame = CGRect(x: 0, y: 0, width: 750, height: 1336)
        
        super.init(frame: gridFrame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not benn implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2.0)
        let strokeColor = UIColor.white.cgColor
        context?.setStrokeColor(strokeColor)
        
        for i in 1...28 {
            let multiflier = CGFloat(i / 2)
            var offset: CGFloat = 50.0 * multiflier
            if i % 2 == 1 { offset = offset * -1 }
            
            context?.move(to: CGPoint(x: 0, y: rect.size.height / 2 + offset))
            context?.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height / 2 + offset))
            context?.move(to: CGPoint(x: rect.size.width / 2 + offset, y: 0))
            context?.addLine(to: CGPoint(x: rect.size.width / 2 + offset, y: rect.size.height))
        }
        context?.strokePath()
    }
    
}
