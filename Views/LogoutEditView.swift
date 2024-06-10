//
//  LogoutSectionView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct LogoutEditView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Section {
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
                Text("Logout")
                    .foregroundColor(.red)
            }
        }
    }
}
