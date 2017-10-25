/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Convenience extensions on ARSCNView for hit testing
*/

import ARKit

extension ARSCNView {
    
    func setup() {
        automaticallyUpdatesLighting = false
        
        preferredFramesPerSecond = 60
        contentScaleFactor = 2.0
        
        if let camera = pointOfView?.camera {
            camera.automaticallyAdjustsZRange = true
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
            camera.maximumExposure = 3
        }
    }
}
