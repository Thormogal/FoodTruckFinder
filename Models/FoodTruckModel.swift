//
//  FoodTruck.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-19.
//

import Foundation

struct FoodTruck: Identifiable {
    var id: String
    var name: String
    var rating: Double
    var foodType: String
    var priceRange: String
    var openingHours: String
    var paymentMethods: String
    var imageURL: String
    var menu: [MenuItem]
    var location: Location
}

struct MenuItem: Identifiable {
    var id: String
    var name: String
    var price: Double
    var ingredients: String
}

struct Location {
    var latitude: Double
    var longitude: Double
}
