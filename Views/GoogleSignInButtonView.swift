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
    
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Sign in with Google", for: .normal)
        button.setTitleColor(.black, for: .normal) // Black text for classic Google button
        button.backgroundColor = .white // White background for classic Google button
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.addTarget(context.coordinator, action: #selector(Coordinator.signInWithGoogle), for: .touchUpInside)
        
        let googleIcon = UIImageView(image: UIImage(named: "google_logo")) // Replace with your Google logo image name
        googleIcon.contentMode = .scaleAspectFit
        googleIcon.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(googleIcon)
        button.bringSubviewToFront(googleIcon)
        
        NSLayoutConstraint.activate([
            googleIcon.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 12),
            googleIcon.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            googleIcon.widthAnchor.constraint(equalToConstant: 24),
            googleIcon.heightAnchor.constraint(equalToConstant: 24),
            
            button.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {}
    
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
            guard GIDSignIn.sharedInstance.configuration?.clientID != nil else {
                print("Client ID is nil")
                return
            }
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
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
                        let userType = 1
                        UserManagerModel.shared.userType = 1
                        
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
