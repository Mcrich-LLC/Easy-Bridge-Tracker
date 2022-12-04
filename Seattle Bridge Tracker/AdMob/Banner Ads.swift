//
//  Banner Ads.swift
//  
//
//  Created by Morris Richman on 8/20/22.
//

import Foundation
import SwiftUI
import GoogleMobileAds
import Shimmer

struct BannerViewController: UIViewControllerRepresentable {
    
    let adUnitID: String = Utilities.remoteConfig["GADBannerAdID"].stringValue!
    
    var finishedLoading: () -> Void = {}
    var startLoading: () -> Void = {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(bannerViewController: self)
    }
    
    init() {}
    
    init(startLoading: @escaping () -> Void, finishedLoading: @escaping () -> Void) {
        self.startLoading = startLoading
        self.finishedLoading = finishedLoading
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        self.startLoading()
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        let viewController = UIViewController()
        banner.delegate = context.coordinator
        banner.adUnitID = adUnitID
        banner.rootViewController = viewController
        banner.load(GADRequest())
        
        if !Utilities.isFastlaneRunning && !Utilities.areAdsDisabled {
            viewController.view.addSubview(banner)
            viewController.view.backgroundColor = .clear
            viewController.view.frame = CGRect(origin: .zero, size: GADAdSizeBanner.size)
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    class Coordinator: NSObject, GADBannerViewDelegate {
        
        var bannerViewController: BannerViewController
        
        init(bannerViewController: BannerViewController) {
            self.bannerViewController = bannerViewController
        }
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("banner failed to show! Error: \(String(describing: error))")
            bannerViewController.startLoading()
        }
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            
        }
        func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
            bannerViewController.finishedLoading()
        }
    }
}

struct BannerAds: View {
    @State var shimmering = true
    var body: some View {
        if !Utilities.isFastlaneRunning && !Utilities.areAdsDisabled {
            ZStack {
                if shimmering {
                Rectangle()
                    .shimmering(active: true, duration: 0.75, bounce: false)
                    .frame(height: 50)
                    .onDisappear {
                        print("stopped shimmering")
                    }
            }
                BannerViewController(startLoading: {
                    DispatchQueue.main.async {
                        shimmering = true
                    }
                }, finishedLoading: {
                    shimmering = false
                })
                    .frame(height: 50)
            }
        }
    }
}
