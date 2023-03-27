//
//  NotificationPreferencesModel.swift
//  NotificationService
//
//  Created by Morris Richman on 3/26/23.
//

import Foundation
import UserNotifications
import Firebase
import Mcrich23_Toolkit
import SwiftUI

final class NotificationPreferencesModel: ObservableObject {
    static let shared = NotificationPreferencesModel()
    @Published var preferencesArray: [NotificationPreferences] = [] {
        didSet {
            setPreferences()
        }
    }
    let fileName = "NotificationPreferences.json"
    
    func addSubscription(for bridge: Bridge) {
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            DispatchQueue.main.async {
                if setting.authorizationStatus == .authorized {
                        Analytics.setUserProperty("subscribed", forName: ContentViewModel.shared.bridgeName(bridge: bridge))
                        Analytics.logEvent("subscribed_to_bridge", parameters: ["subscribed" : ContentViewModel.shared.bridgeName(bridge: bridge)])
                        Messaging.messaging().subscribe(toTopic: ContentViewModel.shared.bridgeName(bridge: bridge))
                        let index = ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]?.firstIndex(where: { bridgeArray in
                            bridgeArray.name == bridge.name
                        })!
                        ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]![index!].subscribed = true
                        UserDefaults.standard.set(true, forKey: "\(ContentViewModel.shared.bridgeName(bridge: bridge)).subscribed")
                } else {
                    SwiftUIAlert.show(title: "Uh Oh", message: "Notifications are disabled. Please enable them in settings.", preferredStyle: .alert, actions: [UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { _ in
                        // continue your work
                    }, UIAlertAction(title: "Open Settings", style: .cancel, handler: { _ in
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings)
                        }
                    })])
                }
            }
        }
    }
    
    func removeSubscription(for bridge: Bridge) {
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            DispatchQueue.main.async {
                if setting.authorizationStatus == .authorized {
                        let allBridgeIds = self.preferencesArray.map { $0.bridgeIds }.joined()
                        if !allBridgeIds.contains(bridge.id) {
                            Analytics.setUserProperty("unsubscribed", forName: ContentViewModel.shared.bridgeName(bridge: bridge))
                            Analytics.logEvent("unsubscribed_to_bridge", parameters: ["unsubscribed" : ContentViewModel.shared.bridgeName(bridge: bridge)])
                            Messaging.messaging().unsubscribe(fromTopic: ContentViewModel.shared.bridgeName(bridge: bridge))
                            if let index = ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]?.firstIndex(where: { bridgeArray in
                                bridgeArray.name == bridge.name
                            }) {
                                ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]![index].subscribed = false
                            }
                            UserDefaults.standard.set(false, forKey: "\(ContentViewModel.shared.bridgeName(bridge: bridge)).subscribed")
                        }
                } else {
                    SwiftUIAlert.show(title: "Uh Oh", message: "Notifications are disabled. Please enable them in settings.", preferredStyle: .alert, actions: [UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { _ in
                        // continue your work
                    }, UIAlertAction(title: "Open Settings", style: .cancel, handler: { _ in
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings)
                        }
                    })])
                }
            }
        }
    }
    
    func setPreferences() {
        do {
            enum throwError: Error {
                case unableToWrite
            }
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            let preferencesJson = try jsonEncoder.encode(preferencesArray)
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let pathWithFileName = documentDirectory.appendingPathComponent(fileName)
                
                try preferencesJson.write(to: pathWithFileName)
            } else {
                throw throwError.unableToWrite
            }
        } catch {
            print("Unable to write json")
        }
    }
    
    func getPreferences() {
        do {
            enum throwError: Error {
                case fileDoesNotExist
            }
            if let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let preferencesArray = try jsonDecoder.decode([NotificationPreferences].self, from: Data(contentsOf: filePath))
                
                self.preferencesArray = preferencesArray
                let allBridgeIds = preferencesArray.map { $0.bridgeIds }.joined()
                for id in allBridgeIds {
                    if let bridge = ContentViewModel.shared.allBridges.first(where: { $0.id == id}) {
                        addSubscription(for: bridge)
                    }
                }
            } else {
                throw throwError.fileDoesNotExist
            }
        } catch {
            print("NotificationPreferences.json doesn't exist")
        }
    }
    
    func updateTitle(for preferences: NotificationPreferences) {
        var title = preferences.title
        SwiftUIAlert.textfieldShow(title: "Update Schedule Name", message: "Update the name of this notification schedule.", preferredStyle: .alert, textfield: .init(text: Binding(get: {
            return title
        }, set: { newValue in
            title = newValue
        }), placeholder: "Schedule Name"), actions: [.init(title: "Cancel", style: .destructive), .init(title: "Done", style: .default, handler: { _ in
            if let index = self.preferencesArray.firstIndex(where: { $0.id == preferences.id }) {
                self.preferencesArray[index].title = title
            }
        })])
    }
        
    func setTitle(onDone completion: @escaping (_ title: String) -> Void) {
            var title = "Untitled"
            SwiftUIAlert.textfieldShow(title: "Set Schedule Name", message: "Set the name of this notification schedule.", preferredStyle: .alert, textfield: .init(text: Binding(get: {
                return title
            }, set: { newValue in
                title = newValue
            }), placeholder: "Schedule Name"), actions: [.init(title: "Cancel", style: .destructive), .init(title: "Done", style: .default, handler: { _ in
                completion(title)
            })])
    }
}
