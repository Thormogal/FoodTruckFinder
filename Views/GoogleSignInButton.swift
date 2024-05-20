//
//  GoogleSignInButton.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-16.
//


import Foundation
import SwiftUI
import GoogleSignIn
import FirebaseAuth

struct GoogleSignInButton: UIViewRepresentable {
    @Binding var signedIn: Bool
    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()
        button.style = .wide
        button.colorScheme = .dark
        button.addTarget(context.coordinator, action: #selector(Coordinator.signInWithGoogle), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(signedIn: $signedIn)
    }
    
    class Coordinator: NSObject {
        @Binding var signedIn: Bool
            
            init(signedIn: Binding<Bool>) {
                _signedIn = signedIn
            }
            
        @objc func signInWithGoogle() {
            guard let clientID = GIDSignIn.sharedInstance.configuration?.clientID else {
                print("Client ID is nil")
                return
            }
            
            // Get the top view controller
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                print("Root view controller is nil")
                return
            }
            
            
            // Start the sign-in flow
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                if let error = error {
                    // Handle error
                    print("Error signing in: \(error.localizedDescription)")
                    return
                }
                
                guard let signInResult = signInResult else {
                    print("Sign-in result is nil")
                    return
                }
                
                let user = signInResult.user
                
                // Fetch user's authentication tokens
                let idToken = user.idToken?.tokenString
                let accessToken = user.accessToken.tokenString
                
                // Create a Firebase credential with the tokens
                let credential = GoogleAuthProvider.credential(withIDToken: idToken!, accessToken: accessToken)
                
                // Sign in with Firebase
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase sign-in error: \(error.localizedDescription)")
                        return
                    }
                    
                    // User is signed in to Firebase
                    if let user = authResult?.user {
                        print("Firebase User ID: \(user.uid)")
                        print("Firebase Email: \(user.email ?? "No Email")")
                        self.signedIn = true
                    }
                }
                
                // Fetch user's profile information
                let userId = user.userID
                let fullName = user.profile?.name
                let givenName = user.profile?.givenName
                let familyName = user.profile?.familyName
                let email = user.profile?.email
                
                // Use these details in your app
                print("User ID: \(userId ?? "No User ID")")
                print("Full Name: \(fullName ?? "No Full Name")")
                print("Given Name: \(givenName ?? "No Given Name")")
                print("Family Name: \(familyName ?? "No Family Name")")
                print("Email: \(email ?? "No Email")")
            }
        }
    }
}
