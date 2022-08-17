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
    var tweets: [Tweet] = [] {
        didSet {
            for tweet in tweets {
                print("tweet.text = \(tweet.text)")
                func addBridge(name: String) {
//                    print("name = \(name)")
                    if !bridges.contains(where: { bridge in
                        bridge.name == name
                    }) {
                        if tweet.text.lowercased().contains("opened to traffic") {
                            bridges.append(Bridge(name: name, status: .down))
                        } else if tweet.text.lowercased().contains("maintenance") {
                            if tweet.text.lowercased().contains("finished") {
                                bridges.append(Bridge(name: name, status: .down))
                            } else {
                                bridges.append(Bridge(name: name, status: .maintenance))
                            }
                        } else {
                            bridges.append(Bridge(name: name, status: .up))
                        }
                    }
                }
                switch tweet.text {
                case let str where str.contains("Ballard Bridge"):
                    addBridge(name: "Ballard Bridge")
                case let str where str.contains("Fremont Bridge"):
                    addBridge(name: "Fremont Bridge")
                case let str where str.contains("Montlake Bridge"):
                    addBridge(name: "Montlake Bridge")
                case let str where str.contains("Spokane St Swing Bridge"):
                    addBridge(name: "Spokane St Swing Bridge")
                case let str where str.contains("South Park Bridge"):
                    addBridge(name: "South Park Bridge")
                case let str where str.contains("University Bridge"):
                    addBridge(name: "University Bridge")
                case let str where str.contains("1 Ave S Bridge"):
                    addBridge(name: "1 Ave S Bridge")
                default:
                    break
                }
            }
        }
    }
    func fetchData() {
        DispatchQueue.main.async {
            self.dataFetch.fetchTweet { response in
                switch response {
                case .success(let response):
                    DispatchQueue.main.async {
                        self.tweets = response.data
                    }
                case .failure(let error):
                    print("error = \(error)")
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
}
enum BridgeStatus {
    case up
    case down
    case maintenance
}
