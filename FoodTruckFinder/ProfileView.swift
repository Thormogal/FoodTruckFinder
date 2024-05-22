//
//  ProfileView.swift
//  FoodTruckFinder
//
//  Created by Irfan Sarac on 2024-05-17.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var userEmail: String = "Unknown"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 30.0) {
                Image("ProfilePic")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .padding(.leading)

                VStack(alignment: .leading) {
                    Text(userEmail)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Göteborg, Sweden")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.leading)
            }
            .padding(.top)

            VStack(alignment: .leading) {
                HStack {
                    Image("HamburgerIcon")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Reviews")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.leading)
                Spacer()
            }
            .frame(maxHeight: .infinity)
            
            Spacer()
            
            Button(action: signOut) {
                Text("Sign Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.bottom)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchUserEmail()
        }
    }

    private func fetchUserEmail() {
        if let user = Auth.auth().currentUser {
            self.userEmail = user.email ?? "No Email"
        } else {
            self.userEmail = "No User Signed In"
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()

        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
