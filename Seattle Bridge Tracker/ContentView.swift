//
//  ContentView.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.bridges.sorted(), id: \.self) { bridge in
                    Link(destination: bridge.mapsUrl) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(bridge.name)
                                    .foregroundColor(Color(.label))
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
                            Text(bridge.address)
                                .font(SwiftUI.Font.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
