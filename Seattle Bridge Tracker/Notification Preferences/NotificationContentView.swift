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
    @ObservedObject var viewModel = ContentViewModel.shared
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var adController = AdController.shared
    @ObservedObject var favoritesModel = FavoritesModel.shared
    @Binding var preference: NotificationPreferences
    @Environment(\.backportDismiss) var dismiss
    
    func toggleBridgeCallback(for bridge: Bridge) {
        Utilities.checkNotificationPermissions { notificationsAreAllowed in
            if notificationsAreAllowed {
                if let index = preferencesModel.preferencesArray.firstIndex(where: { $0.id == preference.id }) {
                    if self.preference.bridgeIds.contains(bridge.id) {
                        self.preference.bridgeIds.remove(at: index)
                        preferencesModel.removeSubscription(for: bridge, preference: preference)
                    } else if !self.preference.bridgeIds.contains(bridge.id) {
                        self.preference.bridgeIds.append(bridge.id)
                        preferencesModel.addSubscription(for: bridge)
                    }
                }
            }
        }
    }
    
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
                        Form {
                            if viewModel.sortedBridges.keys.count > 1 {
                                Section {
                                    BridgeFilterView()
                                }
                            }
                            switch viewModel.filterSelection {
                            case .allBridges:
                                NotificationFavoritedCities(preference: $preference, toggleBridgeCallback: toggleBridgeCallback)
                                ForEach(Array(viewModel.sortedBridges.keys), id: \.self) { key in
                                    if !Array(favoritesModel.favorites).contains(key) {
                                        Section {
                                            ForEach((viewModel.sortedBridges[key] ?? []).sorted()) { bridge in
                                                    rowView(bridge: bridge)
                                                        .tag(bridge.name)
                                            }
                                            if !adController.areAdsDisabled && !Utilities.isFastlaneRunning {
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
                                                        favoritesModel.toggleFavorite(bridgeLocation: key)
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
                            case .favorites:
                                NotificationFavoritedCities(preference: $preference, toggleBridgeCallback: toggleBridgeCallback)
                            case .city(let name):
                                ForEach((viewModel.sortedBridges[name] ?? []).sorted()) { bridge in
                                    rowView(bridge: bridge)
                                        .tag(bridge.name)
                                }
                                if !adController.areAdsDisabled && !Utilities.isFastlaneRunning {
                                    HStack {
                                        Spacer()
                                        BannerAds()
                                        Spacer()
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
                Task(priority: .background) {
                    viewModel.fetchData(repeatFetch: true)
                }
            }
            .navigationBarTitle("Subscribed Bridges", displayMode: .large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        self.dismiss.callAsFunction()
                    }
                }
            }
        }
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
        }), isSelected: preference.bridgeIds.contains(bridge.id), toggleBridgeCallback: { bridge in
            toggleBridgeCallback(for: bridge)
        })
    }
}

struct NotificationContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
