//
//  FoodTruckEditView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-19.
//

import SwiftUI

struct FoodTruckEditView: View {
    @Binding var foodTruck: FoodTruck
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General")) {
                    TextField("Name", text: $foodTruck.name)
                    TextField("Food Type", text: $foodTruck.foodType)
                    TextField("Price Range", text: $foodTruck.priceRange)
                    TextField("Opening Hours", text: $foodTruck.openingHours)
                    TextField("Payment Methods", text: $foodTruck.paymentMethods)
                }

                Section(header: Text("Menu")) {
                    ForEach($foodTruck.menu) { $item in
                        TextField("Item Name", text: $item.name)
                        TextField("Item Price", value: $item.price, formatter: NumberFormatter())
                        TextField("Ingredients", text: $item.ingredients)
                    }
                }
            }
            .navigationBarTitle("Edit Foodtruck")
            .navigationBarItems(trailing: Button("Done") {
                onSave()
            })
        }
    }
}

struct FoodTruckEditView_Previews: PreviewProvider {
    static var previews: some View {
        let mockMenu = [
            MenuItem(id: UUID().uuidString, name: "Taco", price: 50, ingredients: "Beef, Lettuce, Cheese, Salsa"),
            MenuItem(id: UUID().uuidString, name: "Burrito", price: 80, ingredients: "Chicken, Rice, Beans, Cheese, Salsa")
        ]
        
        let mockFoodTruck = FoodTruck(
            id: UUID().uuidString,
            name: "Awesome Food Truck",
            rating: 4.5,
            foodType: "Mexican",
            priceRange: "80 - 140kr",
            openingHours: "10:00 - 20:00",
            paymentMethods: "Cash, Card",
            imageURL: "https://example.com/foodtruck.jpg",
            menu: mockMenu,
            location: Location(latitude: 59.3293, longitude: 18.0686)
        )
        
        FoodTruckEditView(foodTruck: .constant(mockFoodTruck), onSave: {})
    }
}



