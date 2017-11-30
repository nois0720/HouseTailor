/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Wrapper SceneKit node for virtual objects placed into the AR scene.
*/

import Foundation
import SceneKit
import ARKit

struct VirtualObjectDefinition: Codable, Equatable {
    let modelName: String
    let displayName: String
    
    init(modelName: String, displayName: String) {
        self.modelName = modelName
        self.displayName = displayName
    }
    
    static func ==(lhs: VirtualObjectDefinition, rhs: VirtualObjectDefinition) -> Bool {
        return lhs.modelName == rhs.modelName
            && lhs.displayName == rhs.displayName
    }
}

class VirtualObject: SCNReferenceNode {
    let definition: VirtualObjectDefinition
    var frame: VirtualObjectFrame?
    
    init(definition: VirtualObjectDefinition, frame: VirtualObjectFrame? = nil) {
        self.definition = definition
        self.frame = frame
        
        guard let url = Bundle.main.url(forResource: "Models.scnassets/\(definition.modelName)/\(definition.modelName)", withExtension: "scn")
            else { fatalError("can't find expected virtual object bundle resources") }
        super.init(url: url)!
        
        self.name = "\(definition.modelName) reference node"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Use average of recent virtual object distances to avoid rapid changes in object scale.
    var recentVirtualObjectDistances = [Float]()
    
    func setFrame(frame: VirtualObjectFrame) {
        self.frame = frame
        self.addChildNode(frame)
    }
}

extension VirtualObject {
	
	static func isNodePartOfVirtualObject(_ node: SCNNode) -> VirtualObject? {
		if let virtualObjectRoot = node as? VirtualObject {
			return virtualObjectRoot
		}
		
		if node.parent != nil {
			return isNodePartOfVirtualObject(node.parent!)
		}
		
		return nil
	}
    
}

