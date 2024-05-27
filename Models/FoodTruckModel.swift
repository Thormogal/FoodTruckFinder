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
    
   
    var distance: Double {
       // calc distance
        return Double.random(in: 1...20)
    }
}

struct Location: Codable {
    var latitude: Double
    var longitude: Double
}

struct MenuItem: Identifiable, Codable {
    var id: String
    var name: String
    var price: Double
    var ingredients: String
}


