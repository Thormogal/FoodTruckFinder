//
//  SignInView.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-20.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import Foundation

struct SignInView: View {
    @Binding var signedIn: Bool
    var auth = Auth.auth()
    @State private var password: String = ""
    @State private var email: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 15) {
                Text("FoodTruckFinder")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
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
            }
            .padding(.horizontal, 20)
            
            Button(action: {
                auth.signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("Error signing in: \(error.localizedDescription)")
                    } else {
                        signedIn = true
                    }
                }
            }, label: {
                Text("Sign In")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            })
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            HStack {
                Text("Don't have an account?")
                NavigationLink(destination: SignUpView(signedIn: $signedIn)) {
                    Text("Sign Up")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 10)
            
            GoogleSignInButton(signedIn: $signedIn)
                .frame(height: 50)
                .padding(.top, 20)
                .padding(.horizontal, 20)
            
            Spacer()
        }
        .onAppear {
            if Auth.auth().currentUser != nil {
                signedIn = true
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
