//
//  MenuSectionView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct MenuEditView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    
    var body: some View {
        Section(header: Text("Menu")) {
            ForEach(Array(viewModel.foodTruck.menu.enumerated()), id: \.element.id) { index, item in
                VStack {
                    TextField("Item Name", text: binding(for: $viewModel.foodTruck.menu, index: index, keyPath: \.name))
                    TextField("Item Price", value: binding(for: $viewModel.foodTruck.menu, index: index, keyPath: \.price), formatter: NumberFormatter())
                    TextField("Ingredients", text: binding(for: $viewModel.foodTruck.menu, index: index, keyPath: \.ingredients))
                    Button(action: {
                        viewModel.removeMenuItem(at: index)
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
