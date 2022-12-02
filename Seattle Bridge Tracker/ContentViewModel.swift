//
//  ContentViewModel.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import Foundation
import Firebase

class ContentViewModel: ObservableObject {
    @Published var bridges: [String: [Bridge]] = [:] {
        didSet {
            var count = 0 {
                didSet {
                    if count >= self.response.count {
                        self.status = .success
                    }
                }
            }
            for bridgeArray in self.bridges {
                count += bridgeArray.value.count
            }
        }
    }
    @Published var bridgeFavorites: [String] = []
    @Published var status: LoadingStatus = .loading
    private var response: [Response] = []
    let dataFetch = TwitterFetch()
    let noImage = URL(string: "https://st4.depositphotos.com/14953852/22772/v/600/depositphotos_227725020-stock-illustration-image-available-icon-flat-vector.jpg")!
    func fetchData(repeatFetch: Bool) {
        self.dataFetch.fetchTweet { error in
            print("❌ Status code is \(error.rawValue)")
            DispatchQueue.main.async {
                self.status = .failed("\(error.rawValue) - \(error.localizedReasonPhrase.capitalized)")
            }
        } completion: { response in
            self.response = response
            for bridge in response {
                DispatchQueue.main.async {
                    let addBridge = Bridge(name: bridge.name, status: BridgeStatus(rawValue: bridge.status) ?? .unknown, imageUrl: URL(string: bridge.imageUrl) ?? self.noImage, mapsUrl: URL(string: bridge.mapsUrl)!, address: bridge.address, latitude: bridge.latitude, longitude: bridge.longitude, bridgeLocation: bridge.bridgeLocation, subscribed: UserDefaults.standard.bool(forKey: "\(bridge.bridgeLocation).\(bridge.name).subscribed"))
                    if (self.bridges[bridge.bridgeLocation] ?? []).contains(where: { br in
                        br.name == addBridge.name
                    }) {
                        let index = self.bridges[bridge.bridgeLocation]!.firstIndex { br in
                            br.name == addBridge.name
                        }!
                        self.bridges[bridge.bridgeLocation]![index].status = addBridge.status
                        print("\(addBridge.name): addBridge.status = \(addBridge.status), self.bridges[bridge.bridgeLocation]![index].status = \(self.bridges[bridge.bridgeLocation]![index].status)")
                    } else {
                        if self.bridges[bridge.bridgeLocation] != nil {
                            self.bridges[bridge.bridgeLocation]!.append(addBridge)
                        } else {
                            self.bridges[bridge.bridgeLocation] = [addBridge]
                        }
                    }
                }
            }
        }
        if repeatFetch {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.fetchData(repeatFetch: true)
            }
        }
    }
    func toggleFavorite(bridgeLocation: String) {
        if self.bridgeFavorites.contains(bridgeLocation) {
            let bridges = self.bridgeFavorites.firstIndex { bridge in
                bridge == bridgeLocation
            }!
            self.bridgeFavorites.remove(at: bridges)
        } else {
            self.bridgeFavorites.append(bridgeLocation)
        }
    }
    func toggleSubscription(for bridge: Bridge) {
        let bridgeName = "\(bridge.bridgeLocation)_\(bridge.name)".replacingOccurrences(of: " Bridge", with: "").replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "st", with: "").replacingOccurrences(of: "nd", with: "").replacingOccurrences(of: "3rd", with: "").replacingOccurrences(of: "th", with: "").replacingOccurrences(of: " ", with: "_")
        if bridge.subscribed {
            Analytics.setUserProperty("subscribed", forName: bridgeName)
            Analytics.logEvent("subscribed_to_bridge", parameters: ["subscribed" : bridgeName])
            let index = self.bridges[bridge.bridgeLocation]?.firstIndex(where: { bridgeArray in
                bridgeArray.name == bridge.name
            })!
            self.bridges[bridge.bridgeLocation]![index!].subscribed = false
            UserDefaults.standard.set(false, forKey: "\(bridge.bridgeLocation).\(bridge.name).subscribed")
        } else {
            Analytics.setUserProperty("unsubscribed", forName: bridgeName)
            Analytics.logEvent("unsubscribed_to_bridge", parameters: ["unsubscribed" : bridgeName])
            let index = self.bridges[bridge.bridgeLocation]?.firstIndex(where: { bridgeArray in
                bridgeArray.name == bridge.name
            })!
            self.bridges[bridge.bridgeLocation]![index!].subscribed = true
            UserDefaults.standard.set(true, forKey: "\(bridge.bridgeLocation)_\(bridge.name).subscribed")
        }
    }
    
}
struct Bridge: Identifiable, Hashable, Comparable {
    static func < (lhs: Bridge, rhs: Bridge) -> Bool {
        return lhs.name < rhs.name
    }
    
    let id = UUID()
    let name: String
    var status: BridgeStatus
    let imageUrl: URL
    let mapsUrl: URL
    let address: String
    let latitude: Double
    let longitude: Double
    let bridgeLocation: String
    var subscribed: Bool
}
enum BridgeStatus: String {
    case up
    case down
    case maintenance
    case unknown
}

enum LoadingStatus {
    case success
    case loading
    case failed(String)
}
