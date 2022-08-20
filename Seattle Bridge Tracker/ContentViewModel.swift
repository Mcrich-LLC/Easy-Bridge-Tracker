//
//  ContentViewModel.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import Foundation

class ContentViewModel: ObservableObject {
    @Published var bridges: [Bridge] = []
    @Published var status: LoadingStatus = .loading
    let dataFetch = TwitterFetch()
    let noImage = URL(string: "https://st4.depositphotos.com/14953852/22772/v/600/depositphotos_227725020-stock-illustration-image-available-icon-flat-vector.jpg")!
    func fetchData() {
        self.dataFetch.fetchTweet { error in
                print("❌ Status code is \(error.statusCode)")
                self.status = .failed(error.description)
            } completion: { response in
                for bridge in response {
                    DispatchQueue.main.async {
                        let addBridge = Bridge(name: bridge.name, status: BridgeStatus(rawValue: bridge.status) ?? .unknown, imageUrl: URL(string: bridge.imageUrl) ?? self.noImage, mapsUrl: URL(string: bridge.mapsUrl)!, address: bridge.address, latitude: bridge.latitude, longitude: bridge.longitude)
                        if self.bridges.contains(where: { br in
                            br.name == addBridge.name
                        }) {
                            let index = self.bridges.firstIndex { br in
                                br.name == br.name
                            }!
                            self.bridges[index].status = addBridge.status
                        } else {
                            self.bridges.append(addBridge)
                            if self.bridges.count >= response.count {
                                self.status = .success
                            }
                            
                        }
                }
            }
            }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
            self.fetchData()
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
