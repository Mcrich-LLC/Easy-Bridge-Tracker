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
        func complete() {
            bestAttemptContent.categoryIdentifier = request.content.title
            if let RawInterruptionLevel = request.content.userInfo["interruption_level"] as? String {
                let interruptionLevel = UInt(RawInterruptionLevel) ?? 1
                print("interruptionLevel = \(interruptionLevel)")
                if #available(iOSApplicationExtension 15.0, *) {
                    bestAttemptContent.interruptionLevel = .init(rawValue: interruptionLevel) ?? .active
                } else {
                    // Fallback on earlier versions
                }
            } else {
                print("interruption_level = nil")
            }
            
            FIRMessagingExtensionHelper().populateNotificationContent(
                bestAttemptContent,
                withContentHandler: contentHandler)
        }
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
                            complete()
                        }
                    }
                }
            }
        }
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
