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
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
