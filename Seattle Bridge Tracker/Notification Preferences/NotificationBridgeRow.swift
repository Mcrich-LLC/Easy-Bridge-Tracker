//
//  NotificationBridgeRow.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/27/23.
//

import SwiftUI
import URLImage
import Mcrich23_Toolkit
import SwiftUIBackports
import Introspect
import Foundation

struct NotificationBridgeRow: View {
    @Binding var bridge: Bridge
    @ObservedObject var viewModel: ContentViewModel
    let isSelected: Bool
    let toggleBridgeCallback: (Bridge) -> Void
    var body: some View {
        Button {
            toggleBridgeCallback(bridge)
        } label: {
            NotificationBridgeRowBody(bridge: $bridge, isSelected: isSelected)
        }
    }
}

struct NotificationBridgeRow_Previews: PreviewProvider {
    static var previews: some View {
        BridgeRow(bridge: .constant(Bridge(id: UUID(), name: "", status: .unknown, imageUrl: URL(string: "https://google.com")!, mapsUrl: URL(string: "https://google.com")!, address: "", latitude: 0, longitude: 0, bridgeLocation: "Seattle, Wa", subscribed: false)), viewModel: ContentViewModel())
    }
}

struct NotificationBridgeRowBody: View {
    @Binding var bridge: Bridge
    let isSelected: Bool
    var body: some View {
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
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.primary)
                }
            }
        }
        .background(.adaptable(light: .clear, dark: .systemGray6))
    }
}
