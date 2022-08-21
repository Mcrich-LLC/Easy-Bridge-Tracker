//
//  Seattle_Bridge_TrackerApp.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import SwiftUI
import Mcrich23_Toolkit
import GoogleMobileAds

@main
struct Seattle_Bridge_TrackerApp: App {
    
    init() {
        NetworkMonitor.shared.startMonitoring()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .navigationViewStyle(.stack)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    BannerAds(adUnitID: "ca-app-pub-8092077340719182/1348152099", areAdsDisabled: false)
                }
            }
        }
    }
}
