//
//  FTDrinksSectionView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct FTDrinksSectionView: View {
    var drinks: [DrinkItem]
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text("Drinks")
                    .font(.title)
                    .bold()
                    .padding(.top, 15)
                    .padding(.bottom, 3)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                ForEach(drinks) { drink in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(drink.name)
                            Spacer()
                            Text("\(drink.price, specifier: "%.2f") kr")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 15)
                }
            }
            .padding([.horizontal, .top])
        }
    }
}
