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
    private var db = Firestore.firestore()
    var auth = Auth.auth()
    
    init(foodTruck: FoodTruck? = nil) {
        if let foodTruck = foodTruck {
            self.foodTruck = foodTruck
        } else {
            self.foodTruck = FoodTruck(
                id: UUID().uuidString,
                name: "",
                rating: 0.0,
                ratings: [],
                foodType: "",
                priceRange: "",
                openingHours: "",
                paymentMethods: "",
                imageURL: "",
                menu: [],
                dailyDeals: [],
                location: Location(latitude: 0.0, longitude: 0.0),
                reviews: []
            )
        }
    }
    
    func addReview(_ review: Review) {
        var review = review
        review.foodTruckName = foodTruck.name
        let foodTruckId = foodTruck.id
        let foodTruckRef = db.collection("foodTrucks").document(foodTruckId)
        
        foodTruckRef.updateData([
            "reviews": FieldValue.arrayUnion([review.dictionary])
        ]) { error in
            if let error = error {
                print("Error updating reviews: \(error)")
            } else {
                print("Review added successfully")
                self.foodTruck.reviews.append(review)
            }
        }
    }

    func addRating(_ rating: Double) {
        let foodTruckId = foodTruck.id
        print("Adding rating to food truck ID: \(foodTruckId)")

        let foodTruckRef = db.collection("foodTrucks").document(foodTruckId)

        // Fetch the current document to get the existing ratings
        foodTruckRef.getDocument { document, error in
            if let document = document, document.exists {
                if var currentRatings = document.data()?["ratings"] as? [Double] {
                    currentRatings.append(rating)
                    self.updateRatingsInFirestore(currentRatings, for: foodTruckId)
                } else {
                    self.updateRatingsInFirestore([rating], for: foodTruckId)
                }
            } else {
                if let error = error {
                    print("Error fetching document: \(error.localizedDescription)")
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

    func updateRatingsInFirestore(_ ratings: [Double], for foodTruckId: String) {
        let foodTruckRef = db.collection("foodTrucks").document(foodTruckId)

        foodTruckRef.updateData([
            "ratings": ratings
        ]) { error in
            if let error = error {
                print("Error updating ratings: \(error)")
            } else {
                print("Ratings updated successfully")
                self.foodTruck.ratings = ratings
                self.foodTruck.rating = self.calculateAverageRating()
                self.updateAverageRatingInFirestore()
            }
        }
    }

    func updateAverageRatingInFirestore() {
        let foodTruckId = foodTruck.id
        db.collection("foodTrucks").document(foodTruckId).updateData([
            "rating": foodTruck.rating
        ]) { error in
            if let error = error {
                print("Error updating average rating: \(error)")
            } else {
                print("Average rating updated successfully in Firestore")
            }
        }
    }
    
    func calculateAverageRating() -> Double {
        let totalRating = foodTruck.ratings.reduce(0.0, +)
        let averageRating = totalRating / Double(foodTruck.ratings.count)
        print("Total rating: \(totalRating), Average rating: \(averageRating)")
        return averageRating
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
                        ratings: [],
                        foodType: "",
                        priceRange: "",
                        openingHours: "",
                        paymentMethods: "",
                        imageURL: "",
                        menu: [],
                        dailyDeals: [],
                        location: Location(latitude: 0.0, longitude: 0.0),
                        reviews: []
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

extension Review {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "userId": userId,
            "userName": userName,
            "text": text,
            "rating": rating,
            "foodTruckName": foodTruckName ?? "Unknown Food Truck"
        ]
    }
}
