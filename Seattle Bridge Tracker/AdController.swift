//
//  AdController.swift
//  Pickt
//
//  Created by Morris Richman on 12/19/22.
//

import Foundation

class AdController: ObservableObject {
    static var shared = AdController()
    @Published var areAdsDisabled = UserDefaults.standard.bool(forKey: "adsDisabled") && Utilities.isFastlaneRunning {
        didSet {
            UserDefaults.standard.set(areAdsDisabled, forKey: "adsDisabled")
        }
    }
}
