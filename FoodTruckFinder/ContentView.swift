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
        Group {
            if signedIn {
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
            } else {
                SignInView(signedIn: $signedIn, userType: $userType)
            }
        }
        .onAppear {
            checkUserLoggedInStatus()
        }
    }

    private func checkUserLoggedInStatus() {
        if let user = Auth.auth().currentUser {
            self.signedIn = true
            fetchUserType(user: user)
        } else {
            self.signedIn = false
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
    }
}

#Preview {
    ContentView()
}




