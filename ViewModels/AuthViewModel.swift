//
//  AuthViewModel.swift
//  FoodTruckFinder
//
//  Created by A.S on 2024-05-28.
//

import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { _, user in
            self.isSignedIn = user != nil
        }
    }
    
    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
