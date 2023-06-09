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
        
        do {
            enum throwError: Error {
                case fileDoesNotExist
                case preferenceDoesNotExist
            }
            if let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("NotificationPreferences.json") {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let preferencesArray = try jsonDecoder.decode([NotificationPreferences].self, from: Data(contentsOf: filePath))
                
                if let day = Day.currentDay(),
                   let bridgeId = request.content.userInfo["bridge_id"] as? String,
                   let preferences = preferencesArray.first(where: { pref in
                       (pref.days ?? []).contains(day) && (currentTimeIsBetween(startTime: pref.startTime, endTime: pref.endTime) || pref.isAllDay) && pref.bridgeIds.contains(UUID(uuidString: bridgeId)!) && pref.isActive
                   }) {
                    removeOldNotifications {
                        self.pushNotification(request: request, preferences: preferences)
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
    
    func pushNotification(request: UNNotificationRequest, preferences: NotificationPreferences) {
        guard let bestAttemptContent, let contentHandler else { return }
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
        guard let bestAttemptContent else { return }
        UNUserNotificationCenter.current().getDeliveredNotifications { deliveredNotifications in
            if deliveredNotifications.isEmpty {
                completion()
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
    func removeBridgeStatus() -> String {
        return self.replacingOccurrences(of: "up", with: "").replacingOccurrences(of: "down", with: "").replacingOccurrences(of: "unknown", with: "")
    }
}
