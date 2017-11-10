//
//  HashFunction.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 8..
//  Copyright © 2017년 Apple. All rights reserved.
//

import Foundation

func hash_combine(seed: inout UInt, value: UInt) {
    let tmp = value &+ 0x9e3779b9 &+ (seed << 6) &+ (seed >> 2)
    seed ^= tmp
}
