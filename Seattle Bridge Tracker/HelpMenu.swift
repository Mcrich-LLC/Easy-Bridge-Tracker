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
import SwiftUIAlert

struct HelpMenu: View {
    @ObservedObject var contentViewModel = ContentViewModel.shared
    @State var supportUs1 = OfferingInfo.offerings.first { offering in
        offering.id.rawValue == PurchaseService.Offerings.supportUs1.rawValue
    }!
    @State var supportUs5 = OfferingInfo.offerings.first { offering in
        offering.id.rawValue == PurchaseService.Offerings.supportUs5.rawValue
    }!
    @State var supportUs10 = OfferingInfo.offerings.first { offering in
        offering.id.rawValue == PurchaseService.Offerings.supportUs10.rawValue
    }!
    @State var supportUs20 = OfferingInfo.offerings.first { offering in
        offering.id.rawValue == PurchaseService.Offerings.supportUs20.rawValue
    }!
    var body: some View {
        Group {
            if Utilities.isFastlaneRunning {
                Button {
                    contentViewModel.menuScreenshotClickCount += 1
                    if contentViewModel.menuScreenshotClickCount == 1 {
                        contentViewModel.showDemoView()
                    } else  if contentViewModel.menuScreenshotClickCount == 2 {
                        contentViewModel.isShowingNotificationSettings.toggle()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.horizontal)
                        .backgroundFill(.clear)
                }
                .tag("Help Menu Button")
            } else {
                Menu {
                    Section {
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
                    }
                    Section {
                        Button {
                            PurchaseService.shared.purchase(offering: .removeAds, completion: {_ in})
                        } label: {
                            Label("Remove Ads", systemImage: "rectangle.slash")
                        }
                        Button {
                            SwiftUIAlert.show(title: NSLocalizedString("Support Us", comment: "Shown in support us alert"), message: NSLocalizedString("Help us make a better app by donating.", comment: "Shown in support us alert"), preferredStyle: .alert, actions: [
                                UIAlertAction(title: "\(NSLocalizedString("Donate", comment: "Donate button in Support Us Alert in the Menu view")) \(self.supportUs1.price)", style: .default, handler: {_ in PurchaseService.shared.purchase(offering: .supportUs1, completion: {_ in})}),
                                UIAlertAction(title: "\(NSLocalizedString("Donate", comment: "Donate button in Support Us Alert in the Menu view")) \(self.supportUs5.price)", style: .default, handler: {_ in PurchaseService.shared.purchase(offering: .supportUs5, completion: {_ in})}),
                                UIAlertAction(title: "\(NSLocalizedString("Donate", comment: "Donate button in Support Us Alert in the Menu view")) \(self.supportUs10.price)", style: .default, handler: {_ in PurchaseService.shared.purchase(offering: .supportUs10, completion: {_ in})}),
                                UIAlertAction(title: "\(NSLocalizedString("Donate", comment: "Donate button in Support Us Alert in the Menu view")) \(self.supportUs20.price)", style: .default, handler: {_ in PurchaseService.shared.purchase(offering: .supportUs20, completion: {_ in})}),
                                UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button in Support Us Alert in the Menu view"), style: .default)
                            ])
                        } label: {
                            Label(NSLocalizedString("Support Us", comment: "Support Us button in more screen"), systemImage: "dollarsign.circle")
                        }

                        Button {
                            PurchaseService.shared.restore {}
                        } label: {
                            Label("Restore Purchases", systemImage: "purchased")
                        }
                    }
                    Section {
                        Button {
                            contentViewModel.isShowingInfo.toggle()
                        } label: {
                            Label("Info", systemImage: "info.circle")
                        }
                        Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                            Label("Settings", systemImage: "switch.2")
                        }
                        Button {
                            contentViewModel.isShowingNotificationSettings.toggle()
                        } label: {
                            Label("Notification Schedules", systemImage: "bell")
                        }
                    }
                    if Utilities.appType == .TestFlight || Utilities.appType == .Debug {
                        Section {
                            Button {
                                ConsoleManager.uiConsole.isVisible.toggle()
                            } label: {
                                let text = ConsoleManager.uiConsole.isVisible ? "Hide Console" : "Show Console"
                                if #available(iOS 17, *) {
                                    Label(text, systemImage: "apple.terminal")
                                } else {
                                    Label(text, systemImage: "terminal")
                                }
                            }
                        }
                    }
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.horizontal)
                        .backgroundFill(.clear)
                }
            }
        }
        .sheet(isPresented: $contentViewModel.isShowingNotificationSettings) {
            NotificationPreferencesView()
        }
        .sheet(isPresented: $contentViewModel.isShowingInfo) {
            Info()
        }
    }
}

struct HelpMenu_Previews: PreviewProvider {
    static var previews: some View {
        HelpMenu()
    }
}
