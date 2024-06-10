//
//  FoodTruckEditView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-19.
//

import SwiftUI
import MapKit

struct FoodTruckEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: FoodTruckViewModel
    @StateObject private var searchCompleter = SearchCompleter()
    @StateObject private var imagePickerViewModel = TruckImagePickerViewModel()
    @State private var showingImagePicker = false
    @State private var address: String = ""
    @State private var showSuggestions = false
    var onSave: () -> Void
    let foodTypes = ["Taco", "Sushi", "Hamburger", "Asian", "Indian", "Pizza", "Kebab", "Chicken"]
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General")) {
                    TextField("Name", text: $viewModel.foodTruck.name)
                    
                    Picker("Food Type", selection: $viewModel.foodTruck.foodType) {
                        ForEach(foodTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    TextField("Price Range", text: $viewModel.foodTruck.priceRange)
                    TextField("Opening Hours", text: $viewModel.foodTruck.openingHours)
                    TextField("Payment Methods", text: $viewModel.foodTruck.paymentMethods)
                }
                
                Section(header: Text("Menu")) {
                    ForEach(Array(viewModel.foodTruck.menu.enumerated()), id: \.element.id) { index, item in
                        VStack {
                            TextField("Item Name", text: binding(for: $viewModel.foodTruck.menu, index: index, keyPath: \.name))
                            TextField("Item Price", value: binding(for: $viewModel.foodTruck.menu, index: index, keyPath: \.price), formatter: NumberFormatter())
                            TextField("Ingredients", text: binding(for: $viewModel.foodTruck.menu, index: index, keyPath: \.ingredients))
                            Button(action: {
                                viewModel.removeMenuItem(at: index)
                            }) {
                                Text("Remove Item")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button(action: viewModel.addMenuItem) {
                        Text("Add Item")
                    }
                }
                
                Section(header: Text("Drinks")) {
                    ForEach(Array(viewModel.foodTruck.drinks.enumerated()), id: \.element.id) { index, item in
                        VStack {
                            TextField("Drink Name", text: binding(for: $viewModel.foodTruck.drinks, index: index, keyPath: \.name))
                            TextField("Drink Price", value: binding(for: $viewModel.foodTruck.drinks, index: index, keyPath: \.price), formatter: NumberFormatter())
                            Button(action: {
                                viewModel.removeDrinkItem(at: index)
                            }) {
                                Text("Remove Drink")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button(action: viewModel.addDrinkItem) {
                        Text("Add Drink")
                    }
                }
                
                Section(header: Text("Daily Deals")) {
                    ForEach(Array(viewModel.foodTruck.dailyDeals.enumerated()), id: \.element.id) { index, item in
                        VStack {
                            TextField("Item Name", text: binding(for: $viewModel.foodTruck.dailyDeals, index: index, keyPath: \.name))
                            HStack {
                                TextField("Original Price", value: binding(for: $viewModel.foodTruck.dailyDeals, index: index, keyPath: \.originalPrice), formatter: NumberFormatter())
                                TextField("Deal Price", value: binding(for: $viewModel.foodTruck.dailyDeals, index: index, keyPath: \.dealPrice), formatter: NumberFormatter())
                            }
                            TextField("Ingredients", text: binding(for: $viewModel.foodTruck.dailyDeals, index: index, keyPath: \.ingredients))
                            Button(action: {
                                viewModel.removeDailyDealItem(at: index)
                            }) {
                                Text("Remove Deal")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button(action: viewModel.addDailyDealItem) {
                        Text("Add Daily Deal")
                    }
                }
                
                Section(header: Text("Location")) {
                    Text("Current Location: \(searchCompleter.currentAddress)")
                        .foregroundColor(.gray)
                        .italic()
                    
                    TextField("New Address", text: $address)
                        .onChange(of: address) { oldAddress, newAddress in
                            searchCompleter.queryFragment = newAddress
                            showSuggestions = true
                        }
                    
                    if showSuggestions && !searchCompleter.results.isEmpty {
                        List(searchCompleter.results, id: \.self) { suggestion in
                            Button(action: {
                                searchCompleter.selectSuggestion(suggestion) { coordinate in
                                    if let coordinate = coordinate {
                                        viewModel.foodTruck.location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
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
                    
                    TextField("Location Period (e.g., 9 June - 16 June)", text: $viewModel.foodTruck.locationPeriod)
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
                
                Section {
                    Button(action: {
                        viewModel.showingPasswordAlert = true
                    }) {
                        Text("Delete Account")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationBarTitle("Edit Foodtruck")
            .navigationBarItems(leading: Button(action: {
                showingImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo")
                    Text("Truck Picture")
                }
            }, trailing: Button("Done") {
                searchCompleter.searchAddress(address) { coordinate in
                    if let coordinate = coordinate {
                        viewModel.foodTruck.location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
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
            .onChange(of: imagePickerViewModel.imageURL) { oldURL, newURL in
                if let newURL = newURL {
                    viewModel.foodTruck.imageURL = newURL
                }
            }
            .onAppear {
                let location = CLLocation(latitude: viewModel.foodTruck.location.latitude, longitude: viewModel.foodTruck.location.longitude)
                searchCompleter.reverseGeocodeLocation(location: location) { address in
                    searchCompleter.currentAddress = address
                }
            }
            .overlay(
                DeleteAccountAlertView(
                    isPresented: $viewModel.showingPasswordAlert,
                    password: $viewModel.password,
                    title: "Confirm Password",
                    message: "Please enter your password to confirm",
                    onConfirm: viewModel.reauthenticateAndDeleteAccount
                )
                .opacity(viewModel.showingPasswordAlert ? 1 : 0)
            )
            .alert(isPresented: $viewModel.showingDeleteAlert) {
                Alert(
                    title: Text("Delete Account"),
                    message: Text("Are you sure you want to delete your account?"),
                    primaryButton: .destructive(Text("Delete")) {
                        ProfileService.shared.deleteUserAccount { result in
                            switch result {
                            case .success:
                                print("User account deleted successfully")
                                self.presentationMode.wrappedValue.dismiss()
                            case .failure(let error):
                                print("Error deleting user account: \(error.localizedDescription)")
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func binding<Value>(for array: Binding<[Value]>, index: Int, keyPath: WritableKeyPath<Value, String>) -> Binding<String> {
        return Binding<String>(
            get: {
                if array.wrappedValue.indices.contains(index) {
                    return array.wrappedValue[index][keyPath: keyPath]
                }
                return ""
            },
            set: { newValue in
                if array.wrappedValue.indices.contains(index) {
                    array.wrappedValue[index][keyPath: keyPath] = newValue
                }
            }
        )
    }
    
    private func binding<Value>(for array: Binding<[Value]>, index: Int, keyPath: WritableKeyPath<Value, Double>) -> Binding<Double> {
        return Binding<Double>(
            get: {
                if array.wrappedValue.indices.contains(index) {
                    return array.wrappedValue[index][keyPath: keyPath]
                }
                return 0.0
            },
            set: { newValue in
                if array.wrappedValue.indices.contains(index) {
                    array.wrappedValue[index][keyPath: keyPath] = newValue
                }
            }
        )
    }
}

struct FoodTruckEditView_Previews: PreviewProvider {
    @State static var sampleFoodTruck = FoodTruck(
        id: UUID().uuidString,
        name: "Sample Truck",
        rating: 4.5,
        ratings: [4.5, 5.0, 4.0],
        foodType: "Taco",
        priceRange: "$$",
        openingHours: "9 AM - 5 PM",
        paymentMethods: "Cash, Credit",
        imageURL: "https://example.com/image.jpg",
        menu: [MenuItem(name: "Taco", price: 5.0, ingredients: "Beef, Cheese, Lettuce")],
        drinks: [DrinkItem(name: "Soda", price: 2.0)],
        dailyDeals: [DailyDealItem(name: "Discount Taco", originalPrice: 5.0, dealPrice: 3.0, ingredients: "Beef, Cheese, Lettuce", foodTruckName: "Sample Truck")],
        location: Location(latitude: 37.7749, longitude: -122.4194),
        locationPeriod: "9 June - 16 June",
        reviews: [Review(userId: "123", userName: "John Doe", text: "Great food!", rating: 5.0)]
    )
    
    static var previews: some View {
        FoodTruckEditView(
            viewModel: FoodTruckViewModel(foodTruck: sampleFoodTruck),
            onSave: {
                print("Save action")
            }
        )
    }
}
