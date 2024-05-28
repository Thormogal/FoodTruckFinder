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
    @StateObject private var imagePickerViewModel = TruckImagePickerViewModel()
    @State private var showingImagePicker = false
    let foodTypes = ["Taco", "Sushi", "Hamburger", "Asian", "Indian", "Pizza", "Kebab", "Chicken"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General")) {
                    TextField("Name", text: $foodTruck.name)
                    
                    // Food Type Picker
                    Picker("Food Type", selection: $foodTruck.foodType) {
                        ForEach(foodTypes, id: \.self) {
                            Text($0)
                        }
                    }

                    TextField("Price Range", text: $foodTruck.priceRange)
                    TextField("Opening Hours", text: $foodTruck.openingHours)
                    TextField("Payment Methods", text: $foodTruck.paymentMethods)
                }

                Section(header: Text("Menu")) {
                    ForEach(Array($foodTruck.menu.enumerated()), id: \.element.id) { index, $item in
                        VStack {
                            TextField("Item Name", text: $item.name)
                            TextField("Item Price", value: $item.price, formatter: NumberFormatter())
                            TextField("Ingredients", text: $item.ingredients)
                            Button(action: {
                                removeMenuItem(at: index)
                            }) {
                                Text("Remove Item")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button(action: addMenuItem) {
                        Text("Add Item")
                    }
                }
            }
            .navigationBarTitle("Edit Foodtruck")
            .navigationBarItems(leading: Button(action: {
                showingImagePicker = true
            }) {
                Image(systemName: "photo")
            }, trailing: Button("Done") {
                onSave()
            })
            .sheet(isPresented: $showingImagePicker) {
                TruckImagePicker(image: $imagePickerViewModel.selectedImage) { image in
                    imagePickerViewModel.uploadImage()
                }
            }
            .onChange(of: imagePickerViewModel.imageURL) { newURL in
                if let newURL = newURL {
                    foodTruck.imageURL = newURL
                }
            }
        }
    }

    private func addMenuItem() {
        foodTruck.menu.append(MenuItem(name: "", price: 0.0, ingredients: ""))
    }

    private func removeMenuItem(at index: Int) {
        foodTruck.menu.remove(at: index)
    }
}






