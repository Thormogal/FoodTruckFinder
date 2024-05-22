//
//  RatingView.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-21.
//

import SwiftUI

struct RtingView: View {
    
    let rating: Int
    let maximumRating = 5
    
    var body: some View {
        HStack {
            ForEach(1...maximumRating, id: \.self) { index in
                Image(index <= rating ? "filledburger" : "burger")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        RatingView(rating: 4)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
