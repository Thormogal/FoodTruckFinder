//
//  Review.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-06-03.
//

import Foundation

struct ReviewModel: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String
    var userName: String
    var text: String
    var rating: Double
    var foodTruckName: String?
    
    init(id: String = UUID().uuidString, userId: String, userName: String, text: String, rating: Double, foodTruckName: String? = nil) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.text = text
        self.rating = rating
        self.foodTruckName = foodTruckName
    }
}
