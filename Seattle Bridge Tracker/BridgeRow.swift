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
    @Binding var bridge: Bridge
    @ObservedObject var viewModel: ContentViewModel
    @State var showView = false
    var body: some View {
        NavigationLink(isActive: $showView) {
            BridgeView(bridge: $bridge, viewModel: viewModel)
        } label: {
            BridgeRowBody(bridge: $bridge)
                .contextMenu(PreviewContextMenu(navigate: .custom({
                    showView.toggle()
                }), destination: BridgeView(bridge: $bridge, viewModel: viewModel), menu: {
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
//                .contextMenu(CustomContextMenu(navigate: {
//                    showView.toggle()
//                }, content: {
//                    Button {
//                        showView.toggle()
//                    } label: {
//                        Text("Open")
//                        Image(systemName: "arrow.right")
//                    }
//
//                }, preview: {
//                    BridgeView(bridge: $bridge, viewModel: viewModel)
//                }, menu: {
//                    let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: []) // Menu
//                        return menu
//                }))
//                            .contextMenu {
//                                showView.toggle()
//                            } preview: {
//                                BridgeView(bridge: $bridge, viewModel: viewModel)
//                            } menu: {
//                                let openView = UIAction(title: "Open", image: UIImage(systemName: "arrow.right")) { _ in
//                                    showView.toggle()
//                                }
//                                let openUrl = UIAction(title: "Open in Maps", image: UIImage(systemName: "map")) { _ in
//                                    SwiftUIAlert.show(title: "Open Bridge?", message: "Do you want to open \(bridge.name) in maps?", preferredStyle: .alert, actions: [UIAlertAction(title: "Open", style: .default, handler: { _ in
//                                        UIApplication.shared.open(bridge.mapsUrl)
//                                    }), UIAlertAction(title: "Cancel", style: .cancel)])
//                                }
//                                let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [openView, openUrl]) // Menu
//                                    return menu
//                            }

        }
    }
}

struct BridgeRow_Previews: PreviewProvider {
    static var previews: some View {
        BridgeRow(bridge: .constant(Bridge(name: "", status: .unknown, imageUrl: URL(string: "https://google.com")!, mapsUrl: URL(string: "https://google.com")!, address: "", latitude: 0, longitude: 0, bridgeLocation: "Seattle, Wa", subscribed: false)), viewModel: ContentViewModel())
    }
}

struct BridgeStatusView: View {
    @Binding var status: BridgeStatus
    var body: some View {
        switch status {
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
