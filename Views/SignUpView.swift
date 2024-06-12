//
//  SignUpView.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-20.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @Binding var signedIn: Bool
    @Binding var userType: Int?
    @State private var password: String = ""
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var selectedRole = "User"
    @State private var errorMessage: String? = nil
    var auth = Auth.auth()
    var db = Firestore.firestore()
    let roles = ["User", "Food Truck Owner"]

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 15) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }

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
                checkIfUserExists { exists in
                    if exists {
                        errorMessage = "Username or email already exists."
                    } else {
                        signUpUser()
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

    func checkIfUserExists(completion: @escaping (Bool) -> Void) {
        let usersRef = db.collection("users")

        usersRef.whereField("username", isEqualTo: username).getDocuments { usernameQuerySnapshot, error in
            if let error = error {
                print("Error checking username: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let usernameDocs = usernameQuerySnapshot?.documents, !usernameDocs.isEmpty {
                completion(true)
                return
            }

            usersRef.whereField("email", isEqualTo: email).getDocuments { emailQuerySnapshot, error in
                if let error = error {
                    print("Error checking email: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                if let emailDocs = emailQuerySnapshot?.documents, !emailDocs.isEmpty {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }

    func signUpUser() {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating account: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            } else {
                if let user = authResult?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = username
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("Error setting username: \(error.localizedDescription)")
                            errorMessage = error.localizedDescription
                        } else {
                            let userTypeValue = selectedRole == "User" ? 1 : 2
                            saveUserProfile(uid: user.uid, username: username, email: email, userType: userTypeValue)
                            if userTypeValue == 1 {
                                signedIn = true
                                userType = 1
                            } else if userTypeValue == 2 {
                               // UserManager.shared.userType = 2
                                userType = 2
                            }
                        }
                    }
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
