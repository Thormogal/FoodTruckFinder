//
//  FirebasePlist.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-13.
//

import Foundation
import Firebase

func loadAndCombinePlists() -> FirebaseOptions? {
    guard let defaultPlistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
        print("Could not find GoogleService-Info.plist")
        return nil
    }
    
    guard let defaultOptions = FirebaseOptions(contentsOfFile: defaultPlistPath) else {
        print("Could not load Firebase options from GoogleService-Info.plist")
        return nil
    }
    
    return defaultOptions
}

func configureFirebase() {
    if let options = loadAndCombinePlists() {
        FirebaseApp.configure(options: options)
    } else {
        print("Failed to load Firebase configuration.")
    }
}
