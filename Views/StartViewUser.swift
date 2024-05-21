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
//                Text("Hello, user!")
//                Button(action: {
//                    do {
//                        try Auth.auth().signOut()
//                        signedIn = false
//                    } catch let signOutError as NSError {
//                        print("Error signing out: \(signOutError)")
//                    }
//                }, label: {
//                    Text("Sign Out")
//                })
            } else {
                //SignInView(signedIn: $signedIn,userType: <#T##Binding<Int?>#>)
            }
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
        }


    }
}
