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
                    .padding(.top, 10)
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
                            let location = CLLocation(latitude: viewModel.foodTruck.location.latitude, longitude: viewModel.foodTruck.location.longitude)
                            searchCompleter.reverseGeocodeLocation(location: location) { address in
                                searchCompleter.currentAddress = address
                            }
                            isEditing = false
                        }
                    }
                }
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
            .safeAreaInset(edge: .top) {
                Text("\(foodTruck.name) Location")
                    .font(.headline)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
            }
            .navigationTitle("\(foodTruck.name) Location")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
