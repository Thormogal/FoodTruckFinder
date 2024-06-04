//
//  Review.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-06-03.
//

import Foundation

struct Review: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String
    var userName: String
    var text: String
    var rating: Double
   // var date: Date = Date()
}
