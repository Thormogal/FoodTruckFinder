//
//  FoodTruck.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-19.
//

import Foundation

struct FoodTruck: Identifiable {
    let id: String
    let name: String
    let rating: Double
    let foodType: String
    let priceRange: String
    let openingHours: String
    let paymentMethods: String
    let imageURL: String
    let menu: [MenuItem]
    let location: Location
}

struct MenuItem: Identifiable {
    let id: String
    let name: String
    let ingredients: String
    let price: Double
}

struct Location {
    let latitude: Double
    let longitude: Double
}
