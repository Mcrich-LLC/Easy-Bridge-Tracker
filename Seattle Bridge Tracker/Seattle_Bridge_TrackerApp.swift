//
//  Seattle_Bridge_TrackerApp.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import SwiftUI
import Mcrich23_Toolkit
import GoogleMobileAds
import Firebase

@main
struct Seattle_Bridge_TrackerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.Message_ID"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Utilities.getAppType()
        NetworkMonitor.shared.startMonitoring()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        FirebaseApp.configure()
        setupFPN(application: application)
        Utilities.fetchRemoteConfig()
        Analytics.setUserProperty(Utilities.appType.rawValue, forName: "application_type")
        Analytics.logEvent("set_application_type", parameters: ["application_type" : Utilities.appType.rawValue])
        return true
    }
}
