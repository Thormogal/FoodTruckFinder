//
//  StartViewUser.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-16.
//

import Foundation
import SwiftUI
import FirebaseAuth
struct StartViewUser : View {
    @State var signedIn = false
    
    var body: some View {
        VStack {
            if signedIn {
                // Visa den vy som användare ska se när de är inloggade
                Text("Hello, user!")
                Button(action: {
                    do {
                        try Auth.auth().signOut()
                        signedIn = false  // Uppdatera din signedIn state för att återspegla att användaren inte längre är inloggad
                    } catch let signOutError as NSError {
                        print("Error signing out: \(signOutError)")
                    }
                }, label: {
                    Text("Sign Out")
                })
            } else {
                // Visa SignInView om användaren inte är inloggad
                SignInView(signedIn: $signedIn)
            }
        }
    }
}
