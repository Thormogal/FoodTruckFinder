//
//  FoodTruckProfileView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-19.
//

import SwiftUI
import MapKit

struct FoodTruckProfileView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    @StateObject private var searchCompleter = SearchCompleter()
    @State private var isEditing = false
    @State private var showingMap = false
    @State private var isRatingPresented = false
    @State private var isReviewPresented = false
    var userType: Int
    
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
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                    .onTapGesture {
                        isRatingPresented = true
                    }
                
                
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
                            Text("Location: \(searchCompleter.currentAddress)")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 5)
                }
                .padding(.bottom, 30)
                
                // Daily Deals
                if !viewModel.foodTruck.dailyDeals.isEmpty {
                    Group {
                        VStack(alignment: .leading) {
                            Text("🎉 Daily Deals 🎉")
                                .font(.title)
                                .fontWeight(.heavy)
                                .foregroundColor(.red)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            ForEach(viewModel.foodTruck.dailyDeals) { deal in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(deal.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("\(deal.originalPrice, specifier: "%.2f") kr")
                                            .strikethrough()
                                            .foregroundColor(.gray)
                                        Text("\(deal.dealPrice, specifier: "%.2f") kr")
                                            .foregroundColor(.red)
                                            .font(.headline)
                                    }
                                    .padding(.horizontal)
                                    
                                    Text("Ingredients: \(deal.ingredients)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                    .padding([.horizontal, .bottom])
                }
                // Menu
                Group {
                    VStack(alignment: .leading) {
                        Text("Menu")
                            .font(.title)
                            .bold()
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
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
                    .padding(.top, viewModel.foodTruck.dailyDeals.isEmpty ? 0 : 20) // Adjust padding based on daily deals
                }
                .padding([.horizontal, .top])
                
                // Edit button for usertype 2 (owner)
                if userType == 2 {
                    Button(action: {
                        isEditing = true
                    }) {
                        Text("Edit Profile")
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $isEditing) {
                        FoodTruckEditView(foodTruck: $viewModel.foodTruck) {
                            viewModel.saveFoodTruckData()
                            let location = CLLocation(latitude: viewModel.foodTruck.location.latitude, longitude: viewModel.foodTruck.location.longitude)
                            searchCompleter.reverseGeocodeLocation(location: location) { address in
                                searchCompleter.currentAddress = address
                            }
                            isEditing = false
                        }
                    }
                }
                if userType == 1 {
                    Button(action: {
                        isReviewPresented = true
                    }) {
                        Text("Write a Review")
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                
                Group {
                    Text("Reviews")
                        .font(.title)
                        .bold()
                    
                    ForEach(viewModel.foodTruck.reviews) { review in
                        VStack(alignment: .leading) {
                            Text("\(review.userName) - \(review.rating, specifier: "%.1f") burgers")
                                .font(.headline)
                            Text(review.text)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingMap) {
            FoodTruckLocationMap(foodTruck: viewModel.foodTruck)
        }
        .onAppear {
            let location = CLLocation(latitude: viewModel.foodTruck.location.latitude, longitude: viewModel.foodTruck.location.longitude)
            searchCompleter.reverseGeocodeLocation(location: location) { address in
                searchCompleter.currentAddress = address
            }
        }
        .onChange(of: viewModel.foodTruck.location) {
            let location = CLLocation(latitude: viewModel.foodTruck.location.latitude, longitude: viewModel.foodTruck.location.longitude)
            searchCompleter.reverseGeocodeLocation(location: location) { address in
                searchCompleter.currentAddress = address
            }
        }
        .sheet(isPresented: $isRatingPresented) {
            RatingInputView(isPresented: $isRatingPresented) { newRating in
                viewModel.addRating(newRating)
            }
            
        }
        .sheet(isPresented: $isReviewPresented) {
            SubmitReviewView(viewModels: viewModel, isPresented: $isReviewPresented)
        }
        .padding()
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

struct FoodTruckLocationMap: View {
    var foodTruck: FoodTruck
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Map {
                Marker(foodTruck.name, coordinate: CLLocationCoordinate2D(latitude: foodTruck.location.latitude, longitude: foodTruck.location.longitude))
            }
            .mapStyle(.standard)
            .navigationTitle("\(foodTruck.name) Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(foodTruck.name) Location")
                        .font(.largeTitle) // Anpassa storleken här
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
