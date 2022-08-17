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
                ForEach(viewModel.bridges, id: \.self) { bridge in
                    HStack() {
                        Text(bridge.name)
                        if bridge.status == .up {
                            Text("Up")
                                .foregroundColor(.red)
                        } else if bridge.status == .maintenance {
                            Text("Under Maintenance")
                                .foregroundColor(.yellow)
                        } else {
                            Text("Down")
                                .foregroundColor(.green)
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
