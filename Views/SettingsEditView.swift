//
//  SettingsEditView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct SettingsEditView: View {
    @AppStorage("confirmationEnabled") private var confirmationEnabled: Bool = true
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Settings")) {
                    Toggle(isOn: $confirmationEnabled) {
                        Text("Confirm before removing")
                    }
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
