//
//  SubmitReviewView.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-06-03.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct SubmitReviewView: View {
    @ObservedObject var viewModels: FoodTruckViewModel
    @Binding var isPresented: Bool
    @State private var reviewText: String = ""
    @State private var rating: Double = 0
    @State private var existingReview: ReviewModel?
    
    var body: some View {
        VStack {
            Text(existingReview == nil ? "Write a Review" : "Edit Your Review")
                .font(.headline)
                .padding()
            
            TextField("Review", text: $reviewText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            CustomRatingSlider(rating: $rating)
                .padding()
            
            Button(action: {
                if let existingReview = existingReview {
                    // Update existing review
                    var updatedReview = existingReview
                    updatedReview.text = reviewText
                    updatedReview.rating = rating
                    viewModels.updateReview(updatedReview)
                } else {
                    // Add new review
                    let review = ReviewModel(
                        userId: Auth.auth().currentUser?.uid ?? "",
                        userName: Auth.auth().currentUser?.displayName ?? "Anonymous",
                        text: reviewText,
                        rating: rating,
                        foodTruckName: viewModels.foodTruck.name
                    )
                    viewModels.addReview(review)
                    viewModels.addRating(review.rating)
                }
                isPresented = false
            }) {
                Text(existingReview == nil ? "Submit Review" : "Update Review")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .onAppear {
            // Check if the user has already written a review for this food truck
            if let userId = Auth.auth().currentUser?.uid {
                existingReview = viewModels.foodTruck.reviews.first { $0.userId == userId }
                if let existingReview = existingReview {
                    reviewText = existingReview.text
                    rating = existingReview.rating
                }
            }
        }
    }
}
