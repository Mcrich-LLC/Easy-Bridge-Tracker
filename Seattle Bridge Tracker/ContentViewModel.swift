//
//  ContentViewModel.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import Foundation

class ContentViewModel: ObservableObject {
    @Published var bridges: [Bridge] = [] {
        didSet {
            print("added bridge item")
        }
    }
    let dataFetch = TwitterFetch()
    func fetchData() {
        DispatchQueue.main.async {
            self.dataFetch.fetchTweet { response in
                for bridge in response {
                    self.bridges.append(Bridge(name: bridge.name, status: BridgeStatus(rawValue: bridge.status) ?? .unknown, mapsUrl: bridge.mapsUrl, address: bridge.address, latitude: bridge.latitude, longitude: bridge.longitude))
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                    self.fetchData()
                }
            }
        }
    }
}
struct Bridge: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let status: BridgeStatus
    let mapsUrl: String
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
