//
//  DrinksSectionView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct DrinksEditView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    @State private var showingAlert = false
    @State private var indexToRemove: Int?
    @AppStorage("confirmationEnabled") private var confirmationEnabled: Bool = true

    var body: some View {
        Section(header: Text("Drinks")) {
            ForEach(Array(viewModel.foodTruck.drinks.enumerated()), id: \.element.id) { index, _ in
                VStack {
                    TextField("Drink Name", text: binding(for: $viewModel.foodTruck.drinks, index: index, keyPath: \.name))
                    TextField("Drink Price", value: binding(for: $viewModel.foodTruck.drinks, index: index, keyPath: \.price), formatter: NumberFormatter())
                    Button(action: {
                        if confirmationEnabled {
                            indexToRemove = index
                            showingAlert = true
                        } else {
                            viewModel.removeDrinkItem(at: index)
                        }
                    }) {
                        Text("Remove Drink")
                            .foregroundColor(.red)
                    }
                }
            }
            Button(action: viewModel.addDrinkItem) {
                Text("Add Drink")
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Confirm Removal"),
                message: Text("Are you sure you want to remove this drink?"),
                primaryButton: .destructive(Text("Remove")) {
                    if let index = indexToRemove {
                        viewModel.removeDrinkItem(at: index)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func binding(for array: Binding<[DrinkItem]>, index: Int, keyPath: WritableKeyPath<DrinkItem, String>) -> Binding<String> {
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

    private func binding(for array: Binding<[DrinkItem]>, index: Int, keyPath: WritableKeyPath<DrinkItem, Double>) -> Binding<Double> {
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
