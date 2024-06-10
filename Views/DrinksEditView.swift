//
//  DrinksSectionView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct DrinksEditView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    
    var body: some View {
        Section(header: Text("Drinks")) {
            ForEach(Array(viewModel.foodTruck.drinks.enumerated()), id: \.element.id) { index, item in
                VStack {
                    TextField("Drink Name", text: binding(for: $viewModel.foodTruck.drinks, index: index, keyPath: \.name))
                    TextField("Drink Price", value: binding(for: $viewModel.foodTruck.drinks, index: index, keyPath: \.price), formatter: NumberFormatter())
                    Button(action: {
                        viewModel.removeDrinkItem(at: index)
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
    }
    
    private func binding<Value>(for array: Binding<[Value]>, index: Int, keyPath: WritableKeyPath<Value, String>) -> Binding<String> {
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
    
    private func binding<Value>(for array: Binding<[Value]>, index: Int, keyPath: WritableKeyPath<Value, Double>) -> Binding<Double> {
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
