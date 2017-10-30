/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Empty application delegate class.
*/

import ARKit
import CoreMotion
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
    let motionManager = CMMotionManager()
    var timer = Timer()
    var velocity = SCNVector3(0, 0, 0)
    var offsetVector = SCNVector3(0, 0, 0)
    var vector = SCNVector3(0, 0, 0)

    var backgroundTask: UIBackgroundTaskIdentifier!
    
    func doBackgroundTask() {
        beginBackgroundTask()
        
//        let queue = DispatchQueue.global(qos: .background)
//
//        queue.async {
//            self.endBackgroundTask()
//        }
    }
    
    func beginBackgroundTask() {
        motionManager.startDeviceMotionUpdates()
        motionManager.startAccelerometerUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startGyroUpdates()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(motion), userInfo: nil, repeats: true)
        
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "bgTask") {
            self.endBackgroundTask()
        }
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopMagnetometerUpdates()
        motionManager.stopGyroUpdates()
        
        timer.invalidate()
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    @objc func motion() {
        if let deviceMotion = motionManager.deviceMotion {
            // d = (1/2) * a * t^2
            print(deviceMotion)
            
//            let dist = SCNVector3(deviceMotion.userAcceleration.x,
//                                   deviceMotion.userAcceleration.y,
//                                   deviceMotion.userAcceleration.z)
//
//            offsetVector += dist
//            deviceMotion.userAcceleration.x
//            deviceMotion.userAcceleration.y
//            deviceMotion.userAcceleration.z
//            print(deviceMotion)
        }
        
        if let gyroData = motionManager.gyroData {
            print(gyroData.rotationRate)
        }
        
        if let accelerometerData = motionManager.accelerometerData {
            print(accelerometerData.acceleration)
        }
        
        if let magnetometerData = motionManager.magnetometerData {
            print(magnetometerData.magneticField)
        }
        
        print("motion.")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        doBackgroundTask()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        endBackgroundTask()
        print(offsetVector)
    }
}
