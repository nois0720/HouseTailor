//
//  ViewController+GestureReconizer.swift
//  HouseTailor
//
//  Created by Yoo Seok Kim on 2017. 10. 13..
//  Copyright © 2017년 Nois. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches began")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches moved")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches ended")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches cancelled")
    }
}
