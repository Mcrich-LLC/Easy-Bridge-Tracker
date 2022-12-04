//
//  Utilities.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 8/21/22.
//

import Foundation
import Firebase

class Utilities {
    static let isFastlaneRunning = UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
    static var areAdsDisabled = UserDefaults.standard.bool(forKey: "adsDisabled")
    static var appType = AppConfiguration.AppStore
    static var remoteConfig: RemoteConfig!
    
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
            } else if status == .successUsingPreFetchedData {
                print("fetched locally, \(String(describing: remoteConfig))")
            } else if status == .error {
                print("error fetching = \(String(describing: error))")
            }
        }
        print("remote config = \(String(describing: remoteConfig))")
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
