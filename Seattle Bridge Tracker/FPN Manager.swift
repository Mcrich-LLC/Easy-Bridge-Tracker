//
//  FPN Manager.swift
//  Pickt
//
//  Created by Morris Richman on 10/9/21.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    // MARK: Setup Function
    func setupFPN(application: UIApplication) {
        // set messaging delegate
        Messaging.messaging().delegate = self
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // register for notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { success, error in
                if success && error == nil {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                } else {
                    ConsoleManager.printStatement("Notifications request auth error: \(String(describing: error))")
                }
            }
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    // MARK: Recieve Message
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
    -> UIBackgroundFetchResult {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // ConsoleManager.printStatement message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            ConsoleManager.printStatement("Message ID: \(messageID)")
        }
        
        // ConsoleManager.printStatement full message.
        ConsoleManager.printStatement(userInfo)
        
        return UIBackgroundFetchResult.newData
    }
    
    // MARK: Register FCM
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        ConsoleManager.printStatement("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        ConsoleManager.printStatement("APNs token retrieved: \(deviceToken)")
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        ConsoleManager.printStatement("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    // MARK: Handle Message
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // ConsoleManager.printStatement message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            ConsoleManager.printStatement("Message ID: \(messageID)")
        }
        // ConsoleManager.printStatement full message.
        ConsoleManager.printStatement("userInfo = \(userInfo)")
        
        // Change this to your preferred presentation option
        return [[.banner, .list, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        // ConsoleManager.printStatement message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            ConsoleManager.printStatement("Message ID: \(messageID)")
        }
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // ConsoleManager.printStatement full message.
        ConsoleManager.printStatement(userInfo)
    }
}
