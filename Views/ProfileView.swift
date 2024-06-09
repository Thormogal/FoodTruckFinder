//
//  ProfileView.swift
//  FoodTruckFinder
//
//  Created by Irfan Sarac on 2024-05-17.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var userEmail: String = "Unknown"
    @State private var profileImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var profileImageUrl: URL? = nil
    @State private var userReviews: [Review] = []
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .onTapGesture {
                            self.showingImagePicker = true
                        }
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .onTapGesture {
                            self.showingImagePicker = true
                        }
                }

                VStack(alignment: .center, spacing: 8) {
                    Text(Auth.auth().currentUser?.displayName ?? "Username not available")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(userEmail)
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundColor(.white)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.fromHex("3D84B7")))
            .cornerRadius(10)
            .padding([.top, .horizontal])

            VStack(alignment: .leading) {
                HStack {
                    Image("HamburgerIcon")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Reviews")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.leading, 45)
                .padding(.top)

                ScrollView {
                    if userReviews.isEmpty {
                        Text("No reviews yet...")
                            .font(.body)
                            .padding(.leading, 45)
                            .padding(.top, 20)
                    } else {
                        ForEach(userReviews) { review in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(review.foodTruckName ?? "Unknown Food Truck")
                                    .font(.headline)
                                Text(review.text)
                                    .font(.body)
                                RatingView(rating: review.rating)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.leading, 20)
                        }
                    }
                }
                .padding(.leading, 20)
            }
            .frame(maxHeight: .infinity)

            HStack {
                Spacer()
                Button(action: {
                    AuthManager.shared.signOut(presentationMode: presentationMode) { result in
                        switch result {
                        case .success:
                            print("Signed out successfully")
                        case .failure(let error):
                            print("Error signing out: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(UIColor.fromHex("3D84B7")))
                        .cornerRadius(10)
                        .padding(.bottom)
                }
                
                Button(action: {
                    self.showingDeleteAlert = true
                }) {
                    Text("Delete Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.bottom)
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account?"),
                        primaryButton: .destructive(Text("Delete")) {
                            ProfileService.shared.deleteUserAccount { result in
                                switch result {
                                case .success:
                                    print("User account deleted successfully")
                                    self.presentationMode.wrappedValue.dismiss()
                                case .failure(let error):
                                    print("Error deleting user account: \(error.localizedDescription)")
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .frame(width: 450, height: 700)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchUserEmail()
            fetchProfileImage()
            fetchUserReviews()
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

    func fetchUserReviews() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("foodTrucks").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching user reviews: \(error.localizedDescription)")
                return
            }
            
            var userReviews: [Review] = []
            for document in querySnapshot!.documents {
                if let reviews = document.data()["reviews"] as? [[String: Any]] {
                    for reviewData in reviews {
                        if reviewData["userId"] as? String == userId {
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: reviewData, options: [])
                                var review = try JSONDecoder().decode(Review.self, from: jsonData)
                                review.foodTruckName = review.foodTruckName ?? "Unknown Food Truck"
                                userReviews.append(review)
                            } catch {
                                print("Error decoding review: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.userReviews = userReviews
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
