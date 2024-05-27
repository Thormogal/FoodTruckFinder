//
//  RatingView.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-21.
//

import SwiftUI



struct RatingView: View {
    
    var rating: Double
   
       var body: some View {
           HStack {
               ForEach(0..<5) { index in
                   Image(index < Int(rating) ? "filledburger" : "burger")
                       .foregroundColor(index < Int(rating) ? .yellow : .gray)
               }
           }
           .padding(.horizontal)
       }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        RatingView(rating: 4)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
