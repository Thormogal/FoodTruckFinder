//
//  FTDailySectionsView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct FTDailyDealsSectionView: View {
    var dailyDeals: [DailyDealItem]
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text("🎉 Daily Deals 🎉")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.red)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                ForEach(dailyDeals) { deal in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(deal.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(deal.originalPrice, specifier: "%.2f") kr")
                                .strikethrough()
                                .foregroundColor(.gray)
                            Text("\(deal.dealPrice, specifier: "%.2f") kr")
                                .foregroundColor(.red)
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        Text("\(deal.ingredients)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding()
            .background(Color.yellow.opacity(0.3))
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .padding([.horizontal, .bottom])
    }
}
