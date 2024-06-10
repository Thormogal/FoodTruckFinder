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
    @StateObject private var locationManager = LocationManager()
    @State private var isEditing = false
    @State private var showingMap = false
    @State private var isRatingPresented = false
    @State private var isReviewListPresented = false
    var userType: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text(viewModel.foodTruck.name)
                    .font(.custom("AvenirNext-Bold", size: 24))
                    .foregroundColor(.primary)
                    .padding(.top, 10)
                
                // Food truck image
                if let imageURL = URL(string: viewModel.foodTruck.imageURL) {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: 200)
                            .clipped()
                    } placeholder: {
                        EmptyView()
                    }
                }
                
                // Rating bar
                RatingView(rating: viewModel.foodTruck.rating)
                    .padding(.top, 10)
                    .onTapGesture {
                        isRatingPresented = true
                    }
                
                // Reviews Count and Average Rating
                Text("(\(viewModel.foodTruck.ratings.count) ratings and \(viewModel.foodTruck.reviews.count) reviews)")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .padding(.bottom, 30)
                    .onTapGesture {
                        isReviewListPresented = true
                    }
                
                // Information about the food truck.
                FoodTruckInfoSection(viewModel: viewModel, searchCompleter: searchCompleter, showingMap: $showingMap)
                
                // Daily Deals
                if !viewModel.foodTruck.dailyDeals.isEmpty {
                    DailyDealsSection(dailyDeals: viewModel.foodTruck.dailyDeals)
                }
                
                // Menu
                if !viewModel.foodTruck.menu.isEmpty {
                    MenuSection(menu: viewModel.foodTruck.menu)
                }
                
                // Drinks
                if !viewModel.foodTruck.drinks.isEmpty {
                    DrinksSection(drinks: viewModel.foodTruck.drinks)
                }
                
                // Edit button for usertype 2 (owner)
                if userType == 2 {
                    Button(action: {
                        isEditing = true
                    }) {
                        Text("Edit Profile")
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $isEditing) {
                        FoodTruckEditView(
                            viewModel: FoodTruckViewModel(foodTruck: viewModel.foodTruck),
                            onSave: {
                                viewModel.saveFoodTruckData()
                                let location = CLLocation(latitude: viewModel.foodTruck.location.latitude, longitude: viewModel.foodTruck.location.longitude)
                                searchCompleter.reverseGeocodeLocation(location: location) { address in
                                    searchCompleter.currentAddress = address
                                }
                                isEditing = false
                            }
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showingMap) {
            FoodTruckLocationMap(foodTruck: viewModel.foodTruck, userLocation: locationManager.userLocation?.coordinate)
        }
        .sheet(isPresented: $isRatingPresented) {
            RatingInputView(isPresented: $isRatingPresented) { newRating in
                viewModel.addRating(newRating)
            }
        }
        .sheet(isPresented: $isReviewListPresented) {
            ReviewsListView(viewModel: viewModel, userType: userType)
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
        .padding()
    }
}

struct FoodTruckInfoSection: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    @ObservedObject var searchCompleter: SearchCompleter
    @Binding var showingMap: Bool
    
    var body: some View {
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
            .padding(.top, 5)
        }
        .padding(.bottom, 30)
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

struct DailyDealsSection: View {
    var dailyDeals: [DailyDealItem]
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text("🎉 Daily Deals 🎉")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.red)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                ForEach(dailyDeals) { deal in
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
                        
                        Text("\(deal.ingredients)")
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
}

struct MenuSection: View {
    var menu: [MenuItem]
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text("Menu")
                    .font(.title)
                    .bold()
                    .padding(.top, 10)
                    .padding(.bottom, 3)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                ForEach(menu) { item in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("\(item.price, specifier: "%.2f") kr")
                        }
                        .padding(.horizontal)
                        
                        Text("\(item.ingredients)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding([.horizontal, .top])
        }
    }
}

struct DrinksSection: View {
    var drinks: [DrinkItem]
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text("Drinks")
                    .font(.title)
                    .bold()
                    .padding(.top, 15)
                    .padding(.bottom, 3)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                ForEach(drinks) { drink in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(drink.name)
                            Spacer()
                            Text("\(drink.price, specifier: "%.2f") kr")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 15)
                }
            }
            .padding([.horizontal, .top])
        }
    }
}

struct FoodTruckLocationMap: View {
    var foodTruck: FoodTruck
    var userLocation: CLLocationCoordinate2D?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Map {
                Marker(foodTruck.name, coordinate: CLLocationCoordinate2D(latitude: foodTruck.location.latitude, longitude: foodTruck.location.longitude))
                if let userLocation = userLocation {
                    Marker("Your Location", coordinate: userLocation)
                }
            }
            .mapStyle(.standard)
            .navigationTitle("\(foodTruck.name) Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(foodTruck.name) Location")
                        .font(.largeTitle)
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

struct FoodTruckProfileView_Previews: PreviewProvider {
    @StateObject static var viewModel = FoodTruckViewModel(
        foodTruck: FoodTruck(
            id: UUID().uuidString,
            name: "Sample Truck",
            rating: 4.5,
            ratings: [4.5, 5.0, 4.0],
            foodType: "Taco",
            priceRange: "$$",
            openingHours: "9 AM - 5 PM",
            paymentMethods: "Cash, Credit",
            imageURL: "https://example.com/image.jpg",
            menu: [
                MenuItem(name: "Taco", price: 5.0, ingredients: "Beef, Cheese, Lettuce")
            ],
            drinks: [
                DrinkItem(name: "Coca-Cola", price: 2.0),
                DrinkItem(name: "Fanta", price: 2.0)
            ],
            dailyDeals: [
                DailyDealItem(name: "Discount Taco", originalPrice: 5.0, dealPrice: 3.0, ingredients: "Beef, Cheese, Lettuce", foodTruckName: "Sample Truck")
            ],
            location: Location(latitude: 37.7749, longitude: -122.4194),
            locationPeriod: "9 June - 16 June",
            reviews: [
                Review(userId: "123", userName: "John Doe", text: "Great food!", rating: 5.0)
            ]
        )
    )
    
    static var previews: some View {
        FoodTruckProfileView(viewModel: viewModel, userType: 1)
    }
}
