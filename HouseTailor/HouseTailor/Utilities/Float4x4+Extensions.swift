//
//  Float4x4+Extension.swift
//  HouseTailor
//
//  Created by Yoo Seok Kim on 2017. 10. 13..
//  Copyright © 2017년 Nois. All rights reserved.
//

import ARKit

extension float4x4 {
    /// Treats matrix as a (right-hand column-major convention) transform matrix
    /// and factors out the translation component of the transform.
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
