//
//  NotificationFavoritedCities.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 4/3/23.
//

import SwiftUI

struct NotificationFavoritedCities: View {
    @ObservedObject var viewModel = ContentViewModel.shared
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var adController = AdController.shared
    @ObservedObject var favoritesModel = FavoritesModel.shared
    @Binding var preference: NotificationPreferences
    let toggleBridgeCallback: (Bridge) -> Void
    var body: some View {
        ForEach(favoritesModel.favorites, id: \.self) { key in
            Section {
                VStack {
                    ForEach((viewModel.sortedBridges[key] ?? []).sorted()) { bridge in
                        NotificationBridgeRow(bridge: Binding(get: {
                            print("get \(bridge)")
                            return bridge
                        }, set: { _ in
                        }), isSelected: preference.bridgeIds.contains(bridge.id), toggleBridgeCallback: { bridge in
                            toggleBridgeCallback(bridge)
                        })
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
            } header: {
                HStack {
                    Text(key)
                    if viewModel.sortedBridges.keys.count >= 3 {
                        Spacer()
                        Button {
                            favoritesModel.toggleFavorite(bridgeLocation: key)
                        } label: {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .imageScale(.medium)
                        }
                    }
                }
            }
        }
    }
}

struct NotificationFavoritedCities_Previews: PreviewProvider {
    static var previews: some View {
        NotificationFavoritedCities(preference: .constant(NotificationPreferences.defaultPreferences), toggleBridgeCallback: {_ in})
    }
}
