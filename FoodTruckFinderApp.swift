//
//  FoodTruckFinderApp.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-13.
//



import UIKit
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Kontrollera om GoogleService-Info.plist kan hittas
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("Found GoogleService-Info.plist at: \(path)")
        } else {
            print("Could not find GoogleService-Info.plist")
        }
        
        // Konfigurera Firebase
        FirebaseApp.configure()
        
        // Konfigurera Google Sign-In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "292893742509-pfpubpufkmfdcak4909hmqrgbfg2bptv.apps.googleusercontent.com")
        
        // Registrera för pushnotiser
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
                print("Permission granted: \(granted)")
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()

        Messaging.messaging().delegate = self

        return true
    }
    
    override init() {
        UserManager.shared.userType = 0
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // UNUserNotificationCenterDelegate
    @available(iOS 10, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    // MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        // Skicka token till din server eller spara den lokalt
    }
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
