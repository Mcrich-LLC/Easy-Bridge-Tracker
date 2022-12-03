//
//  Utilities.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 8/21/22.
//

import Foundation

class Utilities {
    static let isFastlaneRunning = UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
    static var areAdsDisabled = UserDefaults.standard.bool(forKey: "adsDisabled")
    static var appType = AppConfiguration.AppStore
    
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
