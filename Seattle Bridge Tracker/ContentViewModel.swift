//
//  ContentViewModel.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import Foundation

class ContentViewModel: ObservableObject {
    @Published var bridges: [Bridge] = []
    let dataFetch = TwitterFetch()
    func fetchData() {
            self.dataFetch.fetchTweet { response in
                DispatchQueue.main.async {
                    self.bridges.removeAll()
                }
                for bridge in response {
                    DispatchQueue.main.async {
                    self.bridges.append(Bridge(name: bridge.name, status: BridgeStatus(rawValue: bridge.status) ?? .unknown, mapsUrl: URL(string: bridge.mapsUrl)!, address: bridge.address, latitude: bridge.latitude, longitude: bridge.longitude))
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
    let status: BridgeStatus
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
