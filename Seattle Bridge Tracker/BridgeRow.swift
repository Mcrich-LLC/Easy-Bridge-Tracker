//
//  BridgeRow.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 8/31/22.
//

import SwiftUI
import URLImage
import Mcrich23_Toolkit
import SwiftUIBackports
import Introspect
import Foundation

struct BridgeRow: View {
    @State var bridge: Bridge
    @ObservedObject var viewModel: ContentViewModel
    var body: some View {
        NavigationLink {
            BridgeView(bridge: bridge, viewModel: viewModel)
        } label: {
            HStack {
                if #available(iOS 15, *) {
                    AsyncImage(url: bridge.imageUrl) { image in
                        image
                            .resizable()
                            .frame(width: 60, height: 60)
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    }
                } else {
                    URLImage(bridge.imageUrl) { image in
                        image
                            .resizable()
                            .frame(width: 60, height: 60)
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                    }
                }
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text(bridge.name)
                            .foregroundColor(Color(.label))
                        Text(bridge.address)
                            .font(SwiftUI.Font.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    switch bridge.status {
                    case .up:
                        Text("Up")
                            .foregroundColor(.red)
                    case .down:
                        Text("Down")
                            .foregroundColor(.green)
                    case .maintenance:
                        Text("Under Maintenance")
                            .foregroundColor(.yellow)
                    case .unknown:
                        Text("Unknown")
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}

struct BridgeRow_Previews: PreviewProvider {
    static var previews: some View {
        BridgeRow(bridge: Bridge(name: "", status: .unknown, imageUrl: URL(string: "https://google.com")!, mapsUrl: URL(string: "https://google.com")!, address: "", latitude: 0, longitude: 0, bridgeLocation: "Seattle, Wa"), viewModel: ContentViewModel())
    }
}
