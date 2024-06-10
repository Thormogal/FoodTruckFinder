//
//  HomeView.swift
//  FoodTruckFinder
//
//  Created by Irfan Sarac on 2024-05-17.
//



// Your HomeView implementation here...

import SwiftUI
import Firebase
import FirebaseFirestore
import CoreLocation

enum SortOption: String, CaseIterable, Identifiable {
    case distance = "Distance"
    case price = "Price"
    case rating = "Rating"
    
    var id: String { self.rawValue }
}

extension UIColor {
    static func fromHex(_ hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

struct Category: Equatable, Identifiable {
    var id = UUID()
    var name: String
    var imageName: String
}

struct CategoryItemView: View {
    var category: Category
    var isSelected: Bool
    
    var body: some View {
        VStack {
            Image(category.imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
            Text(category.name)
                .font(.caption)
        }
    }
}

struct HomeView: View {
    @State private var foodTrucks: [FoodTruck] = []
    @State private var filteredFoodTrucks: [FoodTruck] = []
    @State private var selectedCategory: Category?
    @State private var selectedSortOption: SortOption = .distance // Default sort option
    @State private var categories: [Category] = [
        Category(name: "All", imageName: "everything"),
        Category(name: "Taco", imageName: "taco"),
        Category(name: "Sushi", imageName: "sushi"),
        Category(name: "Hamburger", imageName: "hamburger"),
        Category(name: "Asian", imageName: "asian"),
        Category(name: "Indian", imageName: "indian"),
        Category(name: "Pizza", imageName: "pizza"),
        Category(name: "Kebab", imageName: "kebab"),
        Category(name: "Chicken", imageName: "chicken")
    ]
    @ObservedObject private var locationManager = LocationManager()
    private let foodTruckService = FoodTruckService()
    @State private var userType: Int = 1  // Assuming a default value, you can set this from parent view or context
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories) { category in
                            CategoryItemView(category: category, isSelected: category == selectedCategory)
                                .padding(.horizontal, 10)
                                .onTapGesture {
                                    selectedCategory = category
                                    filterFoodTrucks()
                                }
                        }
                    }
                    .padding()
                }
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(UIColor.fromHex("3D84B7")))
                            .frame(width: 125, height: 35)
                        Picker("Sort by", selection: $selectedSortOption) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal, 10)
                        .onChange(of: selectedSortOption) {
                            sortFoodTrucks()
                        }
                        .accentColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                
                List(filteredFoodTrucks) { foodTruck in
                    ZStack {
                        VStack(alignment: .leading) {
                            Text(foodTruck.name)
                                .font(.headline)
                                .padding(.bottom, 5)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                Image("cardpic")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text(foodTruck.openingHours)
                                    Text("Food: \(foodTruck.foodType)")
                                    
                                    Text("Price: \(foodTruck.priceRange)")
                                    RatingView(rating: (foodTruck.rating))
                                    if let userLocation = locationManager.userLocation {
                                        Text("Distance: \(String(format: "%.2f", foodTruck.distance(to: userLocation))) km")
                                    } else {
                                        Text("Distance: Calculating...")
                                    }
                                    
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color(UIColor.fromHex("3D84B7")))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                        
                        NavigationLink(destination: FoodTruckDetailView(foodTruckId: foodTruck.id, userType: userType)) {
                            EmptyView()
                        }
                        .opacity(0)
                    }
                }
                .onAppear {
                    fetchFoodTrucks()
                }
            }
        }
    }
    
    private func fetchFoodTrucks() {
        foodTruckService.fetchFoodTrucks { trucks in
            foodTrucks = trucks
            filterFoodTrucks()
        }
    }
    
    private func filterFoodTrucks() {
        if let selectedCategory = selectedCategory, selectedCategory.name != "All" {
            filteredFoodTrucks = foodTrucks.filter { $0.foodType == selectedCategory.name }
        } else {
            filteredFoodTrucks = foodTrucks
        }
        sortFoodTrucks()
    }
    
    private func sortFoodTrucks() {
        if let userLocation = locationManager.userLocation {
            print("User Location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
        } else {
            print("User Location not available")
        }
        switch selectedSortOption {
        case .distance:
            if let userLocation = locationManager.userLocation {
                filteredFoodTrucks.sort { $0.distance(to: userLocation) < $1.distance(to: userLocation) }
                print("Sorted by distance")
            }
        case .price:
            filteredFoodTrucks.sort { $0.priceRange < $1.priceRange }
            print("Sorted by price")
        case .rating:
            filteredFoodTrucks.sort { $0.rating > $1.rating }
            print("Sorted by rating")
        }
    }
}

