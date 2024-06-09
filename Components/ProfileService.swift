//
//  ProfileService.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-09.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileService {
    static let shared = ProfileService()

    private init() {}

    func deleteUserAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "No user signed in", code: -1, userInfo: nil)))
            return
        }
        
        let userId = user.uid

        // Step 1: Delete user data from Firestore
        deleteUserData(userId: userId) { result in
            switch result {
            case .success:
                // Step 2: Delete food truck data from Firestore
                self.deleteFoodTruckData(userId: userId) { result in
                    switch result {
                    case .success:
                        // Step 3: Delete user reviews from Firestore
                        self.deleteUserReviews(userId: userId) { result in
                            switch result {
                            case .success:
                                // Step 4: Delete user images from Storage
                                self.deleteUserImages(userId: userId) { result in
                                    switch result {
                                    case .success:
                                        // Step 5: Delete user from Firebase Authentication
                                        self.deleteUserFromAuth(user: user, completion: completion)
                                    case .failure(let error):
                                        completion(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func deleteUserData(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        userRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    private func deleteFoodTruckData(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let foodTruckRef = db.collection("foodTrucks").document(userId)
        foodTruckRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    private func deleteUserReviews(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("foodTrucks").getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var encounteredError: Error?

            for document in querySnapshot!.documents {
                dispatchGroup.enter()
                var reviews = document.data()["reviews"] as? [[String: Any]] ?? []
                reviews.removeAll { $0["userId"] as? String == userId }
                
                db.collection("foodTrucks").document(document.documentID).updateData(["reviews": reviews]) { error in
                    if let error = error {
                        encounteredError = error
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                if let error = encounteredError {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    private func deleteUserImages(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var encounteredError: Error?

        // Delete profile image
        let profileImageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        dispatchGroup.enter()
        profileImageRef.delete { error in
            if let error = error as NSError?, error.code != StorageErrorCode.objectNotFound.rawValue {
                encounteredError = error
            }
            dispatchGroup.leave()
        }

        // Delete food truck image
        let foodTruckImageRef = Storage.storage().reference().child("foodTruckImages/\(userId).jpg")
        dispatchGroup.enter()
        foodTruckImageRef.delete { error in
            if let error = error as NSError?, error.code != StorageErrorCode.objectNotFound.rawValue {
                encounteredError = error
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            if let error = encounteredError {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    private func deleteUserFromAuth(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        user.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func reauthenticateUser(password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "No user signed in", code: -1, userInfo: nil)))
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: user.email!, password: password)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
