//
//  NotificationService.swift
//  NotificationService
//
//  Created by Morris Richman on 12/5/22.
//

import UserNotifications
import FirebaseMessaging

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        guard let bestAttemptContent = bestAttemptContent else { return }
        
        do {
            enum throwError: Error {
                case fileDoesNotExist
                case preferenceDoesNotExist
            }
            if let bundlePath = Bundle.main.url(forResource: "NotificationPreferences", withExtension: "json") {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let preferencesArray = try jsonDecoder.decode([NotificationPreferences].self, from: Data(contentsOf: bundlePath))
                
                if let day = Day.currentDay(),
                   let bridgeId = request.content.userInfo["bridge_id"] as? String,
                   let preferences = preferences.first(where: { pref in
                       pref.days.contains(day) && currentTimeIsBetween(startTime: pref.startTime, endTime: pref.endTime) && pref.bridgeIds.contains(bridgeId)
                   }) {
                    removeOldNotifications {
                        pushNotification(preferences: preferences)
                    }
                } else {
                    throw throwError.preferenceDoesNotExist
                }
            } else {
                throw throwError.fileDoesNotExist
            }
        } catch {
//            removeOldNotifications {
//                pushNotification()
//            }
        }
    }
    
    func pushNotification(preferences: NotificationPreferences) {
        bestAttemptContent.categoryIdentifier = request.content.title
        if #available(iOSApplicationExtension 15.0, *) {
            switch preferences.notificationPriority {
            case .timeSensitive: bestAttemptContent.interruptionLevel = .timeSensitive
            case .normal: bestAttemptContent.interruptionLevel = .active
            case .silent: bestAttemptContent.interruptionLevel = .passive
            }
        }
        
        FIRMessagingExtensionHelper().populateNotificationContent(
            bestAttemptContent,
            withContentHandler: contentHandler)
    }
    
    func removeOldNotifications(then completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().getDeliveredNotifications { deliveredNotifications in
            if deliveredNotifications.isEmpty {
                complete()
            } else {
                let filteredNotifications = deliveredNotifications.filter { getNotification in
                    getNotification.request.content.body.removeBridgeStatus() == bestAttemptContent.body.removeBridgeStatus()
                }
                for notification in filteredNotifications {
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                    if notification == filteredNotifications.last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func currentTimeIsBetween(startTime: String, endTime: String) -> Bool {
        guard let start = Formatter.today.date(from: startTime),
              let end = Formatter.today.date(from: endTime) else {
            return false
        }
        return DateInterval(start: start, end: end).contains(Date())
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
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
    func removeBridgeStatus() -> String {
        return self.replacingOccurrences(of: "up", with: "").replacingOccurrences(of: "down", with: "").replacingOccurrences(of: "unknown", with: "")
    }
}

struct NotificationPreferences: Codable, Identifiable, Equatable {
    let id = UUID()
    let days: [Day]
    let startTime: String
    let endTime: String
    let notificationPriority: NotificationPriority
    let bridgeIds: [String]
    
    init(days: [Day], startTime: String, endTime: String, notificationPriority: NotificationPriority, bridgeIds: [String]) {
        self.days = days
        self.startTime = startTime
        self.endTime = endTime
        self.notificationPriority = notificationPriority
        self.bridgeIds = bridgeIds
    }
}

enum NotificationPriority: String, CaseIterable {
    case timeSensitive = "time sensitive"
    case normal = "normal"
    case silent = "silent"
}

enum Day: String, CaseIterable, Codable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    static func currentDay() -> Self? {
        Self(rawValue: Date().dayOfWeek())
    }
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).lowercased()
    }
}

extension Formatter {
    static let today: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.defaultDate = Calendar.current.startOfDay(for: Date())
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
    }()
}
