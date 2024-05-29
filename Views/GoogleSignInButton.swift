//
//  GoogleSignInButton.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-16.
//


import SwiftUI
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

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
        var db = Firestore.firestore()

        init(signedIn: Binding<Bool>) {
            _signedIn = signedIn
        }

        @objc func signInWithGoogle() {
            guard let clientID = GIDSignIn.sharedInstance.configuration?.clientID else {
                print("Client ID is nil")
                return
            }

            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                print("Root view controller is nil")
                return
            }

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    return
                }

                guard let signInResult = signInResult else {
                    print("Sign-in result is nil")
                    return
                }

                let user = signInResult.user

                let idToken = user.idToken?.tokenString
                let accessToken = user.accessToken.tokenString

                let credential = GoogleAuthProvider.credential(withIDToken: idToken!, accessToken: accessToken)

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase sign-in error: \(error.localizedDescription)")
                        return
                    }

                    if let user = authResult?.user {
                        self.signedIn = true
                        let uid = user.uid
                        let email = user.email ?? "No Email"
                        let username = user.displayName ?? "No Name"
                        let userType = 1 // Assuming a default userType. Adjust as needed.
                        UserManager.shared.userType = 1

                        self.saveUserProfile(uid: uid, username: username, email: email, userType: userType)
                    }
                }
            }
        }

        func saveUserProfile(uid: String, username: String, email: String, userType: Int) {
            let userData: [String: Any] = [
                "username": username,
                "email": email,
                "usertype": userType,
                "uid": uid
            ]

            db.collection("users").document(uid).setData(userData) { error in
                if let error = error {
                    print("Error saving user profile: \(error.localizedDescription)")
                } else {
                    print("User profile saved successfully")
                }
            }
        }
    }
}

