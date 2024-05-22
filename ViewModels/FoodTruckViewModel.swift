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
    private var db = Firestore.firestore()
    var auth = Auth.auth()

    init() {
        // Initialize with empty FoodTruck object
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
            location: Location(latitude: 0.0, longitude: 0.0)
        )
        fetchFoodTruckData()
    }

    func fetchFoodTruckData() {
        guard let userId = auth.currentUser?.uid else { return }
        db.collection("foodTrucks").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let foodTruck = try document.data(as: FoodTruck.self)
                    self.foodTruck = foodTruck
                } catch {
                    print("Error decoding food truck: \(error)")
                }
            } else {
                print("Document does not exist")
            }
        }
    }


    func saveFoodTruckData() {
        guard let userId = auth.currentUser?.uid else { return }
        do {
            try db.collection("foodTrucks").document(userId).setData(from: foodTruck)
        } catch {
            print("Error saving food truck: \(error)")
        }
    }
}




