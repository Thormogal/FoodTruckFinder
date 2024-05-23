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
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Category:Equatable, Identifiable {
    var id = UUID()
    var name: String
    var imageName: String
}

struct CategoryItemView: View {
    var category: Category
    var isSelected: Bool
    
    var body: some View {
        VStack {
            Image(category.imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
            Text(category.name)
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .primary)
        }
    }
}


struct HomeView: View {
    @State private var foodTrucks: [FoodTruck] = []
    @State private var filteredFoodTrucks: [FoodTruck] = []
    @State private var selectedCategory: Category? = nil
    @State private var categories: [Category] = [
        Category(name: "All", imageName: "all"),
        Category(name: "Taco", imageName: "taco"),
        Category(name: "Sushi", imageName: "sushi"),
        Category(name: "Hamburger", imageName: "hamburger"),
        Category(name: "Asian", imageName: "asian"),
        Category(name: "Indian", imageName: "indian"),
        Category(name: "Pizza", imageName: "pizza"),
        Category(name: "Kebab", imageName: "kebab"),
        Category(name: "Chicken", imageName: "chicken")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
          
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories) { category in
                            CategoryItemView(category: category, isSelected: category == selectedCategory)
                                .padding(.horizontal, 10)
                                .onTapGesture {
                                    selectedCategory = category
                                    filterFoodTrucks()
                                }
                        }
                    }
                    .padding()
                }
                
                
                List(filteredFoodTrucks) { foodTruck in
                    VStack(alignment: .leading) {
                        Text(foodTruck.name)
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
                                Text(foodTruck.openingHours)
                                Text("Food: \(foodTruck.foodType)")
                                RtingView(rating: Int(foodTruck.rating)) 
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
                do {
                    let foodTruck = try document.data(as: FoodTruck.self)
                    return foodTruck
                } catch {
                    print("Error decoding document into FoodTruck: \(error.localizedDescription)")
                    return nil
                }
            }
            filterFoodTrucks()
        }
    }
    
    private func filterFoodTrucks() {
            if let selectedCategory = selectedCategory, selectedCategory.name != "All" {
                filteredFoodTrucks = foodTrucks.filter { $0.foodType == selectedCategory.name }
            } else {
                filteredFoodTrucks = foodTrucks
            }
        }
    }



//struct HomeView_Previews: PreviewProvider {
////    static var previews: some View {
////        //HomeView()
////    }
//}

