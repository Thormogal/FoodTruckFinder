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
    @State private var showingDeleteAlert = false
    @State private var showingPasswordAlert = false
    @State private var password: String = ""

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
                        .onChange(of: address) { oldAddress, newAddress in
                            searchCompleter.queryFragment = newAddress
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
                
                Section {
                    Button(action: {
                        self.showingPasswordAlert = true
                    }) {
                        Text("Delete Account")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .listRowBackground(Color.clear)  // Remove the default white background of the Form
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
            .onChange(of: imagePickerViewModel.imageURL) { oldURL, newURL in
                if let newURL = newURL {
                    foodTruck.imageURL = newURL
                }
            }
            .onAppear {
                let location = CLLocation(latitude: foodTruck.location.latitude, longitude: foodTruck.location.longitude)
                searchCompleter.reverseGeocodeLocation(location: location) { address in
                    searchCompleter.currentAddress = address
                }
            }
            .overlay(
                DeleteAccountAlertView(
                    isPresented: $showingPasswordAlert,
                    password: $password,
                    title: "Confirm Password",
                    message: "Please enter your password to confirm",
                    onConfirm: reauthenticateAndDeleteAccount
                )
                .opacity(showingPasswordAlert ? 1 : 0)
            )
            .alert(isPresented: $showingDeleteAlert) {
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

    private func reauthenticateAndDeleteAccount() {
        ProfileService.shared.reauthenticateUser(password: password) { result in
            switch result {
            case .success:
                self.showingPasswordAlert = false
                self.showingDeleteAlert = true
            case .failure(let error):
                print("Error reauthenticating: \(error.localizedDescription)")
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
        dailyDeals: [DailyDealItem(name: "Discount Taco", originalPrice: 5.0, dealPrice: 3.0, ingredients: "Beef, Cheese, Lettuce", foodTruckName: "Sample Truck")],
        location: Location(latitude: 37.7749, longitude: -122.4194),
        locationPeriod: "9 June - 16 June",
        reviews: [Review(userId: "123", userName: "John Doe", text: "Great food!", rating: 5.0)]
    )

    static var previews: some View {
        FoodTruckEditView(
            foodTruck: $sampleFoodTruck,
            onSave: {
                print("Save action")
            }
        )
    }
}

