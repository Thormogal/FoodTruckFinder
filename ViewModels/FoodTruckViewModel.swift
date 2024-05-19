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
                MenuItem(id: UUID().uuidString, name: "Taco", ingredients: "Beef, Lettuce, Cheese, Salsa", price: 50),
                MenuItem(id: UUID().uuidString, name: "Burrito", ingredients: "Chicken, Rice, Beans, Cheese, Salsa", price: 80)
            ],
            location: Location(latitude: 59.3293, longitude: 18.0686)
        )
    }
}
