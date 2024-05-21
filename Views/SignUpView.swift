//
//  SignUpView.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-20.
//
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import Foundation
struct SignUpView: View {
    @Binding var signedIn: Bool
    var auth = Auth.auth()
    var db = Firestore.firestore()
    @State private var password: String = ""
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var selectedRole = "User"  

    let roles = ["User", "Food Truck Owner"]

    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text("Username")
                    .font(.headline)
                TextField("Enter your username", text: $username)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                Text("Email")
                    .font(.headline)
                TextField("Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                Text("Password")
                    .font(.headline)
                SecureField("Enter your password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                Text("Role")
                    .font(.headline)
                Picker("Select your role", selection: $selectedRole) {
                    ForEach(roles, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            
            Button(action: {
                auth.createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        print("Error creating account: \(error.localizedDescription)")
                    } else {
                        if let user = authResult?.user {
                            let changeRequest = user.createProfileChangeRequest()
                            changeRequest.displayName = username
                            changeRequest.commitChanges { error in
                                if let error = error {
                                    print("Error setting username: \(error.localizedDescription)")
                                } else {
                                    let userType = selectedRole == "User" ? 1 : 2
                                    saveUserProfile(uid: user.uid, username: username, email: email, userType: userType)
                                    signedIn = true
                                }
                            }
                        }
                    }
                }
            }, label: {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            })
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
