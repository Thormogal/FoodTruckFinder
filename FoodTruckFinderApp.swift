//
//  FoodTruckFinderApp.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-13.
//



import UIKit
import FirebaseCore
import GoogleSignIn
import SwiftUI


class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("Found GoogleService-Info.plist at: \(path)")
        } else {
            print("Could not find GoogleService-Info.plist")
        }
        
        // configure Firebase
        FirebaseApp.configure()
        
        // ConfigureGoogle Sign-In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "292893742509-pfpubpufkmfdcak4909hmqrgbfg2bptv.apps.googleusercontent.com")

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
