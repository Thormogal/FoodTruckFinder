//
//  StartViewUser.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-16.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct StartViewUser: View {
    @StateObject private var authViewModel = AuthViewModel()
    init() {
        UserManager.shared.userType = 1
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
                }
            } else {
                SignInView(signedIn: $authViewModel.isSignedIn, userType: .constant(nil))
            }
        }
    }
}
