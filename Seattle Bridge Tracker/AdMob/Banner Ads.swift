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

final class BannerViewController: UIViewControllerRepresentable {
    
    let adUnitID: String = "ca-app-pub-8092077340719182/1348152099"
    
    func makeCoordinator() -> Coordinator {
        Coordinator(bannerViewController: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
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
        }
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            
        }
    }
}

struct BannerAds: View {
    var body: some View {
        if !Utilities.isFastlaneRunning && !Utilities.areAdsDisabled {
            ZStack {
                Rectangle()
                    .background(.white)
                    .shimmering(active: true, duration: 0.75, bounce: false)
                    .frame(width: 320, height: 50)
                BannerViewController()
                    .frame(width: 320, height: 50)
            }
        }
    }
}
