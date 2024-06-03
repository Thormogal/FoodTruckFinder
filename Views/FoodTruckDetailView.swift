//
//  FoodTruckDetailView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-02.
//

import SwiftUI

struct FoodTruckDetailView: View {
    var foodTruckId: String
    var userType: Int
    @StateObject private var viewModel = FoodTruckViewModel()

    var body: some View {
        VStack {
            if !viewModel.foodTruck.id.isEmpty {
                FoodTruckProfileView(viewModel: viewModel, userType: userType)
            } else {
                Text("Loading...")
                    .onAppear {
                        viewModel.fetchFoodTruckData(by: foodTruckId)
                    }
            }
        }
        .onAppear {
            if viewModel.foodTruck.id != foodTruckId {
                viewModel.fetchFoodTruckData(by: foodTruckId)
            }
        }
    }
}
