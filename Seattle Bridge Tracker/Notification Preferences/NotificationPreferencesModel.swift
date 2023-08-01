//
//  NotificationPreferencesModel.swift
//  NotificationService
//
//  Created by Morris Richman on 3/26/23.
//

import Foundation
import UserNotifications
import Firebase
import FirebaseAnalytics
import Mcrich23_Toolkit
import SwiftUI
import SwiftUIAlert

final class NotificationPreferencesModel: ObservableObject {
    static let shared = NotificationPreferencesModel()
    @Published var preferencesArray: [NotificationPreferences] = [] {
        didSet {
            setPreferences()
        }
    }
    let fileName = "NotificationPreferences.json"
    let maxNumber = 6
    
    init() {
        getPreferences()
    }
    let db = Firestore.firestore()
    
    @Published var notificationsAllowed = false
    
    func addSubscription(for bridge: Bridge) {
        Utilities.checkNotificationPermissions { notificationsAreAllowed in
            if notificationsAreAllowed {
                Analytics.setUserProperty("subscribed", forName: ContentViewModel.shared.bridgeName(bridge: bridge))
                Analytics.logEvent("subscribed_to_bridge", parameters: ["subscribed" : ContentViewModel.shared.bridgeName(bridge: bridge)])
                let index = ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]?.firstIndex(where: { bridgeArray in
                    bridgeArray.name == bridge.name
                })!
                ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]![index!].subscribed = true
                UserDefaults.standard.set(true, forKey: "\(ContentViewModel.shared.bridgeName(bridge: bridge)).subscribed")
            }
        }
    }
    
    func removeSubscription(for bridge: Bridge, preference: NotificationPreferences) {
        Utilities.checkNotificationPermissions { notificationsAreAllowed in
            if notificationsAreAllowed {
                let allBridgeIds = self.preferencesArray.map { $0.bridgeIds }.joined()
                if !allBridgeIds.contains(bridge.id) {
                    Analytics.setUserProperty("unsubscribed", forName: ContentViewModel.shared.bridgeName(bridge: bridge))
                    Analytics.logEvent("unsubscribed_to_bridge", parameters: ["unsubscribed" : ContentViewModel.shared.bridgeName(bridge: bridge)])
                    if let index = ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]?.firstIndex(where: { bridgeArray in
                        bridgeArray.name == bridge.name
                    }) {
                        ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]![index].subscribed = false
                        if let deviceID = Utilities.deviceID {
                            self.db.collection("Directory").document(bridge.id.uuidString).setData([
                                "subscribed_users" : FieldValue.arrayRemove(["\(deviceID)/\(preference.id.uuidString)"])
                            ], merge: true)
                        }
                    }
                    UserDefaults.standard.set(false, forKey: "\(ContentViewModel.shared.bridgeName(bridge: bridge)).subscribed")
                }
            }
        }
    }
    
    func updateBackendPreferences() {
        guard let deviceID = Utilities.deviceID else { return }
        for pref in preferencesArray {
            db.collection(deviceID).document(pref.id.uuidString).setData([
                "id": pref.id.uuidString,
                "title": pref.title,
                "days": (pref.days ?? []).map({ $0.rawValue }),
                "is_all_day": pref.isAllDay,
                "start_time": pref.startTime,
                "end_time": pref.endTime,
                "notification_priority": pref.notificationPriority.rawValue,
                "bridge_ids": pref.bridgeIds.map({ $0.uuidString }),
                "is_active": pref.isActive,
                "device_id": Messaging.messaging().fcmToken ?? "nil",
                "isBeta": Utilities.appType != .AppStore
            ], merge: true)
            for bridge in pref.bridgeIds {
                db.collection("Directory").document(bridge.uuidString).setData([
                    "subscribed_users" : FieldValue.arrayUnion(["\(deviceID)/\(pref.id.uuidString)"])
                ], merge: true)
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
                updateBackendPreferences()
            } else {
                throw throwError.unableToWrite
            }
        } catch {
            print("Unable to write json")
        }
    }
    
    func getPreferences() {
        if Utilities.isFastlaneRunning {
            getDemoPreferences()
        } else {
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
                    updateBackendPreferences()
                } else {
                    throw throwError.fileDoesNotExist
                }
            } catch {
                print("NotificationPreferences.json doesn't exist")
            }
        }
    }
    
    private func getDemoPreferences() {
        do {
            enum throwError: Error {
                case fileDoesNotExist
            }
            if let filePath = Bundle.main.url(forResource: "NotificationPreferencesExample", withExtension: "json") {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let preferencesArray = try jsonDecoder.decode([NotificationPreferences].self, from: Data(contentsOf: filePath))
                
                self.preferencesArray = preferencesArray
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
            self.duplicateTitleAlert(for: title, hasEditor: true) { newTitle in
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
    
    func saveUpdatedTitle(for preferences: NotificationPreferences, with title: String, showTextEditorIfDuplicate showEditor: Bool, completion: @escaping () -> Void) {
        if self.preferencesArray.contains(where: { $0.title == title && $0.id != preferences.id }) {
            self.duplicateTitleAlert(for: title, hasEditor: showEditor) { newTitle in
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
    
    func checkIfMaximumNumber(completionIfAble completion: @escaping () -> Void) {
        if self.preferencesArray.count >= self.maxNumber {
            SwiftUIAlert.show(title: "Uh Oh", message: "You can only have \(maxNumber) notification schedules. Please delete one to add another.", preferredStyle: .alert, actions: [.ok()])
        } else {
            completion()
        }
    }
    
    func updateTitleAlert(for preferences: NotificationPreferences) {
        var title = preferences.title
        SwiftUIAlert.textfieldShow(title: "Update Schedule Name", message: "Update the name of this notification schedule", preferredStyle: .alert, textfield: .init(text: Binding(get: {
            return title
        }, set: { newValue in
            title = newValue
        }), placeholder: "Schedule Name"), actions: [.init(title: "Cancel", style: .destructive), .init(title: "Done", style: .default, handler: { _ in
            self.saveUpdatedTitle(for: preferences, with: title, showTextEditorIfDuplicate: true) {}
        })])
    }
    
    func createNotificationPreferenceAlert(onDone completion: @escaping () -> Void) {
        Utilities.checkNotificationPermissions { notificationsAreAllowed in
            if notificationsAreAllowed {
                self.checkIfMaximumNumber {
                    let defaultPrefs = NotificationPreferences.defaultPreferences
                    var title = defaultPrefs.title
                    self.adjustTitleForDuplicates(for: defaultPrefs.title) { newTitle in
                        title = newTitle
                    }
                    SwiftUIAlert.textfieldShow(title: "Create Notification Schedule", message: "Set the name of this notification schedule", preferredStyle: .alert, textfield: .init(text: Binding(get: {
                        return title
                    }, set: { newValue in
                        title = newValue
                    }), placeholder: "Schedule Name"), actions: [.init(title: "Cancel", style: .destructive), .init(title: "Done", style: .default, handler: { _ in
                        self.saveTitle(for: defaultPrefs, with: title, completion: completion)
                    })])
                }
            }
        }
    }
    
    func createNotificationPreferenceAlert(basedOn preferences: NotificationPreferences, onDone completion: @escaping () -> Void) {
        Utilities.checkNotificationPermissions { notificationsAreAllowed in
            
            if notificationsAreAllowed {
                self.checkIfMaximumNumber {
                    let defaultPrefs = preferences
                    var title = preferences.title
                    self.adjustTitleForDuplicates(for: preferences.title) { newTitle in
                        title = newTitle
                    }
                    SwiftUIAlert.textfieldShow(title: "Create Notification Schedule", message: "Set the name of this notification schedule", preferredStyle: .alert, textfield: .init(text: Binding(get: {
                        return title
                    }, set: { newValue in
                        title = newValue
                    }), placeholder: "Schedule Name"), actions: [.init(title: "Cancel", style: .destructive), .init(title: "Done", style: .default, handler: { _ in
                        self.saveTitle(for: defaultPrefs, with: title, completion: completion)
                    })])
                }
            }
        }
    }
    
    func duplicateNotificationPreferenceAlert(basedOn preferences: NotificationPreferences, onDone completion: @escaping () -> Void) {
        Utilities.checkNotificationPermissions { notificationsAreAllowed in
            if notificationsAreAllowed {
                self.checkIfMaximumNumber {
                    var prefs = preferences
                    prefs.id = UUID()
                    var title = preferences.title
                    self.adjustTitleForDuplicates(for: preferences.title) { newTitle in
                        title = newTitle
                        SwiftUIAlert.textfieldShow(title: "Duplicate Notification Schedule", message: "Set the name of this notification schedule", preferredStyle: .alert, textfield: .init(text: Binding(get: {
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
                        self.removeSubscription(for: ContentViewModel.shared.sortedBridges[bridge.bridgeLocation]![sortedBridgesIndex], preference: preference)
                    }
                }
                if let deviceID = Utilities.deviceID {
                    self.db.collection(deviceID).document(preference.id.uuidString).delete()
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
    
    private func duplicateTitleAlert(for duplicateTitle: String, hasEditor: Bool, onDone completion: @escaping (_ title: String) -> Void) {
        var title = duplicateTitle
        
        if !hasEditor {
            SwiftUIAlert.show(title: "Duplicate Name", message: "You can't have more than one notification schedule with the same name", preferredStyle: .alert, actions: [.init(title: "Done", style: .default)])
        } else {
            SwiftUIAlert.textfieldShow(title: "Duplicate Name", message: "You can't have more than one notification schedule with the same name. Please fix it below:", preferredStyle: .alert, textfield: .init(text: Binding(get: {
                return title
            }, set: { newValue in
                title = newValue
            }), placeholder: "Schedule Name"), actions: [.init(title: "Cancel", style: .destructive), .init(title: "Done", style: .default, handler: { _ in
                if self.preferencesArray.contains(where: { $0.title == title }) {
                    self.duplicateTitleAlert(for: title, hasEditor: true, onDone: completion)
                } else {
                    completion(title)
                }
            })])
        }
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
