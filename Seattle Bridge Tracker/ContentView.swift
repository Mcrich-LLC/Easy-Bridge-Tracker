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
                        Section {
                            ForEach(viewModel.bridges.sorted(), id: \.self) { bridge in
                                Button {
                                    SwiftUIAlert.show(title: "Open Bridge?", message: "Do you want to open \(bridge.name) in maps?", preferredStyle: .alert, actions: [UIAlertAction(title: "Open", style: .default, handler: { _ in
                                        UIApplication.shared.open(bridge.mapsUrl)
                                    }), UIAlertAction(title: "Cancel", style: .cancel)])
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
                                            if bridge.status == .up {
                                                Text("Up")
                                                    .foregroundColor(.red)
                                            } else if bridge.status == .maintenance {
                                                Text("Under Maintenance")
                                                    .foregroundColor(.yellow)
                                            } else if bridge.status == .unknown {
                                                Text("Unknown")
                                                    .foregroundColor(.yellow)
                                            } else {
                                                Text("Down")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                            }
                        } header: {
                            Text("Seattle")
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
                BannerAds()
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
struct HelpMenu: View {
    
    var body: some View {
        Menu {
            Link(destination: URL(string: "mailto:feedback@mcrich23@icloud.com")!) {
                Image(systemName: "tray")
                Text("Give Feedback")
            }
            Link(destination: URL(string: "mailto:support@mcrich23@icloud.com")!) {
                Image(systemName: "questionmark.circle")
                Text("Get Support")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(.horizontal)
        }
    }
}
