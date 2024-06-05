//
//  DailyDealsView.swift
//  FoodTruckFinder
//
//  Created by Irfan Sarac on 2024-06-05.
//

import SwiftUI

struct DailyDealsView: View {
    @State private var dailyDeals: [DailyDealItem] = []
    private let foodTruckService = FoodTruckService()

    var body: some View {
        NavigationView {
            List(dailyDeals) { deal in
                VStack(alignment: .leading) {
                    Text(deal.name)
                        .font(.headline)
                    Text("Food Truck: \(deal.foodTruckName)") // lägga till namn food truck-a
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("Original Price: \(deal.originalPrice, specifier: "%.2f")")
                        .strikethrough()
                    Text("Deal Price: \(deal.dealPrice, specifier: "%.2f")")
                        .foregroundColor(.red)
                    Text("Ingredients: \(deal.ingredients)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .navigationTitle("Dagens Deals")
        }
        .onAppear {
            fetchAllDailyDeals()
        }
    }

    private func fetchAllDailyDeals() {
        foodTruckService.fetchAllDailyDeals { deals in
            self.dailyDeals = deals
        }
    }
}

struct DailyDealsView_Previews: PreviewProvider {
    static var previews: some View {
        DailyDealsView()
    }
}
