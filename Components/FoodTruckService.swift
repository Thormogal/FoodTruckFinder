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
    
    func fetchFoodTruck(by truckId: String, completion: @escaping (FoodTruck?) -> Void) {
        db.collection("foodTrucks").document(truckId).getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    var data = document.data()!
                    if data["dailyDeals"] == nil {
                        data["dailyDeals"] = []
                    }
                    if data["menu"] == nil {
                        data["menu"] = []
                    }
                    // Ensure locationPeriod is handled
                    if data["locationPeriod"] == nil {
                        data["locationPeriod"] = ""
                    }
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let foodTruck = try JSONDecoder().decode(FoodTruck.self, from: jsonData)
                    completion(foodTruck)
                } catch {
                    print("Error decoding food truck: \(error)")
                    completion(nil)
                }
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }
    
    func fetchFoodTrucks(completion: @escaping ([FoodTruck]) -> Void) {
        db.collection("foodTrucks").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
                return
            }
            
            let foodTrucks = querySnapshot?.documents.compactMap { document -> FoodTruck? in
                do {
                    var data = document.data()
                    if data["dailyDeals"] == nil {
                        data["dailyDeals"] = []
                    }
                    if data["menu"] == nil {
                        data["menu"] = []
                    }
                    if data["locationPeriod"] == nil {
                        data["locationPeriod"] = ""
                    }
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let foodTruck = try JSONDecoder().decode(FoodTruck.self, from: jsonData)
                    return foodTruck
                } catch {
                    print("Error decoding food truck: \(error)")
                    return nil
                }
            } ?? []
            completion(foodTrucks)
        }
    }
    
    func saveFoodTruck(_ foodTruck: FoodTruck, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection("foodTrucks").document(foodTruck.id).setData(from: foodTruck) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
    // New function for fetching daily deals
    func fetchAllDailyDeals(completion: @escaping ([DailyDealItem]) -> Void) {
        db.collection("foodTrucks").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
                return
            }
            
            var allDailyDeals: [DailyDealItem] = []
            for document in querySnapshot!.documents {
                let foodTruckId = document.documentID
                let foodTruckName = document.data()["name"] as? String ?? "Unknown"
                if let data = document.data()["dailyDeals"] as? [[String: Any]] {
                    for dealData in data {
                        var dealDataWithTruckInfo = dealData
                        dealDataWithTruckInfo["foodTruckName"] = foodTruckName
                        dealDataWithTruckInfo["foodTruckId"] = foodTruckId
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: dealDataWithTruckInfo, options: [])
                            let dailyDeal = try JSONDecoder().decode(DailyDealItem.self, from: jsonData)
                            allDailyDeals.append(dailyDeal)
                        } catch {
                            print("Error decoding daily deal: \(error)")
                        }
                    }
                }
            }
            completion(allDailyDeals)
        }
    }
}
