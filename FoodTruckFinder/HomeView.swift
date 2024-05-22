//
//  HomeView.swift
//  FoodTruckFinder
//
//  Created by Irfan Sarac on 2024-05-17.
//

import SwiftUI
import Firebase
import FirebaseFirestore
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
    @State private var foodTrucks: [FoodTruck] = []
    
    var body: some View {
        NavigationStack {
            List(foodTrucks) { foodTruck in
                VStack(alignment: .leading) {
                    Text(foodTruck.name)
                        .font(.headline)
                        .padding(.bottom, 5)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    
                    HStack {
//                        if let imageURL = URL(string: foodTruck.imageURL) {
//                            AsyncImage(url: imageURL) { phase in
//                                if let image = phase.image {
//                                    image.resizable()
//                                         .frame(width: 100, height: 100)
//                                         .clipShape(Circle())
//                                } else {
                                    Image("cardpic")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
//                                }
//                            }
//                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(foodTruck.openingHours)
                            Text("Food: \(foodTruck.foodType)")
                            RtingView(rating: Int(foodTruck.rating)) // Pass rating directly
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
            .onAppear {
                fetchFoodTrucks()
            }
        }
    }
    
    private func fetchFoodTrucks() {
        let db = Firestore.firestore()
        db.collection("foodTrucks").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            self.foodTrucks = documents.compactMap { document -> FoodTruck? in
                try? document.data(as: FoodTruck.self)
            }
        }
    }
}



//struct HomeView_Previews: PreviewProvider {
////    static var previews: some View {
////        //HomeView()
////    }
//}

