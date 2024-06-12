//
//  AuthViewModel.swift
//  FoodTruckFinder
//
//  Created by A.S on 2024-05-28.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift


class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var userType: Int?

    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { _, user in
            self.isSignedIn = user != nil
            if let user = user {
                self.fetchUserType(user: user)
            }
        }
    }

    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

     func fetchUserType(user: User) {
        let userId = user.uid
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                self.userType = document.data()?["usertype"] as? Int
            } else {
                print("Error fetching user type: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
