//
//  ReviewsListView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-09.
//

import SwiftUI
import FirebaseAuth

struct ReviewsListView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    @State private var isReviewPresented = false
    var userType: Int
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                if userType == 1 {
                    let userId = Auth.auth().currentUser?.uid
                    let hasReview = viewModel.foodTruck.reviews.contains { $0.userId == userId }

                    Button(action: {
                        isReviewPresented = true
                    }) {
                        Text(hasReview ? "Edit Review" : "Write a Review")
                            .foregroundColor(.blue)
                    }
                    .padding()
                }

                List {
                    // My Review Section
                    if let userId = Auth.auth().currentUser?.uid,
                       let myReview = viewModel.foodTruck.reviews.first(where: { $0.userId == userId }) {
                        Section(header: Text("My Review").font(.headline)) {
                            ReviewRow(review: myReview)
                        }
                    }

                    // Other Reviews Section
                    Section(header: Text("All Reviews").font(.headline)) {
                        ForEach(viewModel.foodTruck.reviews.filter { $0.userId != Auth.auth().currentUser?.uid }) { review in
                            ReviewRow(review: review)
                        }
                    }
                }
                .navigationTitle("Reviews")
                .navigationBarItems(trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
        .sheet(isPresented: $isReviewPresented) {
            SubmitReviewView(viewModels: viewModel, isPresented: $isReviewPresented)
        }
    }
}

struct ReviewRow: View {
    var review: Review

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(review.userName)
                    .font(.headline)
                Spacer()
                RatingView(rating: review.rating)
            }
            Text(review.text)
                .font(.subheadline)
        }
        .padding(.vertical, 5)
    }
}
