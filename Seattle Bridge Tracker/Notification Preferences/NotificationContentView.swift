//
//  NotificationContentView.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/27/23.
//

import SwiftUI
import URLImage
import Mcrich23_Toolkit
import SwiftUIBackports
import Introspect
import SwiftUIX
import Foundation

struct NotificationContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    let bridgeIds: [UUID]
    let toggleBridgeCallback: (Bridge) -> Void
    @Environment(\.backportDismiss) var dismiss
    var body: some View {
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
                        ForEach(viewModel.bridgeFavorites, id: \.self) { key in
                            Section {
                                ForEach((viewModel.sortedBridges[key] ?? []).sorted()) { bridge in
                                    if #available(iOS 15.0, *) {
                                        NotificationBridgeRow(bridge: Binding(get: {
                                            print("get \(bridge)")
                                            return bridge
                                        }, set: { _ in
                                        }), viewModel: viewModel, isSelected: bridgeIds.contains(bridge.id), toggleBridgeCallback: { bridge in
                                            toggleBridgeCallback(bridge)
                                            self.dismiss.callAsFunction()
                                        })
                                        .tag(bridge.name)
                                    } else {
                                        NotificationBridgeRow(bridge: Binding(get: {
                                            print("get \(bridge)")
                                            return bridge
                                        }, set: { _ in
                                        }), viewModel: viewModel, isSelected: bridgeIds.contains(bridge.id), toggleBridgeCallback: { bridge in
                                            toggleBridgeCallback(bridge)
                                            self.dismiss.callAsFunction()
                                        })
                                        .tag(bridge.name)
                                    }
                                }
                            } header: {
                                HStack {
                                    Text(key)
                                    if viewModel.sortedBridges.keys.count >= 3 {
                                        Spacer()
                                        Button {
                                            viewModel.toggleFavorite(bridgeLocation: key)
                                        } label: {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                                .imageScale(.medium)
                                        }
                                    }
                                }
                                
                            }
                        }
                        ForEach(Array(viewModel.sortedBridges.keys), id: \.self) { key in
                            if !Array(viewModel.bridgeFavorites).contains(key) {
                                Section {
                                    ForEach((viewModel.sortedBridges[key] ?? []).sorted()) { bridge in
                                        //                                            NotificationBridgeRow(bridge: Binding(get: {
                                        //                                                print("get \(bridge)")
                                        //                                                return bridge
                                        //                                            }, set: { _ in
                                        //                                            }), viewModel: viewModel, isSelected: bridgeIds.contains(bridge.id.uuidString), toggleBridgeCallback: { bridge in
                                        //                                                toggleBridgeCallback(bridge)
                                        //                                                self.dismiss.callAsFunction()
                                        //                                            })
                                        rowView(bridge: bridge)
                                            .tag(bridge.name)
                                    }
                                    if !Utilities.areAdsDisabled && !Utilities.isFastlaneRunning {
                                        HStack {
                                            Spacer()
                                            BannerAds()
                                            Spacer()
                                        }
                                    }
                                } header: {
                                    HStack {
                                        Text(key)
                                        if viewModel.sortedBridges.keys.count >= 3 {
                                            Spacer()
                                            Button {
                                                viewModel.toggleFavorite(bridgeLocation: key)
                                            } label: {
                                                Image(systemName: "star")
                                                    .foregroundColor(.yellow)
                                                    .imageScale(.medium)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .backport.refreshable(action: {
                        await viewModel.fetchData(repeatFetch: false)
                    })
                    .tag("bridges")
                    .listStyle(GroupedListStyle())
                }
            }
        }
        .onAppear {
            viewModel.fetchData(repeatFetch: true)
        }
        .navigationBarTitle("Subscribed Bridges", displayMode: .large)
        .navigationViewStyle(.stack)
    }
    
    func errors(error: String) -> some View {
        VStack {
            Text("Unable to connect to server, please try again later. If issues persist, please email me at: [Support@mcrich23.com](mailto:Support@mcrich23.com).\n\nError: \(error)")
            Spacer()
        }
        .padding()
    }
    func rowView(bridge: Bridge) -> some View {
        NotificationBridgeRow(bridge: Binding(get: {
            return bridge
        }, set: { _ in
        }), viewModel: viewModel, isSelected: bridgeIds.contains(bridge.id), toggleBridgeCallback: { bridge in
            toggleBridgeCallback(bridge)
            self.dismiss.callAsFunction()
        })
    }
}

struct NotificationContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
