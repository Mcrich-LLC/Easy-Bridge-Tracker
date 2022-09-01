//
//  ContentView.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import SwiftUI
import URLImage
import Mcrich23_Toolkit
import SwiftUIBackports
import Introspect
import Foundation

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    var body: some View {
        NavigationView {
            VStack {
                if !NetworkMonitor.shared.isConnected {
                    Text("Please check your internet and try again.")
                } else {
                    switch viewModel.status {
                    case .loading:
                        ProgressView()
                    case .failed(let error):
                        errors(error: error)
                    case .success:
                        List {
                            ForEach(Array(viewModel.bridges.keys), id: \.self) { key in
                                Section {
//                                    Section {
//                                        ForEach(viewModel.bridges.sorted(), id: \.self) { bridge in
//                                            if #available(iOS 15.0, *) {
//                                                BridgeRow(bridge: bridge)
//                                                    .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
//                                                        Favorite(viewModel: viewModel)
//                                                            .tint(.yellow)
//                                                    })
//                                            } else {
//                                                // Fallback on earlier versions
//                                                BridgeRow(bridge: bridge)
//                                            }
//                                        }
//                                    } header: {
//                                        Text("Favorites")
//                                    }
                                    ForEach((viewModel.bridges[key] ?? []).sorted()) { bridge in
                                        if #available(iOS 15.0, *) {
                                            BridgeRow(bridge: bridge)
                                                .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                                                    Favorite(viewModel: viewModel)
                                                        .tint(.yellow)
                                                })
                                        } else {
                                            // Fallback on earlier versions
                                            BridgeRow(bridge: bridge)
                                        }
                                    }
                                } header: {
                                    Text(key)
                                }
                            }
                        }
                        .backport.refreshable(action: {
                            await viewModel.fetchData()
                        })
                        .tag(0)
                        .listStyle(GroupedListStyle())
                    }
                }
            }
            .onAppear {
                viewModel.fetchData()
            }
            .introspectNavigationController { navController in
                let bar = navController.navigationBar
                let hosting = UIHostingController(rootView: HelpMenu())
                
                guard let hostingView = hosting.view else { return }
                // bar.addSubview(hostingView)                                          // <--- OPTION 1
                 bar.subviews.first(where: \.clipsToBounds)?.addSubview(hostingView)  // <--- OPTION 2
                hostingView.backgroundColor = .clear
                
                hostingView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    hostingView.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
                    hostingView.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -8)
                ])
            }
            .navigationBarTitle("Bridges", displayMode: .large)
        }
        .navigationViewStyle(.stack)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
//                BannerAds()
            }
        }
    }
    
    func errors(error: String) -> some View {
        VStack {
            Text("Unable to connect to server, please try again later. If issues persist, please email me at: [Support@mcrich23.com](mailto:Support@mcrich23.com).\n\nError: \(error)")
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
