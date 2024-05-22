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
    @Binding var signedIn: Bool

    var body: some View {
        VStack {
            if signedIn {
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
                SignInView(signedIn: $signedIn, userType: .constant(nil))
            }
        }
    }
}

