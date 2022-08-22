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
}
