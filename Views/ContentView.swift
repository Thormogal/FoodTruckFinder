//
//  ContentView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-13.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                if let userType = authViewModel.userType {
                    if userType == 1 {
                        UserStartView()
                    } else if userType == 2 {
                        FoodTruckViewModelProvider { viewModel in
                            FoodTruckProfileView(viewModel: viewModel, userType: userType)
                        }
                    }
                } else {
                    Text("Loading user type...")
                }
            } else {
                SignInView(signedIn: $authViewModel.isSignedIn, userType: $authViewModel.userType, errorMessage: $errorMessage)
            }
        }
        .onAppear {
            checkUserLoggedInStatus()
        }
    }

    private func checkUserLoggedInStatus() {
        if let user = Auth.auth().currentUser {
            self.authViewModel.isSignedIn = true
            authViewModel.fetchUserType(user: user)
        } else {
            self.authViewModel.isSignedIn = false
        }
    }
}

struct FoodTruckViewModelProvider<Content: View>: View {
    @StateObject private var viewModel = FoodTruckViewModel()
    let content: (FoodTruckViewModel) -> Content

    var body: some View {
        content(viewModel)
            .onAppear {
                if let userId = Auth.auth().currentUser?.uid {
                    viewModel.fetchFoodTruckData(by: userId)
                }
            }
    }
}

#Preview {
    ContentView()
}
