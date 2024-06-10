//
//  DeleteAccountSection.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct DeleteAccountSectionView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    
    var body: some View {
        Section {
            Button(action: {
                viewModel.showingPasswordAlert = true
            }) {
                Text("Delete Account")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .listRowBackground(Color.clear)
        }
    }
}
