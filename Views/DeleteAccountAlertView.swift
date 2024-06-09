//
//  CustomAlert.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct DeleteAccountAlertView: View {
    @Binding var isPresented: Bool
    @Binding var password: String
    var title: String
    var message: String
    var onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .foregroundColor(.blue)
                }
                Spacer()
                Button(action: {
                    isPresented = false
                    onConfirm()
                }) {
                    Text("Confirm")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .frame(maxWidth: 300)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}
