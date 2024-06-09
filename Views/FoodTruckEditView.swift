//
//  FoodTruckEditView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-19.
//

import SwiftUI
import MapKit

struct FoodTruckEditView: View {
    @Binding var foodTruck: FoodTruck
    var onSave: () -> Void
    @StateObject private var imagePickerViewModel = TruckImagePickerViewModel()
    @State private var showingImagePicker = false
    @Environment(\.presentationMode) var presentationMode
    let foodTypes = ["Taco", "Sushi", "Hamburger", "Asian", "Indian", "Pizza", "Kebab", "Chicken"]
    @State private var address: String = ""
    @StateObject private var searchCompleter = SearchCompleter()
    @State private var showSuggestions = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General")) {
                    TextField("Name", text: $foodTruck.name)

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

                Section(header: Text("Daily Deals")) {
                    ForEach(Array($foodTruck.dailyDeals.enumerated()), id: \.element.id) { index, $item in
                        VStack {
                            TextField("Item Name", text: $item.name)
                            HStack {
                                TextField("Original Price", value: $item.originalPrice, formatter: NumberFormatter())
                                TextField("Deal Price", value: $item.dealPrice, formatter: NumberFormatter())
                            }
                            TextField("Ingredients", text: $item.ingredients)
                            Button(action: {
                                removeDailyDealItem(at: index)
                            }) {
                                Text("Remove Deal")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button(action: addDailyDealItem) {
                        Text("Add Daily Deal")
                    }
                }

                Section(header: Text("Location")) {
                    Text("Current Location: \(searchCompleter.currentAddress)")
                        .foregroundColor(.gray)
                        .italic()

                    TextField("New Address", text: $address)
                        .onChange(of: address) {
                            searchCompleter.queryFragment = address
                            showSuggestions = true
                        }

                    if showSuggestions && !searchCompleter.results.isEmpty {
                        List(searchCompleter.results, id: \.self) { suggestion in
                            Button(action: {
                                searchCompleter.selectSuggestion(suggestion) { coordinate in
                                    if let coordinate = coordinate {
                                        foodTruck.location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                        searchCompleter.reverseGeocodeLocation(location: location) { address in
                                            searchCompleter.currentAddress = address
                                        }
                                    }
                                    address = ""
                                    showSuggestions = false
                                }
                            }) {
                                VStack(alignment: .leading) {
                                    Text(suggestion.title)
                                    Text(suggestion.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }

                    TextField("Location Period (e.g., 9 June - 16 June)", text: $foodTruck.locationPeriod)
                        .padding(.top, 10)
                }

                Section {
                    Button(action: {
                        AuthManager.shared.signOut(presentationMode: presentationMode) { result in
                            switch result {
                            case .success:
                                print("Signed out successfully")
                            case .failure(let error):
                                print("Error signing out: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Edit Foodtruck")
            .navigationBarItems(leading: Button(action: {
                showingImagePicker = true
            }) {
                Image(systemName: "photo")
            }, trailing: Button("Done") {
                searchCompleter.searchAddress(address) { coordinate in
                    if let coordinate = coordinate {
                        foodTruck.location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        searchCompleter.reverseGeocodeLocation(location: location) { address in
                            searchCompleter.currentAddress = address
                        }
                    }
                    onSave()
                }
            })
            .sheet(isPresented: $showingImagePicker) {
                TruckImagePicker(image: $imagePickerViewModel.selectedImage) { image in
                    imagePickerViewModel.uploadImage()
                }
            }
            .onAppear {
                let location = CLLocation(latitude: foodTruck.location.latitude, longitude: foodTruck.location.longitude)
                searchCompleter.reverseGeocodeLocation(location: location) { address in
                    searchCompleter.currentAddress = address
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

    private func addDailyDealItem() {
        foodTruck.dailyDeals.append(DailyDealItem(name: "", originalPrice: 0.0, dealPrice: 0.0, ingredients: "", foodTruckName: foodTruck.name))
    }

    private func removeDailyDealItem(at index: Int) {
        foodTruck.dailyDeals.remove(at: index)
    }
}
