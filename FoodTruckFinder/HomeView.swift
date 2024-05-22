//
//  HomeView.swift
//  FoodTruckFinder
//
//  Created by Irfan Sarac on 2024-05-17.
//

import SwiftUI

extension UIColor {
    static func fromHex(_ hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading) {
                    Text("Jevez FoodTruck")
                                         .font(.headline)
                                         .padding(.bottom, 5)
                                         .frame(maxWidth: .infinity)
                                         .multilineTextAlignment(.center)
                                    
                    HStack {
                        Image("cardpic")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Open: 11.00-18.00")
                            Text("Food: Mexican")
                            RtingView(rating: 3)
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(Color(UIColor.fromHex("3D84B7")))
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .padding(.vertical, 5)
            }
            .listStyle(PlainListStyle())
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

