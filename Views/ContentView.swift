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
    @State private var userType: Int? = nil
    
    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                if let userType = userType {
                    if userType == 1 {
                        StartViewUser()
                    } else if userType == 2 {
                        FoodTruckViewModelProvider { viewModel in
                            FoodTruckProfileView(viewModel: viewModel, userType: userType)
                        }
                    } else {
                        Text("Loading...")
                    }
                } else {
                    Text("Loading user type...")
                }
            } else {
                SignInView(signedIn: $authViewModel.isSignedIn, userType: $userType)
            }
        }
        .onAppear {
            checkUserLoggedInStatus()
        }
    }
    
    private func checkUserLoggedInStatus() {
        if let user = Auth.auth().currentUser {
            self.authViewModel.isSignedIn = true
            fetchUserType(user: user)
        } else {
            self.authViewModel.isSignedIn = false
        }
    }
    
    private func fetchUserType(user: User) {
        let userId = user.uid
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                self.userType = document.data()?["usertype"] as? Int
            } else {
                print("User does not exist or error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
            }
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
