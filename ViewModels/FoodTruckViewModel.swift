//
//  FoodTruckViewModel.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-19.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FoodTruckViewModel: ObservableObject {
    @Published var foodTruck: FoodTruck
    private var foodTruckService = FoodTruckService()
    
    init(foodTruck: FoodTruck? = nil) {
        if let foodTruck = foodTruck {
            self.foodTruck = foodTruck
        } else {
            self.foodTruck = FoodTruck(
                id: UUID().uuidString,
                name: "",
                rating: 0.0,
                foodType: "",
                priceRange: "",
                openingHours: "",
                paymentMethods: "",
                imageURL: "",
                menu: [],
                dailyDeals: [],
                location: Location(latitude: 0.0, longitude: 0.0)
            )
        }
    }
    
    func fetchFoodTruckData(by truckId: String) {
        print("Fetching food truck data for ID: \(truckId)")
        foodTruckService.fetchFoodTruck(by: truckId) { [weak self] foodTruck in
            DispatchQueue.main.async {
                if let foodTruck = foodTruck {
                    print("Successfully fetched food truck: \(foodTruck)")
                    self?.foodTruck = foodTruck
                } else {
                    print("Food truck not found, initializing new food truck.")
                    self?.foodTruck = FoodTruck(
                        id: truckId,
                        name: "",
                        rating: 0.0,
                        foodType: "",
                        priceRange: "",
                        openingHours: "",
                        paymentMethods: "",
                        imageURL: "",
                        menu: [],
                        dailyDeals: [],
                        location: Location(latitude: 0.0, longitude: 0.0)
                    )
                }
            }
        }
    }
    
    func saveFoodTruckData() {
        print("Saving food truck data for ID: \(foodTruck.id)")
        foodTruckService.saveFoodTruck(foodTruck) { error in
            if let error = error {
                print("Error saving food truck: \(error)")
            } else {
                print("Food truck successfully saved.")
            }
        }
    }
}
