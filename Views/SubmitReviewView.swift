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

    var body: some View {
        VStack {
            Text("Write a Review")
                .font(.headline)
                .padding()
            
            TextField("Review", text: $reviewText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            CustomRatingSlider(rating: $rating)
                .padding()
            
            Button(action: {
                let review = Review(
                    userId: Auth.auth().currentUser?.uid ?? "",
                    userName: Auth.auth().currentUser?.displayName ?? "Anonymous",
                    text: reviewText,
                    rating: rating
                )
                viewModels.addReview(review)
                viewModels.addRating(review.rating)
                isPresented = false
            }) {
                Text("Submit Review")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}
