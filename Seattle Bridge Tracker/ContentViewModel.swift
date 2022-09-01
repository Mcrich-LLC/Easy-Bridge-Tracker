//
//  ContentViewModel.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import Foundation

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
                print("❌ Status code is \(error.statusCode)")
                self.status = .failed(error.description)
            } completion: { response in
                self.response = response
                for bridge in response {
                    DispatchQueue.main.async {
                        let addBridge = Bridge(name: bridge.name, status: BridgeStatus(rawValue: bridge.status) ?? .unknown, imageUrl: URL(string: bridge.imageUrl) ?? self.noImage, mapsUrl: URL(string: bridge.mapsUrl)!, address: bridge.address, latitude: bridge.latitude, longitude: bridge.longitude, bridgeLocation: bridge.bridgeLocation)
                        if (self.bridges[bridge.bridgeLocation] ?? []).contains(where: { br in
                            br.name == addBridge.name
                        }) {
                            let index = self.bridges[bridge.bridgeLocation]!.firstIndex { br in
                                br.name == br.name
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
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
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
