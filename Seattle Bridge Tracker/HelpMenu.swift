//
//  HelpMenu.swift
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

struct HelpMenu: View {
    
    var body: some View {
        Menu {
            Link(destination: URL(string: "mailto:feedback@mcrich23@icloud.com")!) {
                Label("Give Feedback", systemImage: "tray")
            }
            Link(destination: URL(string: "mailto:support@mcrich23@icloud.com")!) {
                Label("Get Support", systemImage: "questionmark.circle")
            }
            Button {
                Mcrich23_Toolkit.presentShareSheet(activityItems: ["I found this app that tells you when bridges are up and down in real time! You should download it here: https://mcrich23.com/easy-bridge-tracker"], excludedActivityTypes: [])
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }

            Button {
                Mcrich23_Toolkit.topVC().present {
                    Info()
                }
            } label: {
                Label("Info", systemImage: "info.circle")
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

struct HelpMenu_Previews: PreviewProvider {
    static var previews: some View {
        HelpMenu()
    }
}
