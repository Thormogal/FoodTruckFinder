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
    
    func fetchFoodTruck(by truckId: String, completion: @escaping (FoodTruckModel?) -> Void) {
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
                    if data["drinks"] == nil {
                        data["drinks"] = []
                    }
                    
                    if data["locationPeriod"] == nil {
                        data["locationPeriod"] = ""
                    }
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let foodTruck = try JSONDecoder().decode(FoodTruckModel.self, from: jsonData)
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
    
    func fetchFoodTrucks(completion: @escaping ([FoodTruckModel]) -> Void) {
        db.collection("foodTrucks").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
                return
            }
            
            let foodTrucks = querySnapshot?.documents.compactMap { document -> FoodTruckModel? in
                do {
                    var data = document.data()
                    if data["dailyDeals"] == nil {
                        data["dailyDeals"] = []
                    }
                    if data["menu"] == nil {
                        data["menu"] = []
                    }
                    if data["drinks"] == nil {
                        data["drinks"] = []
                    }
                    if data["locationPeriod"] == nil {
                        data["locationPeriod"] = ""
                    }
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let foodTruck = try JSONDecoder().decode(FoodTruckModel.self, from: jsonData)
                    return foodTruck
                } catch {
                    print("Error decoding food truck: \(error)")
                    return nil
                }
            } ?? []
            completion(foodTrucks)
        }
    }
    
    func saveFoodTruck(_ foodTruck: FoodTruckModel, completion: @escaping (Error?) -> Void) {
        do {
            let jsonData = try JSONEncoder().encode(foodTruck)
            let data = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
            print("Saving food truck data: \(data)") // Log the data being saved
            db.collection("foodTrucks").document(foodTruck.id).setData(data) { error in
                if let error = error {
                    print("Error saving food truck: \(error)")
                } else {
                    print("Food truck data successfully saved.")
                }
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
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
