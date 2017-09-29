//
//  AppDelegate.swift
//  FireBots
//
//  Created by Thanakorn Amnuaywiboolpol on 9/29/2560 BE.
//  Copyright © 2560 Mobile Computing Lab. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseDatabase
import FirebaseDynamicLinks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var mainViewController: MainViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Setup Firebase
        FirebaseApp.configure()
        
        // Enable Offline Capabilities
//        Database.database().isPersistenceEnabled = true
//        let userRef = Database.database().reference(withPath: "user")
//        userRef.keepSynced(true)
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self as MessagingDelegate
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        // [END register_for_notifications]
        
        // Before setting up UI
        Style.initialiseGlobalAppearance()
        
        // Setup main view controller
        let splashScreenStoryboard = UIStoryboard(name: "SplashScreen", bundle: Bundle.main)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        mainViewController = MainViewController(viewController: splashScreenStoryboard.instantiateInitialViewController()!)
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    // [START DynamicLink]
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            let handleLink = DynamicLinks.dynamicLinks()?.handleUniversalLink(incomingURL, completion: { (dynamicLink, error) in
                if let dynamicLink = dynamicLink, let url = dynamicLink.url {
                    print("Your Dynamic Link parameter: \(dynamicLink)")
                    print("Your Dynamic Link url: \(url)")
                    self.mainViewController?.dynamicLinkURL = url
                }
                else {
                    // Check for errors
                }
            })
            return handleLink!
        }
        return false
    }
    // [END DynamicLink]
    
    // [START Notification]
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
            receiveNotification(notification: userInfo)
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
            receiveNotification(notification: userInfo)
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
        
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func receiveNotification(notification: [AnyHashable: Any]) {
        // Detect application state
        let state: UIApplicationState = UIApplication.shared.applicationState
        if state == .active {
            if let notificationAPS = notification["aps"] as? NSDictionary {
                let body = (notificationAPS["alert"] as! NSDictionary)["body"] as? String ?? ""
                if body != "" {
                    notificationForeground(notification: notification, title: nil, body: body)
                }
            }
        }
        else if state == .inactive {
            notificationBackground(notification: notification)
        }
        else if state == .background {
            notificationBackground(notification: notification)
        }
    }
    
    func notificationBackground(notification: [AnyHashable: Any]) {
        if let user = Auth.auth().currentUser {
            if FBUser.uid != user.uid {
                FBUser.uid = user.uid
            }
            if let type = notification[NotificationType.type] as? String {
//                switch type {
//                case NotificationType.paymentConfirmed:
//                    if let bookingID = notification[NotificationExtra.bookingID] as? String {
//                        self.mainViewController?.bookingID = bookingID
//                        self.mainViewController?.forceSwapToTabBarController(selectedIndex: 1)
//                    }
//                    break
//                case NotificationType.newMessage:
//                    if let activityID = notification[NotificationExtra.activityID] as? String {
//                        self.mainViewController?.activityID = activityID
//                        self.mainViewController?.forceSwapToTabBarController(selectedIndex: 2)
//                    }
//                    break
//                default:
//                    self.mainViewController?.forceSwapToTabBarController()
//                    break
//                }
            }
            else {
                self.mainViewController?.forceSwapToTabBarController()
            }
        }
    }
    
    func notificationForeground(notification: [AnyHashable: Any], title: String?, body: String) {
        if let type = notification[NotificationType.type] as? String {
//            switch type {
//            case NotificationType.paymentConfirmed:
//                if let bookingID = notification[NotificationExtra.bookingID] as? String {
//                    self.mainViewController?.showAlert(title: title, message: body, buttonText: NSLocalizedString("View ticket button", comment: ""), completion: { (_) in
//                        self.mainViewController?.bookingID = bookingID
//                        self.mainViewController?.forceSwapToTabBarController(selectedIndex: 1)
//                    })
//                }
//                break
//            case NotificationType.newMessage:
//                self.mainViewController?.refreshBadgeNumber()
//                break
//            default:
//                break
//            }
        }
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // TODO: Handle data of notification
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
            receiveNotification(notification: userInfo)
        }
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // TODO: Handle data of notification
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
            receiveNotification(notification: userInfo)
        }
        
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
        receiveNotification(notification: remoteMessage.appData)
        
    }
    // [END ios_10_data_message]
}

