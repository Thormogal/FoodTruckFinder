//
//  SignInView.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-20.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignInView: View {
    @Binding var signedIn: Bool
    @Binding var userType: Int?
    @Binding var errorMessage: String?
    var auth = Auth.auth()
    @State private var password: String = ""
    @State private var email: String = ""
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("food_background")
                    .resizable()
                    .blur(radius: 3)
                    .ignoresSafeArea()
                
                VStack {
                    VStack {
                        GeometryReader { geo in
                            Text("FoodTruckFinder")
                                .font(.system(size: 50, weight: .semibold))
                                .frame(maxWidth: geo.size.width)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                                .scaledToFit()
                        }
                        .frame(height: 60)
                        .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Email")
                                .font(.headline)
                            TextField("Enter your email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            
                            Text("Password")
                                .font(.headline)
                            
                            ZStack {
                                if isPasswordVisible {
                                    TextField("Enter your password", text: $password)
                                        .padding()
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                } else {
                                    SecureField("Enter your password", text: $password)
                                        .padding()
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                }
                                
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 10)
                                    }
                                }
                            }
                        }
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }
                        
                        HStack {
                            Text("Don't have an account?")
                                .font(.footnote)
                            NavigationLink(destination: SignUpView(signedIn: $signedIn)) {
                                Text("Sign Up")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 10)
                        
                        Button(action: {
                            signInAndFetchUserType { type in
                                if let type = type {
                                    self.userType = type
                                    self.signedIn = true
                                } else {
                                    self.errorMessage = "Account not found or unknown error."
                                }
                            }
                        }, label: {
                            Text("Sign In")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }).shadow(radius: 5)
                    }
                    
                    GoogleSignInButton(signedIn: $signedIn)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
                .background(Color(.systemGroupedBackground).opacity(0.9))
                .cornerRadius(10)
                .frame(maxWidth: geometry.size.width * 0.9)
            }
        }
    }
    
    func signInAndFetchUserType(completion: @escaping (Int?) -> Void) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(nil)
            } else {
                if let user = authResult?.user {
                    fetchUserType(userID: user.uid) { type in
                        completion(type)
                    }
                } else {
                    self.errorMessage = "No user found after sign-in"
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
                    self.errorMessage = "User document does not contain 'usertype' field"
                    completion(nil)
                }
            } else {
                self.errorMessage = "Error fetching user document: \(error?.localizedDescription ?? "Unknown error")"
                completion(nil)
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(
            signedIn: .constant(false),
            userType: .constant(nil),
            errorMessage: .constant(nil)
        )
    }
}
