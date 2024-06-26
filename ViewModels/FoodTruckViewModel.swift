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
    @Published var foodTruck: FoodTruckModel
    @Published var averageRating: Double = 0.0
    @Published var showingDeleteAlert = false
    @Published var showingPasswordAlert = false
    @Published var password: String = ""
    private var foodTruckService = FoodTruckService()
    private var db = Firestore.firestore()
    var auth = Auth.auth()
    
    init(foodTruck: FoodTruckModel? = nil) {
        if let foodTruck = foodTruck {
            self.foodTruck = foodTruck
            fetchAverageRating()
        } else {
            self.foodTruck = FoodTruckModel(
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
                drinks: [],
                dailyDeals: [],
                location: Location(latitude: 0.0, longitude: 0.0),
                locationPeriod: "",
                reviews: []
            )
        }
    }
    
    func addReview(_ review: ReviewModel) {
        // check for if the user already has an existing review for the food truck.
        if let userId = auth.currentUser?.uid,
           let existingReview = foodTruck.reviews.first(where: { $0.userId == userId }) {
            // update existing review
            updateReview(review)
        } else {
            // add new review
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
                    self.updateAverageRatingInFirestore() // update rating when adding a new review
                }
            }
        }
    }
    
    func updateReview(_ review: ReviewModel) {
        var updatedReview = review
        updatedReview.foodTruckName = foodTruck.name
        let foodTruckId = foodTruck.id
        let foodTruckRef = db.collection("foodTrucks").document(foodTruckId)
        
        // find the index for existing review
        if let existingReviewIndex = foodTruck.reviews.firstIndex(where: { $0.userId == review.userId }) {
            // remove old review and add the updated one.
            foodTruckRef.updateData([
                "reviews": FieldValue.arrayRemove([foodTruck.reviews[existingReviewIndex].dictionary])
            ]) { error in
                if let error = error {
                    print("Error removing old review: \(error)")
                } else {
                    foodTruckRef.updateData([
                        "reviews": FieldValue.arrayUnion([updatedReview.dictionary])
                    ]) { error in
                        if let error = error {
                            print("Error updating review: \(error)")
                        } else {
                            print("Review updated successfully")
                            self.foodTruck.reviews[existingReviewIndex] = updatedReview
                            self.updateAverageRatingInFirestore()
                        }
                    }
                }
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
        let averageRating = calculateAverageRating()
        let foodTruckId = foodTruck.id
        db.collection("foodTrucks").document(foodTruckId).updateData([
            "rating": averageRating
        ]) { error in
            if let error = error {
                print("Error updating average rating: \(error)")
            } else {
                print("Average rating updated successfully in Firestore")
                self.averageRating = averageRating
            }
        }
    }
    
    func calculateAverageRating() -> Double {
        let totalRating = foodTruck.ratings.reduce(0.0, +)
        let averageRating = totalRating / Double(foodTruck.ratings.count)
        print("Total rating: \(totalRating), Average rating: \(averageRating)")
        return averageRating
    }
    
    func fetchAverageRating() {
        let foodTruckRef = db.collection("foodTrucks").document(foodTruck.id)
        foodTruckRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(), let rating = data["rating"] as? Double {
                    DispatchQueue.main.async {
                        self.averageRating = rating
                    }
                }
            } else {
                if let error = error {
                    print("Error fetching average rating: \(error.localizedDescription)")
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func fetchFoodTruckData(by truckId: String) {
        print("Fetching food truck data for ID: \(truckId)")
        foodTruckService.fetchFoodTruck(by: truckId) { [weak self] foodTruck in
            DispatchQueue.main.async {
                if let foodTruck = foodTruck {
                    print("Successfully fetched food truck: \(foodTruck)")
                    self?.foodTruck = foodTruck
                    self?.fetchAverageRating()
                } else {
                    print("Food truck not found, initializing new food truck.")
                    self?.foodTruck = FoodTruckModel(
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
                        locationPeriod: "",
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
    
    func reauthenticateAndDeleteAccount() {
        ProfileService.shared.reauthenticateUser(password: password) { result in
            switch result {
            case .success:
                self.showingPasswordAlert = false
                self.showingDeleteAlert = true
            case .failure(let error):
                print("Error reauthenticating: \(error.localizedDescription)")
            }
        }
    }
    
    func addMenuItem() {
        foodTruck.menu.append(MenuItem(name: "", price: 0.0, ingredients: ""))
    }
    
    func removeMenuItem(at index: Int) {
        if foodTruck.menu.indices.contains(index) {
            foodTruck.menu.remove(at: index)
        }
    }
    
    func addDrinkItem() {
        foodTruck.drinks.append(DrinkItem(name: "", price: 0.0))
    }
    
    func removeDrinkItem(at index: Int) {
        if foodTruck.drinks.indices.contains(index) {
            foodTruck.drinks.remove(at: index)
        }
    }
    
    func addDailyDealItem() {
        foodTruck.dailyDeals.append(DailyDealItem(name: "", originalPrice: 0.0, dealPrice: 0.0, ingredients: "", foodTruckName: foodTruck.name, foodTruckId: foodTruck.id))
    }
    
    func removeDailyDealItem(at index: Int) {
        if foodTruck.dailyDeals.indices.contains(index) {
            foodTruck.dailyDeals.remove(at: index)
        }
    }
}

extension ReviewModel {
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
