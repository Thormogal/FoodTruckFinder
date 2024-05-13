//
//  FirebasePlist.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-13.
//

import Foundation
import Firebase

func loadAndCombinePlists() -> FirebaseOptions? {
    let defaultPlist = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
    let secretPlist = Bundle.main.path(forResource: "GoogleService-Info-Secrets", ofType: "plist")
    
    var defaultOptions: FirebaseOptions?
    var secretOptions: FirebaseOptions?

    if let defaultPlist = defaultPlist {
        defaultOptions = FirebaseOptions(contentsOfFile: defaultPlist)
    }
    
    if let secretPlist = secretPlist {
        secretOptions = FirebaseOptions(contentsOfFile: secretPlist)
    }
    
    // Assume APIKey is in the secrets plist
    defaultOptions?.apiKey = secretOptions?.apiKey ?? defaultOptions?.apiKey

    // Add other properties if necessary, such as projectID, clientID, etc.
    
    return defaultOptions
}

func configureFirebase() {
    if let options = loadAndCombinePlists() {
        FirebaseApp.configure(options: options)
    } else {
        print("Failed to load Firebase configuration.")
    }
}
