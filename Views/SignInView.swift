//
//  SignInView.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-20.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase

struct SignInView: View {
    @Binding var signedIn: Bool
    @Binding var userType: Int?
    var auth = Auth.auth()
    @State private var password: String = ""
    @State private var email: String = ""
    @State private var errorMessage: String?
    
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
                signInAndFetchUserType { type in
                    if let type = type {
                        self.userType = type
                        self.signedIn = true
                    } else {
                        // Handle the error or unknown user type
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
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        //                .onAppear {
        //                    if Auth.auth().currentUser != nil {
        //                        signInAndFetchUserType { type in
        //                            if let type = type {
        //                                self.userType = type
        //                                self.signedIn = true
        //                            } else {
        //                                // Handle the error or unknown user type
        //                            }
        //                        }
        //                    }
        //                }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    func signInAndFetchUserType(completion: @escaping (Int?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(nil)
            } else {
                if let user = authResult?.user {
                    fetchUserType(userID: user.uid) { type in
                        completion(type)
                    }
                } else {
                    print("No user found after sign-in")
                    completion(nil)
                }
            }
        }
    }
    
    func fetchUserType(userID: String, completion: @escaping (Int?) -> Void) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        
        usersCollection.document(userID).getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(), let userType = data["usertype"] as? Int {
                    completion(userType)
                } else {
                    print("User document does not contain 'usertype' field")
                    completion(nil)
                }
            } else {
                print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }
    }
}
