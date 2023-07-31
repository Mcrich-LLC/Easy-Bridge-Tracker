//
//  Info.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 8/27/22.
//

import SwiftUI

struct Info: View {
    @State var build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "x.x"
    @State var version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "x"
    @State var isShowingCredits = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            VStack {
                Image("iTunesArtwork")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .padding()
                Text("Easy Bridge Tracker")
                    .font(.title)
                    .padding()
                VStack(spacing: 1) {
                    Text("Version: \(version)(\(build))")
                    HStack {
                        Image(systemName: "c.circle")
                        Text("Mcrich 2022")
                    }
                    Button("Credits") {
                        isShowingCredits.toggle()
                    }
                }
                .padding()
                .foregroundColor(.gray)
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Text("Done")
                            Image(systemName: "arrow.down")
                        }
                    }
                    
                }
            }
            .sheet(isPresented: $isShowingCredits) {
                Credits()
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct Info_Previews: PreviewProvider {
    static var previews: some View {
        Info()
    }
}
