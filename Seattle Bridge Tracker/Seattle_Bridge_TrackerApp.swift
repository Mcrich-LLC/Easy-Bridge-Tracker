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
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        print("Active")
                        UNUserNotificationCenter.current().getNotificationSettings { setting in
                            DispatchQueue.main.async {
                                if setting.authorizationStatus == .authorized {
                                    NotificationPreferencesModel.shared.notificationsAllowed = true
                                } else {
                                    NotificationPreferencesModel.shared.notificationsAllowed = false
                                }
                            }
                        }
                    } else if newPhase == .inactive {
                        print("Inactive")
                    } else if newPhase == .background {
                        print("Background")
                    }
                }
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
        if Utilities.isFastlaneRunning {
            AdController.shared.areAdsDisabled = true
        }
        if UserDefaults.standard.string(forKey: "deviceID") == nil || UserDefaults.standard.string(forKey: "deviceID")?.isEmpty {
            let deviceID = UUID()
            UserDefaults.standard.setValue(deviceID.uuidString, forKey: "deviceID")
            Utilities.deviceID = deviceID.uuidString
        }
        return true
    }
}
