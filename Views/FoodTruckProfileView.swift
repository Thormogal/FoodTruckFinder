//
//  FoodTruckProfileView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-19.
//

import SwiftUI

struct FoodTruckProfileView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text(viewModel.foodTruck.name)
                    .font(.custom("AvenirNext-Bold", size: 24))
                    .foregroundColor(.primary)
                    .padding(.top, 10)
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
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                VStack(alignment: .leading, spacing: 10) {
                    informationRow(title: "Food:", value: viewModel.foodTruck.foodType)
                    informationRow(title: "Price Range:", value: viewModel.foodTruck.priceRange)
                    informationRow(title: "Opening Hours:", value: viewModel.foodTruck.openingHours)
                    informationRow(title: "Payment Methods:", value: viewModel.foodTruck.paymentMethods)
                }
                .padding(.bottom, 30)

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
                if UserManager.shared.userType != 1 {
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
    }
}
