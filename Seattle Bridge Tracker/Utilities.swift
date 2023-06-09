//
//  Utilities.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 8/21/22.
//

import Foundation
import SwiftUI
import Firebase
import Mcrich23_Toolkit

class Utilities {
    static let isFastlaneRunning = UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
    static var appType = AppConfiguration.AppStore
    static var remoteConfig: RemoteConfig!
    static var deviceID = UserDefaults.standard.string(forKey: "deviceID")
    
    static func handleRemoteConfigLoaded() {
        PurchaseService.shared.config()
    }
    
    static func fetchRemoteConfig() {
        print("refreshing")
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        if Utilities.appType == .Debug {
            settings.minimumFetchInterval = 0
        } else {
            settings.minimumFetchInterval = 43200 // 12 hours
        }
        print("min fetch interval = \(settings.minimumFetchInterval)")
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        remoteConfig.fetchAndActivate { status, error in
            if status == .successFetchedFromRemote {
                print("fetched from remote, \(String(describing: remoteConfig))")
                handleRemoteConfigLoaded()
            } else if status == .successUsingPreFetchedData {
                print("fetched locally, \(String(describing: remoteConfig))")
                handleRemoteConfigLoaded()
            } else if status == .error {
                print("error fetching = \(String(describing: error))")
                handleRemoteConfigLoaded()
            }
        }
        print("remote config = \(String(describing: remoteConfig))")
    }
    
    static func checkNotificationPermissions(completion: @escaping (_ notificationsAreAllowed: Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            DispatchQueue.main.async {
                if setting.authorizationStatus == .authorized {
                    NotificationPreferencesModel.shared.notificationsAllowed = true
                    completion(true)
                } else {
                    NotificationPreferencesModel.shared.notificationsAllowed = false
                    SwiftUIAlert.show(title: "Uh Oh", message: "Notifications are disabled. Please enable them in settings.", preferredStyle: .alert, actions: [UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive) { _ in
                        // continue your work
                        completion(false)
                    }, UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings)
                        }
                        completion(false)
                    })])
                }
            }
        }
    }
    
    enum AppConfiguration: String {
      case Debug
      case TestFlight
      case AppStore
    }
    struct Config {
      // This is private because the use of 'appConfiguration' is preferred.
      private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
      
      // This can be used to add debug statements.
      static var isDebug: Bool {
        #if DEBUG
          return true
        #else
          return false
        #endif
      }

      static var appConfiguration: AppConfiguration {
        if isDebug {
          return .Debug
        } else if isTestFlight {
          return .TestFlight
        } else {
          return .AppStore
        }
      }
    }
    static func getAppType() {
      switch (Config.appConfiguration) {
      case .Debug:
          Utilities.appType = .Debug
      case .TestFlight:
          Utilities.appType = .TestFlight
      default:
          Utilities.appType = .AppStore
      }
        print("App Type: \(Utilities.appType)")
    }

}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func condition<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
