//
//  ContentView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-13.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

struct ContentView: View {
    @State private var signedIn = false
    @State private var userType: Int? = nil

    var body: some View {
        if !signedIn {
            SignInView(signedIn: $signedIn, userType: $userType)
        } else {
            if let userType = userType {
                if userType == 1 {
                    StartViewUser(signedIn: $signedIn)
                } else if userType == 2 {
                    FoodTruckViewModelProvider { viewModel in
                        FoodTruckProfileView(viewModel: viewModel)
                    }
                } else {
                    Text("Unknown user type")
                }
            } else {
                Text("Loading...")
            }
        }
    }
}

struct FoodTruckViewModelProvider<Content: View>: View {
    @StateObject private var viewModel = FoodTruckViewModel()
    let content: (FoodTruckViewModel) -> Content

    var body: some View {
        content(viewModel)
    }
}

#Preview {
    ContentView()
}



