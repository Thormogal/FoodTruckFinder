//
//  FTMenuSectionView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI

struct FTMenuSectionView: View {
    var menu: [MenuItem]
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text("Menu")
                    .font(.title)
                    .bold()
                    .padding(.top, 10)
                    .padding(.bottom, 3)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                ForEach(menu) { item in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("\(item.price, specifier: "%.2f") kr")
                        }
                        .padding(.horizontal)
                        
                        Text("\(item.ingredients)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding([.horizontal, .top])
        }
    }
}
