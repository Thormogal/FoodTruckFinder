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
    @StateObject private var locationManager = LocationManagerViewModel()
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
                FTInfoSectionView(viewModel: viewModel, searchCompleter: searchCompleter, showingMap: $showingMap)
                
                // Daily Deals
                if !viewModel.foodTruck.dailyDeals.isEmpty {
                    FTDailyDealsSectionView(dailyDeals: viewModel.foodTruck.dailyDeals)
                }
                
                // Menu
                if !viewModel.foodTruck.menu.isEmpty {
                    FTMenuSectionView(menu: viewModel.foodTruck.menu)
                }
                
                // Drinks
                if !viewModel.foodTruck.drinks.isEmpty {
                    FTDrinksSectionView(drinks: viewModel.foodTruck.drinks)
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
                            viewModel: viewModel,
                            onSave: {
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
            FTLocationMapView(foodTruck: viewModel.foodTruck, userLocation: locationManager.userLocation?.coordinate)
        }
        .sheet(isPresented: $isRatingPresented) {
            FTRatingInputView(isPresented: $isRatingPresented) { newRating in
                viewModel.addRating(newRating)
            }
        }
        .sheet(isPresented: $isReviewListPresented) {
            FTReviewsListView(viewModel: viewModel, userType: userType)
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
