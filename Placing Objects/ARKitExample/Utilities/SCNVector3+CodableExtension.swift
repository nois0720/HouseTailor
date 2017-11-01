//
//  Codable+Extension.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 10. 30..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit

extension SCNVector3: Codable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
        case z
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(z, forKey: .z)
    }
    
    public init(from decoder: Decoder) throws {
        let vector3 = try decoder.container(keyedBy: CodingKeys.self)
        let x: Float = try vector3.decode(Float.self, forKey: .x)
        let y: Float = try vector3.decode(Float.self, forKey: .y)
        let z: Float = try vector3.decode(Float.self, forKey: .z)

        self.init(x, y, z)
    }
}
