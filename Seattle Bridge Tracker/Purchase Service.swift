//
//  Purchase Service.swift
//  Pickt
//
//  Created by Morris Richman on 1/2/22.
//

import Foundation
import RevenueCat
import Firebase
import FirebaseFirestore
import FirebaseAnalytics
import Mcrich23_Toolkit
import UIKit
import StoreKit
import Network

class PurchaseService {
    static let shared = PurchaseService()
    static var enabled = Utilities.remoteConfig["areIAPsEnabled"].boolValue
    private let db = Firestore.firestore()
    // MARK: Internal Functions
    private var networkMonitor = NetworkMonitor()
    private func isConnectedToInternet() -> Bool {
        if networkMonitor.isConnected {
            return true
        } else {
            SwiftUIAlert.show(
                title: NSLocalizedString("Uh Oh", comment: "Shown in not connected to internet alert"),
                message: NSLocalizedString("Your not connected to the internet, please reconnect before we continue.", comment: "Shown in not connected to internet alert"),
                preferredStyle: .alert,
                actions: [
                    UIAlertAction(
                        title: NSLocalizedString("Ok", comment: "Shown in not connected to internet alert"),
                        style: .default
                    )
                ]
            )
            return false
        }
    }
    private func removeAds() {
        AdController.shared.areAdsDisabled = true
        UserDefaults.standard.set(true, forKey: PurchaseService.Offerings.removeAds.rawValue)
    }
    private func getOfferings(completion: @escaping ([Package]) -> Void) {
        Purchases.shared.getOfferings { offerings, error in
            print("offerings = \(String(describing: offerings))")
            if let offerings = offerings {
                print("offerings = \(offerings)")
                guard let offer = offerings.current else {
                    completion([])
                    return
                }
                let packages = offer.availablePackages
                print("offer = \(String(describing: offer))")
                print("packages = \(String(describing: packages))")
                print("packages = \(String(describing: packages))")
                completion(packages)
            } else {
                print("RevenueCat Error = \(String(describing: error))")
                print("Error, doesn't work")
                SwiftUIAlert.show(
                    title: NSLocalizedString("Uh Oh", comment: "Shown in In App Purchases are not availble alert"),
                    message: NSLocalizedString("In App Purchases are not availble at this time.", comment: "Shown in In App Purchases are not availble alert"),
                    preferredStyle: .alert,
                    actions: [
                        UIAlertAction(
                            title: NSLocalizedString("Ok", comment: "Shown in In App Purchases are not availble alert"),
                            style: .default
                        )
                    ]
                )
            }
        }
    }
    private func diagnostics() async {
        do {
            try await PurchasesDiagnostics.default.testSDKHealth()
        } catch {
            print("RevenueCat Diagnostics Error = \(error)")
        }
    }
    private func configOfferings() {
        Purchases.shared.getOfferings { offerings, error in
            print("offerings = \(String(describing: offerings))")
            if let offerings = offerings {
                print("offerings = \(offerings)")
                guard let offer = offerings.current else {
                    return
                }
                let packages = offer.availablePackages
                print("offer = \(String(describing: offer))")
                print("packages = \(String(describing: packages))")
                print("packages = \(String(describing: packages))")
                for i in 0...packages.count - 1 {
                    
                    // Get a reference to the package
                    let package = packages[i]
                    print("package = \(package.identifier)")
                    if let offeringInfoIndex = OfferingInfo.offerings.firstIndex(where: { offering in
                        offering.id.rawValue == package.id
                    }) {
                        OfferingInfo.offerings[offeringInfoIndex].price = package.localizedPriceString
                        OfferingInfo.offerings[offeringInfoIndex].name = package.storeProduct.localizedTitle
                    }
                }
            } else {
                print("RevenueCat Error = \(String(describing: error))")
                print("Error, doesn't work")
            }
        }
    }
    // MARK: Public Functions
    static func checkIAPEnabled() -> Bool {
        print("IAPs = \(enabled)")
        if !enabled {
            // Create OK button with action handler
            SwiftUIAlert.show(title: NSLocalizedString("Uh Oh", comment: "Shown in In App Purchases are not availble alert"), message: NSLocalizedString("In App Purchases are not availble at this time.", comment: "Shown in In App Purchases are not availble alert"), preferredStyle: .alert, actions: [
                UIAlertAction(title: NSLocalizedString("Ok", comment: "Shown in In App Purchases are not availble alert"), style: .default, handler: { _ -> Void in
                    print("\"IAP Unavailible\" alert was dismised")
                })
            ])
            return false
        } else {
            return true
        }
    }
    enum Offerings: String, CaseIterable {
        case removeAds
    }
    func config() {
        PurchaseService.enabled = Utilities.remoteConfig["areIAPsEnabled"].boolValue
            Purchases.logLevel = .debug
            Purchases.configure(withAPIKey: Utilities.remoteConfig["revenueCatApiKey"].stringValue ?? "")
            Task {
                await diagnostics()
            }
        networkMonitor.startMonitoring { isConnected in
            if PurchaseService.enabled && isConnected {
                self.configOfferings()
            }
        }
    }
    func restore(completion: @escaping () -> Void) {
        if isConnectedToInternet() && PurchaseService.checkIAPEnabled() {
            Purchases.shared.restorePurchases { purchaserInfo, error in
                if error == nil {
                    print("Purchaser Info = \(purchaserInfo!)")
                    if purchaserInfo?.entitlements["removeAds"]?.isActive == true {
                        AdController.shared.areAdsDisabled = true
                        UserDefaults.standard.set(true, forKey: PurchaseService.Offerings.removeAds.rawValue)
                    }
                    SwiftUIAlert.show(
                        title: NSLocalizedString("Wooho!", comment: "Shown in restored purchases alert"),
                        message: NSLocalizedString("We restored your purchases!", comment: "Shown in restored purchases alert"),
                        preferredStyle: .alert,
                        actions: [
                            UIAlertAction(
                                title: NSLocalizedString("Done", comment: "Shown in restored purchases alert"),
                                style: .default
                            )
                        ]
                    )
                    completion()
                } else {
                    print("Error, \(error!)")
                    if "\(error!)" == "Error Domain=RCPurchasesErrorDomain Code=9 \"The receipt is missing.\" UserInfo={NSLocalizedDescription=The receipt is missing., readable_error_code=MISSING_RECEIPT_FILE}" {
                        SwiftUIAlert.show(
                            title: NSLocalizedString("Wooho!", comment: "Shown in restored purchases alert"),
                            message: NSLocalizedString("We restored your purchases!", comment: "Shown in restored purchases alert"),
                            preferredStyle: .alert,
                            actions: [
                                UIAlertAction(
                                    title: NSLocalizedString("Done", comment: "Shown in restored purchases alert"),
                                    style: .default
                                )
                            ]
                        )
                    } else {
                        self.reportError(function: "Restore Transactions", error: error!)
                        SwiftUIAlert.show(
                            title: NSLocalizedString("Unable to restore transactions", comment: "Shown in unable restored purchases alert"),
                            message: NSLocalizedString("Error: \(error!.localizedDescription)", comment: "Shown in unable restored purchases alert"),
                            preferredStyle: .alert,
                            actions: [
                                UIAlertAction(
                                    title: NSLocalizedString("Done", comment: "Shown in unable restored purchases alert"),
                                    style: .default
                                )
                            ]
                        )
                    }
                    completion()
                }
            }
        }
    }
    func purchase(offering: Offerings?, completion: @escaping (_ error: String) -> Void) {
        if isConnectedToInternet() && PurchaseService.checkIAPEnabled() {
            guard let offering = offering else {
                return
            }
            let offeringId = offering.rawValue
            // Perform Purchase
            // Get skProduct
            getOfferings { packages in
                if let package = packages.first(where: { offer in
                    offer.id == offeringId
                }) {
                    print("package = \(package.identifier), productID = \(offeringId)")
                    print("package = \(package.storeProduct.localizedTitle), package.productID = \(package.storeProduct.productIdentifier)")
                    Purchases.shared.purchase(package: package) { _, _, error, userCancelled in
                        if error == nil && !userCancelled {
                            // Successful Purchase
                            print("Success!")
                            if package.id == Offerings.removeAds.rawValue {
                                self.removeAds()
                            } /* else if Offerings.supportValues.contains(where: { offer in
                                offer.rawValue == package.id
                            }) {
                                SwiftUIAlert.show(
                                    title: NSLocalizedString("Thank You!", comment: "Title in thank you for supporting us alert"),
                                    message: NSLocalizedString("Thank you for supporting us!", comment: "Message in thank you for supporting us alert"),
                                    preferredStyle: .alert,
                                    actions: [
                                        UIAlertAction(title: NSLocalizedString("Done", comment: "Done button in thank you for supporting us alert"), style: .default)
                                    ])
                            }*/
                            Analytics.logEvent("in_app_purchase", parameters: ["product" : String(describing: offering)])
                            completion("")
                        } else if userCancelled {
                            print("Error, user cancelled")
                            SwiftUIAlert.show(
                                title: NSLocalizedString("Uh Oh", comment: "Shown in transaction cancelled alert"),
                                message: NSLocalizedString("The transaction was cancelled", comment: "Shown in transaction cancelled alert"),
                                preferredStyle: .alert,
                                actions: [
                                    UIAlertAction(
                                        title: NSLocalizedString("Ok", comment: "Shown in transaction cancelled alert"),
                                        style: .default
                                    )
                                ]
                            )
                            completion("The transaction was cancelled")
                        } else {
                            print("Error, \(error!)")
                            self.reportError(function: "Purchase IAP", error: error!)
                            SwiftUIAlert.show(
                                title: NSLocalizedString("Uh Oh", comment: "Shown in unable purchase alert"),
                                message: NSLocalizedString("Error: \(error!.localizedDescription)", comment: "Shown in unable purchase alert"),
                                preferredStyle: .alert,
                                actions: [
                                    UIAlertAction(
                                        title: NSLocalizedString("Done", comment: "Shown in unable purchase alert"),
                                        style: .default
                                    )
                                ]
                            )
                            completion("Error: \(error!.localizedDescription)")
                        }
                    }
                } else {
                    print("Error, doesn't work")
                    SwiftUIAlert.show(title: NSLocalizedString("Uh Oh", comment: "Shown in In App Purchases are not availble alert"), message: NSLocalizedString("In App Purchases are not availble at this time.", comment: "Shown in In App Purchases are not availble alert"), preferredStyle: .alert, actions: [
                        UIAlertAction(title: NSLocalizedString("Ok", comment: "Shown in In App Purchases are not availble alert"), style: .default, handler: { _ -> Void in
                            print("\"IAP Unavailible\" alert was dismised")
                        })
                    ])
                    completion("In App Purchases are not availble at this time.")
                }
            }
        }
    }
    private func reportError(function: String, error: Error) {
        self.db.collection("Errors").document("RevenueCat").collection(UIDevice.current.identifierForVendor?.uuidString ?? "No UUID").document("\(Date())").setData([
            "Function": function,
            "Full Error": "\(error)",
            "Localized Error": error.localizedDescription,
            "Device Model": "\(UIDevice.current.model)",
            "OS": "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            "User Interface Idiom": "\(UIDevice.current.userInterfaceIdiom)"
        ])
    }
}
// MARK: Offering Info
struct OfferingInfo: Identifiable, Equatable {
    let id: PurchaseService.Offerings
    var name: String
    var price: String
    // MARK: Equatable Methods
    public static func == (lhs: OfferingInfo, rhs: OfferingInfo) -> Bool {
        return (lhs.id == rhs.id && lhs.name == rhs.name)
    }
    static var offerings: [OfferingInfo] = [
        OfferingInfo(id: .removeAds, name: "Remove Ads", price: "$0.99"),
//        OfferingInfo(id: .supportUs1, name: "Support Us $0.99", price: "$0.99"),
//        OfferingInfo(id: .supportUs5, name: "Support Us $4.99", price: "$4.99"),
//        OfferingInfo(id: .supportUs10, name: "Support Us $9.99", price: "$9.99"),
//        OfferingInfo(id: .supportUs20, name: "Support Us $19.99", price: "$19.99")
    ]
}
