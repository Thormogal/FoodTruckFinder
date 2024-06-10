//
//  FoodTruckInfoSectionView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI
import MapKit

struct FTInfoSectionView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    @ObservedObject var searchCompleter: SearchCompleter
    @Binding var showingMap: Bool
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 10) {
                informationRow(title: "Food:", value: viewModel.foodTruck.foodType)
                informationRow(title: "Price Range:", value: viewModel.foodTruck.priceRange)
                informationRow(title: "Opening Hours:", value: viewModel.foodTruck.openingHours)
                informationRow(title: "Payment Methods:", value: viewModel.foodTruck.paymentMethods)
                
                // Current Location
                HStack {
                    Image(systemName: "map")
                        .foregroundColor(.blue)
                    Button(action: {
                        showingMap = true
                    }) {
                        VStack(alignment: .leading) {
                            Text("Location: \(searchCompleter.currentAddress)")
                                .foregroundColor(.blue)
                            if !viewModel.foodTruck.locationPeriod.isEmpty {
                                Text(viewModel.foodTruck.locationPeriod)
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    private func informationRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .bold()
                .alignmentGuide(.leading) { d in d[.leading] }
            VStack(alignment: .leading) {
                ForEach(value.split(separator: ".").map(String.init), id: \.self) { part in
                    Text(part.trimmingCharacters(in: .whitespacesAndNewlines))
                        .alignmentGuide(.leading) { d in d[.leading] }
                }
            }
        }
        .padding(.horizontal)
    }
}
