/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Configures the scene.
*/

import Foundation
import ARKit

// MARK: - Scene extensions

extension SCNScene {
	func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
        DispatchQueue.global().async {
			if self.lightingEnvironment.contents == nil {
				if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
					self.lightingEnvironment.contents = environmentMap
				}
			}
			self.lightingEnvironment.intensity = intensity
		}
	}
}
