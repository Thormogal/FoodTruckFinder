//
//  GeneralSectionView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct GeneralEditView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    let foodTypes: [String]
    
    var body: some View {
        Section(header: Text("General")) {
            TextField("Name", text: $viewModel.foodTruck.name)
            
            Picker("Food Type", selection: $viewModel.foodTruck.foodType) {
                ForEach(foodTypes, id: \.self) {
                    Text($0)
                }
            }
            
            TextField("Price Range", text: $viewModel.foodTruck.priceRange)
            TextField("Opening Hours", text: $viewModel.foodTruck.openingHours)
            TextField("Payment Methods", text: $viewModel.foodTruck.paymentMethods)
        }
    }
}
