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

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
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
                            ForEach(viewModel.bridges.sorted(), id: \.self) { bridge in
                                Link(destination: bridge.mapsUrl) {
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
                    }
                    .backport.refreshable(action: {
                        await viewModel.fetchData()
                    })
                }
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
        .navigationBarTitle("Seattle Bridges", displayMode: .large)
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
