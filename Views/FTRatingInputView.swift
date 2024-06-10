//
//  RatingInputView.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-06-03.
//

import Foundation
import SwiftUI

struct FTRatingInputView: View {
    @Binding var isPresented: Bool
    @State private var rating: Double = 0
    var onRatingSubmitted: (Double) -> Void
    
    var body: some View {
        VStack {
            Text("Rate this Food Truck")
                .font(.headline)
                .padding()
            
            CustomRatingSlider(rating: $rating)
                .padding()
            
            Button(action: {
                onRatingSubmitted(rating)
                isPresented = false
                
            }) {
                Text("Submit Rating")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct CustomRatingSlider: View {
    @Binding var rating: Double
    let maxRating = 5
    let starSize: CGFloat = 40
    
    var body: some View {
        HStack {
            ForEach(1...maxRating, id: \.self) { index in
                Image(index <= Int(rating) ? "filledburger" : "burger")
                    .resizable()
                    .frame(width: starSize, height: starSize)
                    .onTapGesture {
                        rating = Double(index)
                    }
            }
        }
    }
}
