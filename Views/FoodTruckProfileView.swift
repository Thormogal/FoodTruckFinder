//
//  FoodTruckProfileView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-19.
//

import SwiftUI
import CoreLocation

struct FoodTruckProfileView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Food truck image
                AsyncImage(url: URL(string: viewModel.foodTruck.imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: UIScreen.main.bounds.width, height: 200)
                .clipped()

                // Rating bar
                RatingView(rating: viewModel.foodTruck.rating)

                // Location map view
                LocationMapView(coordinate: CLLocationCoordinate2D(
                    latitude: viewModel.foodTruck.location.latitude,
                    longitude: viewModel.foodTruck.location.longitude
                ))
                .frame(height: 200)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Type of Food: \(viewModel.foodTruck.foodType)")
                    Text("Price Range: \(viewModel.foodTruck.priceRange)")
                    Text("Opening Hours: \(viewModel.foodTruck.openingHours)")
                    Text("Payment Methods: \(viewModel.foodTruck.paymentMethods)")
                }
                .padding()

                // Menu
                Group {
                    Text("Menu")
                        .font(.title)
                        .bold()

                    ForEach(viewModel.foodTruck.menu) { item in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text("\(item.price, specifier: "%.2f") kr")
                            }
                            .padding(.horizontal)

                            Text("Ingredients: \(item.ingredients)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()

                // Edit button
                Button(action: {
                    isEditing = true
                }) {
                    Text("Edit Profile")
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $isEditing) {
                    FoodTruckEditView(foodTruck: $viewModel.foodTruck) {
                        viewModel.saveFoodTruckData()
                        isEditing = false
                    }
                }
            }
        }
    }
}

// RatingView for displaying the rating
struct RatingView: View {
    var rating: Double

    var body: some View {
        HStack {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(rating) ? "star.fill" : "star")
                    .foregroundColor(index < Int(rating) ? .yellow : .gray)
            }
        }
        .padding(.horizontal)
    }
}

// Preview Provider
struct FoodTruckProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = FoodTruckViewModel()
        FoodTruckProfileView(viewModel: viewModel)
    }
}






