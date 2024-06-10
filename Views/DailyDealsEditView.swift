//
//  DailyDealsSectionView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct DailyDealsEditView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    
    var body: some View {
        Section(header: Text("Daily Deals")) {
            ForEach(Array(viewModel.foodTruck.dailyDeals.enumerated()), id: \.element.id) { index, _ in
                VStack {
                    TextField("Item Name", text: binding(for: $viewModel.foodTruck.dailyDeals, index: index, keyPath: \.name))
                    HStack {
                        TextField("Original Price", value: binding(for: $viewModel.foodTruck.dailyDeals, index: index, keyPath: \.originalPrice), formatter: NumberFormatter())
                        TextField("Deal Price", value: binding(for: $viewModel.foodTruck.dailyDeals, index: index, keyPath: \.dealPrice), formatter: NumberFormatter())
                    }
                    TextField("Ingredients", text: binding(for: $viewModel.foodTruck.dailyDeals, index: index, keyPath: \.ingredients))
                    Button(action: {
                        viewModel.removeDailyDealItem(at: index)
                    }) {
                        Text("Remove Deal")
                            .foregroundColor(.red)
                    }
                }
            }
            Button(action: viewModel.addDailyDealItem) {
                Text("Add Daily Deal")
            }
        }
    }
    
    private func binding(for array: Binding<[DailyDealItem]>, index: Int, keyPath: WritableKeyPath<DailyDealItem, String>) -> Binding<String> {
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
    
    private func binding(for array: Binding<[DailyDealItem]>, index: Int, keyPath: WritableKeyPath<DailyDealItem, Double>) -> Binding<Double> {
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
