//
//  AuthManager.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-31.
//

import FirebaseAuth
import SwiftUI

class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    func signOut(presentationMode: Binding<PresentationMode>, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
            completion(.success(()))
        } catch let signOutError {
            completion(.failure(signOutError))
        }
    }
}
