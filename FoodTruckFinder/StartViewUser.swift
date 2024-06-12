//
//  StartViewUser.swift
//  FoodTruckFinder
//
//  Created by Irfan Sarac on 2024-05-17.
//

import SwiftUI

struct StartViewUser: View {
    var body: some View {
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

struct StartViewUser_Previews: PreviewProvider {
    static var previews: some View {
        StartViewUser()
    }
}

