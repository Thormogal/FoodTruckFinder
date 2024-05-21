//
//  ContentView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-13.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

//Test av kommentar

struct ContentView: View {
    @State private var signedIn = false
    @State private var userType: Int? = nil
    @State private var foodTruck = FoodTruck(
           id: UUID().uuidString,
           name: "Sample Food Truck",
           rating: 4.5,
           foodType: "Mexican",
           priceRange: "80 - 140kr",
           openingHours: "10:00 - 20:00",
           paymentMethods: "Cash, Card",
           imageURL: "https://example.com/foodtruck.jpg",
           menu: [
               MenuItem(id: UUID().uuidString, name: "Taco", price: 50, ingredients: "Beef, Lettuce, Cheese, Salsa"),
               MenuItem(id: UUID().uuidString, name: "Burrito", price: 80, ingredients: "Chicken, Rice, Beans, Cheese, Salsa")
           ],
           location: Location(latitude: 59.3293, longitude: 18.0686)
       )
    
    var body: some View {
        if !signedIn {
            SignInView(signedIn: $signedIn, userType: $userType)
        } else {
            if let userType = userType {
                if userType == 1 {
                    
                    StartViewUser()
                } else if userType == 2 {
                    
                    FoodTruckEditView(foodTruck: $foodTruck)
                } else {
                    Text("Unknown user type")
                }
            } else {
                Text("Loading...")
            }
        }
    }
}

#Preview {
    ContentView()
}
