//
//  FoodTruck.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-19.
//

import Foundation
import CoreLocation

struct FoodTruckModel: Identifiable, Codable {
    var id: String
    var name: String
    var rating: Double
    var ratings: [Double]
    var foodType: String
    var priceRange: String
    var openingHours: String
    var paymentMethods: String
    var imageURL: String
    var menu: [MenuItem]
    var drinks: [DrinkItem] = []
    var dailyDeals: [DailyDealItem] = []
    var location: Location
    var locationPeriod: String
    var reviews: [ReviewModel]
    
    func distance(to userLocation: CLLocation) -> Double {
        let truckLocation = CLLocation(latitude: self.location.latitude, longitude: self.location.longitude)
        let distance = truckLocation.distance(from: userLocation) / 1000 // convert to kilometers
        print("Distance to \(self.name): \(distance) km")
        return distance
    }
}

struct Location: Codable, Equatable {
    var latitude: Double
    var longitude: Double
}

struct MenuItem: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var price: Double
    var ingredients: String
}

struct DrinkItem: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var price: Double
}

struct DailyDealItem: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var originalPrice: Double
    var dealPrice: Double
    var ingredients: String
    var foodTruckName: String
    var foodTruckId: String
}

func calculateDistance(from location1: Location, to location2: Location) -> Double {
    let lat1 = location1.latitude
    let lon1 = location1.longitude
    let lat2 = location2.latitude
    let lon2 = location2.longitude
    
    let earthRadius = 6371.0 // Earth's radius in kilometers
    
    let dLat = (lat2 - lat1) * .pi / 180.0
    let dLon = (lon2 - lon1) * .pi / 180.0
    
    let a = sin(dLat / 2) * sin(dLat / 2) +
    cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
    sin(dLon / 2) * sin(dLon / 2)
    
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    
    return earthRadius * c
}
