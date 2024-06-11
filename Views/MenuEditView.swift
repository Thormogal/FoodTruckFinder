//
//  MenuSectionView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct MenuEditView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    @State private var showingAlert = false
    @State private var indexToRemove: Int?
    @AppStorage("confirmationEnabled") private var confirmationEnabled: Bool = true
    
    var body: some View {
        Section(header: Text("Menu")) {
            ForEach(Array(viewModel.foodTruck.menu.enumerated()), id: \.element.id) { index, _ in
                VStack {
                    TextField("Item Name", text: binding(for: $viewModel.foodTruck.menu, index: index, keyPath: \.name))
                    DecimalField("Item Price", value: binding(for: $viewModel.foodTruck.menu, index: index, keyPath: \.price))
                    TextField("Ingredients", text: binding(for: $viewModel.foodTruck.menu, index: index, keyPath: \.ingredients))
                    Button(action: {
                        if confirmationEnabled {
                            indexToRemove = index
                            showingAlert = true
                        } else {
                            viewModel.removeMenuItem(at: index)
                        }
                    }) {
                        Text("Remove Item")
                            .foregroundColor(.red)
                    }
                }
            }
            Button(action: viewModel.addMenuItem) {
                Text("Add Item")
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Confirm Removal"),
                message: Text("Are you sure you want to remove this menu item?"),
                primaryButton: .destructive(Text("Remove")) {
                    if let index = indexToRemove {
                        viewModel.removeMenuItem(at: index)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func binding(for array: Binding<[MenuItem]>, index: Int, keyPath: WritableKeyPath<MenuItem, String>) -> Binding<String> {
        return Binding<String>(
            get: {
                if array.wrappedValue.indices.contains(index) {
                    return array.wrappedValue[index][keyPath: keyPath]
                }
                return ""
            },
            set: { newValue in
                if array.wrappedValue.indices.contains(index) {
                    array.wrappedValue[index][keyPath: keyPath] = newValue
                }
            }
        )
    }
    
    private func binding(for array: Binding<[MenuItem]>, index: Int, keyPath: WritableKeyPath<MenuItem, Double>) -> Binding<Double> {
        return Binding<Double>(
            get: {
                if array.wrappedValue.indices.contains(index) {
                    return array.wrappedValue[index][keyPath: keyPath]
                }
                return 0.0
            },
            set: { newValue in
                if array.wrappedValue.indices.contains(index) {
                    array.wrappedValue[index][keyPath: keyPath] = newValue
                }
            }
        )
    }
}
