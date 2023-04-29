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
import SwiftUIAlert

struct BridgeRow: View {
    @Binding var bridge: Bridge
    @ObservedObject var contentViewModel = ContentViewModel.shared
    @State var showView = false
    var body: some View {
        NavigationLink(isActive: $showView) {
            BridgeView(bridge: $bridge)
        } label: {
            BridgeRowBody(bridge: $bridge)
                .contextMenu(PreviewContextMenu(navigate: .custom({
                    showView.toggle()
                }), destination: BridgeView(bridge: $bridge), menu: {
                    let openView = UIAction(title: "Open", image: UIImage(systemName: "arrow.right")) { _ in
                        showView.toggle()
                    }
                    let openUrl = UIAction(title: "Open in Maps", image: UIImage(systemName: "map")) { _ in
                        SwiftUIAlert.show(title: "Open Bridge?", message: "Do you want to open \(bridge.name) in maps?", preferredStyle: .alert, actions: [UIAlertAction(title: "Open", style: .default, handler: { _ in
                            UIApplication.shared.open(bridge.mapsUrl)
                        }), UIAlertAction(title: "Cancel", style: .cancel)])
                    }
                    return UIMenu(title: "", children: [openView, openUrl])
                }))

        }
    }
}

struct BridgeRow_Previews: PreviewProvider {
    static var previews: some View {
        BridgeRow(bridge: .constant(Bridge(id: UUID(), name: "", status: .unknown, imageUrl: URL(string: "https://google.com")!, mapsUrl: URL(string: "https://google.com")!, address: "", latitude: 0, longitude: 0, bridgeLocation: "Seattle, Wa", subscribed: false)))
    }
}

struct BridgeStatusView: View {
    @Binding var status: BridgeStatus
    var body: some View {
        switch status {
        case .up:
            Text(status.rawValue.capitalized)
                .foregroundColor(.red)
        case .down:
            Text(status.rawValue.capitalized)
                .foregroundColor(.green)
        case .maintenance:
            Text(status.rawValue.capitalized)
                .foregroundColor(.yellow)
        case .unknown:
            Text(status.rawValue.capitalized)
                .foregroundColor(.yellow)
        }
    }
}
struct BridgeRowBody: View {
    @Binding var bridge: Bridge
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
                if bridge.subscribed {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.primary)
                }
                BridgeStatusView(status: $bridge.status)
            }
        }
        .background(.adaptable(light: .clear, dark: .systemGray6))
    }
}
