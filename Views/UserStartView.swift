//
//  StartViewUser.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-16.
//

import SwiftUI
import FirebaseAuth

struct UserStartView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var errorMessage: String? // @State to hold the error message
    
    init() {
        UserManagerModel.shared.userType = 1
    }
    
    var body: some View {
        VStack {
            if authViewModel.isSignedIn {
                TabView {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                    
                    MapView()
                        .tabItem {
                            Image(systemName: "map")
                            Text("Map")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                    
                    DailyDealsView() // new button
                        .tabItem {
                            Image(systemName: "tag")
                            Text("Deals")
                        }
                    
                    
                }
            } else {
                SignInView(signedIn: $authViewModel.isSignedIn, userType: .constant(nil), errorMessage: $errorMessage)
            }
        }
        .onAppear {
            checkUserLoggedInStatus()
        }
    }
    
    private func checkUserLoggedInStatus() {
        if Auth.auth().currentUser != nil {
            authViewModel.isSignedIn = true
        } else {
            authViewModel.isSignedIn = false
            errorMessage = "User not signed in."
        }
    }
}
