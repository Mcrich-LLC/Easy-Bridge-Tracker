//
//  BridgeFilterView.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 4/3/23.
//

import SwiftUI
import SwiftUIX

struct BridgeFilterView: View {
    @ObservedObject var viewModel = ContentViewModel.shared
    var body: some View {
        HStack(spacing: 10) {
            Picker(selection: $viewModel.filterSelection) {
                ForEach(viewModel.filterOptions, id: \.self) { option in
                    switch option {
                    case .allBridges:
                        Text("All Bridges")
                    case .favorites:
                        Text("Favorites")
                    case .city(let name):
                        Text(name)
                    }
                }
            }
            .pickerStyle(.menu)
            if viewModel.sortedBridges.keys.count >= 3 {
                switch viewModel.filterSelection {
                case .allBridges: EmptyView()
                case .favorites: EmptyView()
                case .city(let name):
                    Button {
                        viewModel.toggleFavorite(bridgeLocation: name)
                    } label: {
                        HStack {
                            if viewModel.bridgeFavorites.contains(name) {
                                Image(systemName: "star.fill")
                            } else {
                                Image(systemName: "star")
                            }
                        }
                        .foregroundColor(.yellow)
                        .imageScale(.medium)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct BridgeFilterView_Previews: PreviewProvider {
    static var previews: some View {
        BridgeFilterView()
    }
}
