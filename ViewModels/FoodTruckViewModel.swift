//
//  FoodTruckViewModel.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-19.
//

import Foundation
import Combine

class FoodTruckViewModel: ObservableObject {
    @Published var foodTruck: FoodTruck

    init() {
        // Mock data
        self.foodTruck = FoodTruck(
            id: UUID().uuidString,
            name: "Awesome Food Truck",
            rating: 4.5,
            foodType: "Mexican",
            priceRange: "80 - 140kr",
            openingHours: "10:00 - 20:00",
            paymentMethods: "Cash, Card",
            imageURL: "https://example.com/foodtruck.jpg",
            menu: [
                MenuItem(id: UUID().uuidString, name: "Taco", price: 50, ingredients: "Beef, Lettuce, Cheese, Salsa"),
                MenuItem(id: UUID().uuidString, name: "Burrito", price: 80, ingredients: "Chicken, Rice, Beans, Cheese, Salsa")
            ],
            location: Location(latitude: 59.3293, longitude: 18.0686)
        )
    }
}
