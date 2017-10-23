/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility functions and type extensions used throughout the projects.
*/

import Foundation
import ARKit

// MARK: - Collection extensions
extension Array where Iterator.Element == Float {
	var average: Float? {
		guard !self.isEmpty else {
			return nil
		}
		
		let sum = self.reduce(Float(0)) { current, next in
			return current + next
		}
		return sum / Float(self.count)
	}
}

extension Array where Iterator.Element == float3 {
	var average: float3? {
		guard !self.isEmpty else {
			return nil
		}
        
        let sum = self.reduce(float3(0)) { current, next in
            return current + next
        }
		return sum / Float(self.count)
	}
}

extension RangeReplaceableCollection where IndexDistance == Int {
	mutating func keepLast(_ elementsToKeep: Int) {
		if count > elementsToKeep {
			self.removeFirst(count - elementsToKeep)
		}
	}
}

// MARK: - SCNNode extension

extension SCNNode {
	func setUniformScale(_ scale: Float) {
		self.simdScale = float3(scale, scale, scale)
	}
	
	func renderOnTop(_ enable: Bool) {
		self.renderingOrder = enable ? 2 : 0
		if let geom = self.geometry {
			for material in geom.materials {
				material.readsFromDepthBuffer = enable ? false : true
			}
		}
		for child in self.childNodes {
			child.renderOnTop(enable)
		}
	}
    
    func setCategoryBitMask(_ bitMask: Int) {
        if self.childNodes.count > 0 {
            self.childNodes.forEach ({ (node) in
                guard !(node.name == "shadowPlane") else { return }
                node.setCategoryBitMask(bitMask)
            })
        }
        self.categoryBitMask = bitMask
    }
}

// MARK: - float4x4 extensions

extension float4x4 {
    /// Treats matrix as a (right-hand column-major convention) transform matrix
    /// and factors out the translation component of the transform.
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

// MARK: - CGPoint extensions

extension CGPoint {
	
	init(_ size: CGSize) {
		self.x = size.width
		self.y = size.height
	}
	
	init(_ vector: SCNVector3) {
		self.x = CGFloat(vector.x)
		self.y = CGFloat(vector.y)
	}
	
	func distanceTo(_ point: CGPoint) -> CGFloat {
		return (self - point).length()
	}
	
	func length() -> CGFloat {
		return sqrt(self.x * self.x + self.y * self.y)
	}
	
	func midpoint(_ point: CGPoint) -> CGPoint {
		return (self + point) / 2
	}
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }
    
    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }
    
    static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / right, y: left.y / right)
    }
    
    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
    
    static func /= (left: inout CGPoint, right: CGFloat) {
        left = left / right
    }
    
    static func *= (left: inout CGPoint, right: CGFloat) {
        left = left * right
    }
}

// MARK: - CGSize extensions

extension CGSize {
	init(_ point: CGPoint) {
		self.width = point.x
		self.height = point.y
	}

    static func + (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width + right.width, height: left.height + right.height)
    }

    static func - (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width - right.width, height: left.height - right.height)
    }

    static func += (left: inout CGSize, right: CGSize) {
        left = left + right
    }

    static func -= (left: inout CGSize, right: CGSize) {
        left = left - right
    }

    static func / (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width / right, height: left.height / right)
    }

    static func * (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width * right, height: left.height * right)
    }

    static func /= (left: inout CGSize, right: CGFloat) {
        left = left / right
    }

    static func *= (left: inout CGSize, right: CGFloat) {
        left = left * right
    }
}

// MARK: - SCNVector3 extensions

extension SCNVector3 {
    
    init(_ vec: vector_float3) {
        self.x = vec.x
        self.y = vec.y
        self.z = vec.z
    }
    
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    mutating func setLength(_ length: Float) {
        self.normalize()
        self *= length
    }
    
    mutating func setMaximumLength(_ maxLength: Float) {
        if self.length() <= maxLength {
            return
        } else {
            self.normalize()
            self *= maxLength
        }
    }
    
    mutating func normalize() {
        self = self.normalized()
    }
    
    func normalized() -> SCNVector3 {
        if self.length() == 0 {
            return self
        }
        
        return self / self.length()
    }
    
    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    func friendlyString() -> String {
        return "(\(String(format: "%.2f", x)), \(String(format: "%.2f", y)), \(String(format: "%.2f", z)))"
    }
    
    func dot(_ vec: SCNVector3) -> Float {
        return (self.x * vec.x) + (self.y * vec.y) + (self.z * vec.z)
    }
    
    func cross(_ vec: SCNVector3) -> SCNVector3 {
        return SCNVector3(self.y * vec.z - self.z * vec.y, self.z * vec.x - self.x * vec.z, self.x * vec.y - self.y * vec.x)
    }
}

public let SCNVector3One: SCNVector3 = SCNVector3(1.0, 1.0, 1.0)

func SCNVector3Uniform(_ value: Float) -> SCNVector3 {
    return SCNVector3Make(value, value, value)
}

func SCNVector3Uniform(_ value: CGFloat) -> SCNVector3 {
    return SCNVector3Make(Float(value), Float(value), Float(value))
}

func distance(startNode: SCNNode, endNode: SCNNode) -> Float {
    let vector = SCNVector3Make(startNode.position.x - endNode.position.x, startNode.position.y - endNode.position.y, startNode.position.z - endNode.position.z)
    // Scene units map to meters in ARKit.
    return sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
}

func distance(startPos: SCNVector3, endPos: SCNVector3) -> Float {
    let vector = SCNVector3Make(startPos.x - endPos.x, startPos.y - endPos.y, startPos.z - endPos.z)
    // Scene units map to meters in ARKit.
    return sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
}

func lineSCNNode(from v1: SCNVector3, to v2: SCNVector3, color: UIColor = .black) -> SCNNode {
    let indices: [Int32] = [0, 1]
    let source = SCNGeometrySource(vertices: [v1, v2])
    let element = SCNGeometryElement(indices: indices, primitiveType: .line)
    
    let geometry = SCNGeometry(sources: [source], elements: [element])
    geometry.firstMaterial?.diffuse.contents = color
    
    let node = SCNNode(geometry: geometry)
    return node
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func += (left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

func -= (left: inout SCNVector3, right: SCNVector3) {
    left = left - right
}

func / (left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

func * (left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

func /= (left: inout SCNVector3, right: Float) {
    left = left / right
}

func *= (left: inout SCNVector3, right: Float) {
    left = left * right
}

// MARK: - CGRect extensions

extension CGRect {
	var mid: CGPoint {
		return CGPoint(x: midX, y: midY)
	}
}
