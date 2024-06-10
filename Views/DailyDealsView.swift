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
        VStack {
            Text("🎉 Daily Deals 🎉")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(.red)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                .shadow(color: .black, radius: 1)

            NavigationView {
                List {
                    ForEach(groupedDeals.keys.sorted(), id: \.self) { key in
                        Section(header: Text(key).font(.headline)) {
                            ForEach(groupedDeals[key] ?? []) { deal in
                                VStack(alignment: .leading) {
                                    Text(deal.name)
                                        .font(.headline)
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
                        }
                    }
                }
                .navigationTitle("")
                .navigationBarHidden(true)
            }
            .onAppear {
                fetchAllDailyDeals()
            }
        }
    }

    private var groupedDeals: [String: [DailyDealItem]] {
        Dictionary(grouping: dailyDeals, by: { $0.foodTruckName })
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
