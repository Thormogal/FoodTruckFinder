//
//  ImagePickerViewModel.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-27.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth

class TruckImagePickerViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var imageURL: String?

    func uploadImage() {
        guard let userId = Auth.auth().currentUser?.uid, let image = selectedImage else { return }
        let storageRef = Storage.storage().reference().child("foodTruckImages/\(userId).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            storageRef.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                        return
                    }
                    if let url = url {
                        DispatchQueue.main.async {
                            self.imageURL = url.absoluteString
                        }
                    }
                }
            }
        }
    }
}



