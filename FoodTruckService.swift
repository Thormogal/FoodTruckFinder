//
//  FoodTruckService.swift
//  FoodTruckFinder
//
//  Created by Frida Dahlqvist on 2024-05-27.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FoodTruckService {
    private var db = Firestore.firestore()
    
    func fetchFoodTrucks(completion: @escaping ([FoodTruck]) -> Void) {
        db.collection("foodTrucks").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
                return
            }
            
            let foodTrucks = querySnapshot?.documents.compactMap { document -> FoodTruck? in
                return try? document.data(as: FoodTruck.self)
            } ?? []
            completion(foodTrucks)
        }
    }
}
