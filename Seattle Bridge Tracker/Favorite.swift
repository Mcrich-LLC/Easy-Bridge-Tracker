//
//  Favorite.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 8/31/22.
//

import SwiftUI
import SwiftUIBackports

struct Favorite: View {
    @ObservedObject var viewModel: ContentViewModel
    var body: some View {
        Button {
        } label: {
            ZStack {
                Image(systemName: "star")
                    .foregroundColor(.white)
            }
        }

    }
}

struct Favorite_Previews: PreviewProvider {
    static var previews: some View {
        Favorite(viewModel: ContentViewModel())
    }
}
