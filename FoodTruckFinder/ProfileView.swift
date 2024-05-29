//
//  ProfileView.swift
//  FoodTruckFinder
//
//  Created by Irfan Sarac on 2024-05-17.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var userEmail: String = "Unknown"
    @State private var profileImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var profileImageUrl: URL? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top,spacing: 60) {
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .padding(.leading)
                        .onTapGesture {
                            self.showingImagePicker = true
                        }
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .padding(.leading)
                        .onTapGesture {
                            self.showingImagePicker = true
                        }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(Auth.auth().currentUser?.displayName ?? "Username not available")
                        .font(.title)
                        .fontWeight(.bold)
                    Text(userEmail)
                        .font(.title2)
                        .fontWeight(.light)
                }
                .padding(.leading)
            }
            .padding(.top)
            Spacer()
            Spacer()
            
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
            fetchProfileImage()
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: uploadProfileImage) {
            ImagePicker(image: $profileImage)
        }
    }
    
    private func fetchUserEmail() {
        if let user = Auth.auth().currentUser {
            self.userEmail = user.email ?? "No Email"
        } else {
            self.userEmail = "No User Signed In"
        }
    }
    
    private func fetchProfileImage() {
        guard let user = Auth.auth().currentUser else { return }
        let storageRef = Storage.storage().reference().child("profile_images/\(user.uid).jpg")
        
        storageRef.downloadURL { url, error in
            if let error = error {
                print("Error fetching profile image URL: \(error)")
                return
            }
            self.profileImageUrl = url
            if let url = url {
                downloadImage(from: url) { image in
                    self.profileImage = image
                }
            }
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    private func uploadProfileImage() {
        guard let user = Auth.auth().currentUser, let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(user.uid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error while uploading profile image: \(error)")
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error while getting download URL for image: \(error)")
                    return
                }
                self.profileImageUrl = url
            }
        }
    }
    
    private func signOut() {
        do {
            UserManager.shared.userType = 0
            try Auth.auth().signOut()
            presentationMode.wrappedValue.dismiss()
            
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
