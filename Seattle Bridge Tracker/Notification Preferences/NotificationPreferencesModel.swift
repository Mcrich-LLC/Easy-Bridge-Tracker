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
    
    @Published var notificationsAllowed = false
    
    func addSubscription(for bridge: Bridge) {
        Utilities.checkNotificationPermissions { notificationsAreAllowed in
            if notificationsAreAllowed {
                Analytics.setUserProperty("subscribed", forName: ContentViewModel.shared.bridgeName(bridge: bridge))
                Analytics.logEvent("subscribed_to_bridge", parameters: ["subscribed" : ContentViewModel.shared.bridgeName(bridge: bridge)])
                Messaging.messaging().subscribe(toTopic: ContentViewModel.shared.bridgeName(bridge: bridge))
                let index = ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]?.firstIndex(where: { bridgeArray in
                    bridgeArray.name == bridge.name
                })!
                ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]![index!].subscribed = true
                UserDefaults.standard.set(true, forKey: "\(ContentViewModel.shared.bridgeName(bridge: bridge)).subscribed")
            }
        }
    }
    
    func removeSubscription(for bridge: Bridge) {
        Utilities.checkNotificationPermissions { notificationsAreAllowed in
            if notificationsAreAllowed {
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
                Utilities.checkNotificationPermissions { notificationsAreAllowed in
                    if notificationsAreAllowed {
                        for id in allBridgeIds {
                            if let bridge = ContentViewModel.shared.allBridges.first(where: { $0.id == id}) {
                                self.addSubscription(for: bridge)
                            }
                        }
                    }
                }
            } else {
                throw throwError.fileDoesNotExist
            }
        } catch {
            print("NotificationPreferences.json doesn't exist")
        }
    }
    
    func saveTitle(for preferences: NotificationPreferences, with title: String, completion: @escaping () -> Void) {
        var defaultPrefs = preferences
        if self.preferencesArray.contains(where: { $0.title == title }) {
            self.duplicateTitleAlert(for: title) { newTitle in
                defaultPrefs.title = newTitle
                self.preferencesArray.append(defaultPrefs)
                completion()
            }
        } else {
            defaultPrefs.title = title
            self.preferencesArray.append(defaultPrefs)
            completion()
        }
    }
    
    func saveUpdatedTitle(for preferences: NotificationPreferences, with title: String, completion: @escaping () -> Void) {
        if self.preferencesArray.contains(where: { $0.title == title && $0.id != preferences.id }) {
            self.duplicateTitleAlert(for: title) { newTitle in
                if let index = self.preferencesArray.firstIndex(where: { $0.id == preferences.id }) {
                    self.preferencesArray[index].title = newTitle
                    completion()
                }
            }
        } else {
            if let index = self.preferencesArray.firstIndex(where: { $0.id == preferences.id }) {
                self.preferencesArray[index].title = title
                completion()
            }
        }
    }
    
    func updateTitleAlert(for preferences: NotificationPreferences) {
        var title = preferences.title
        SwiftUIAlert.textfieldShow(title: "Update Schedule Name", message: "Update the name of this notification schedule.", preferredStyle: .alert, textfield: .init(text: Binding(get: {
            return title
        }, set: { newValue in
            title = newValue
        }), placeholder: "Schedule Name"), actions: [.init(title: "Cancel", style: .destructive), .init(title: "Done", style: .default, handler: { _ in
            self.saveUpdatedTitle(for: preferences, with: title) {}
        })])
    }
    
    func createNotificationPreferenceAlert(onDone completion: @escaping () -> Void) {
        Utilities.checkNotificationPermissions { notificationsAreAllowed in
            if notificationsAreAllowed {
                let defaultPrefs = NotificationPreferences.defaultPreferences
                var title = defaultPrefs.title
                self.adjustTitleForDuplicates(for: defaultPrefs.title) { newTitle in
                    title = newTitle
                }
                SwiftUIAlert.textfieldShow(title: "Set Schedule Name", message: "Set the name of this notification schedule.", preferredStyle: .alert, textfield: .init(text: Binding(get: {
                    return title
                }, set: { newValue in
                    title = newValue
                }), placeholder: "Schedule Name"), actions: [.init(title: "Cancel", style: .destructive), .init(title: "Done", style: .default, handler: { _ in
                    self.saveTitle(for: defaultPrefs, with: title, completion: completion)
                })])
            }
        }
    }
    
    func createNotificationPreferenceAlert(basedOn preferences: NotificationPreferences, onDone completion: @escaping () -> Void) {
        Utilities.checkNotificationPermissions { notificationsAreAllowed in
            if notificationsAreAllowed {
                var defaultPrefs = preferences
                var title = preferences.title
                self.adjustTitleForDuplicates(for: preferences.title) { newTitle in
                    title = newTitle
                }
                SwiftUIAlert.textfieldShow(title: "Create Notification Schedule", message: "Set the name of this notification schedule.", preferredStyle: .alert, textfield: .init(text: Binding(get: {
                    return title
                }, set: { newValue in
                    title = newValue
                }), placeholder: "Schedule Name"), actions: [.init(title: "Cancel", style: .destructive), .init(title: "Done", style: .default, handler: { _ in
                    self.saveTitle(for: defaultPrefs, with: title, completion: completion)
                })])
            }
        }
    }
    
    func duplicateNotificationPreferenceAlert(basedOn preferences: NotificationPreferences, onDone completion: @escaping () -> Void) {
        Utilities.checkNotificationPermissions { notificationsAreAllowed in
            if notificationsAreAllowed {
                var prefs = preferences
                prefs.id = UUID()
                var title = preferences.title
                self.adjustTitleForDuplicates(for: preferences.title) { newTitle in
                    title = newTitle
                    SwiftUIAlert.textfieldShow(title: "Duplicate Notification Schedule", message: "Set the name of this notification schedule.", preferredStyle: .alert, textfield: .init(text: Binding(get: {
                        return title
                    }, set: { newValue in
                        title = newValue
                    }), placeholder: "Schedule Name"), actions: [.init(title: "Cancel", style: .destructive), .init(title: "Done", style: .default, handler: { _ in
                        self.saveTitle(for: prefs, with: title, completion: completion)
                    })])
                }
            }
        }
    }
    
    func deleteNotificationPreference(preference: NotificationPreferences) {
        var title = "this"
        if let pref = self.preferencesArray.first(where: { $0.id == preference.id }) {
            title = "your \(pref.title)"
        }
        SwiftUIAlert.show(title: "Confirm Deletion", message: "Are you sure that you want to delete \(title) schedule?", preferredStyle: .alert, actions: [.init(title: "Cancel", style: .destructive), .init(title: "Yes", style: .default, handler: { _ in
            if let index = self.preferencesArray.firstIndex(where: { $0.id == preference.id }) {
                self.preferencesArray.remove(at: index)
                for bridge in ContentViewModel.shared.allBridges {
                    let sortedBridgesIndex = ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]?.firstIndex(where: { $0.id == bridge.id })
                    if let sortedBridgesIndex, !(self.preferencesArray.map({ $0.bridgeIds }).joined()).contains(bridge.id) {
                        self.removeSubscription(for: ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]![sortedBridgesIndex])
                    }
                }
            }
        })])
    }
    
    private func adjustTitleForDuplicates(for startTitle: String, completion: @escaping (String) -> Void) {
        var title = startTitle {
            didSet {
                if !self.preferencesArray.contains(where: { $0.title == title }) {
                    completion(title)
                }
            }
        }
        if let slice = title.slice(from: " (", to: ")") {
            title = title.replacingOccurrences(of: " (\(slice))", with: "")
        }
        if !self.preferencesArray.contains(where: { $0.title == title }) {
            completion(title)
        } else {
            while self.preferencesArray.contains(where: { $0.title == title }) {
                if let slice = title.slice(from: " (", to: ")"), let sliceAsNumber = Int(slice.replacingOccurrences(of: "copy", with: "")) {
                    title = "\(title.replacingOccurrences(of: " (\(slice))", with: "")) (\(sliceAsNumber+1))"
                } else {
                    title.append(" (2)")
                }
            }
        }
    }
    
    private func duplicateTitleAlert(for duplicateTitle: String, onDone completion: @escaping (_ title: String) -> Void) {
        var title = duplicateTitle
        SwiftUIAlert.textfieldShow(title: "Duplicate Name", message: "You can't have more than one notification schedule with the same name.", preferredStyle: .alert, textfield: .init(text: Binding(get: {
            return title
        }, set: { newValue in
            title = newValue
        }), placeholder: "Schedule Name"), actions: [.init(title: "Cancel", style: .destructive), .init(title: "Done", style: .default, handler: { _ in
            if self.preferencesArray.contains(where: { $0.title == title }) {
                self.duplicateTitleAlert(for: title, onDone: completion)
            } else {
                completion(title)
            }
        })])
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func isInt() -> Bool {
        if Int(self) != nil {
            return true
        } else {
            return false
        }
    }
}
