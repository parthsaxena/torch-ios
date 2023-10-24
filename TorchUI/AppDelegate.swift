//
//  AppDelegate.swift
//  TorchUI
//
//  Created by Parth Saxena on 7/6/23.
//

import Foundation
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Initialize Google Maps SDK
        GMSServices.provideAPIKey("AIzaSyBevmebTmlyD-kftwvRqqRItgh07CDiwx0")
        
        RunLoop.current.run(until: NSDate(timeIntervalSinceNow:2) as Date)
        
        return true
    }
}
