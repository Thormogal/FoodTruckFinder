//
//  FoodTruck.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-19.
//

import Foundation

import Foundation
import FirebaseFirestoreSwift

struct FoodTruck: Identifiable, Codable {
    @DocumentID var id: String?
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

struct MenuItem: Identifiable, Codable {
    var id = UUID().uuidString
    var name: String
    var price: Double
    var ingredients: String
}

struct Location: Codable {
    var latitude: Double
    var longitude: Double
}

