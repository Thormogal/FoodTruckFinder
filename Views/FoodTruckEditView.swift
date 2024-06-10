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
    @StateObject private var imagePickerViewModel = FoodTruckImagePickerViewModel()
    @State private var showingImagePicker = false
    @State private var address: String = ""
    @State private var showSuggestions = false
    var onSave: () -> Void
    let foodTypes = ["Taco", "Sushi", "Hamburger", "Asian", "Indian", "Pizza", "Kebab", "Chicken"]
    
    var body: some View {
        NavigationView {
            Form {
                GeneralEditView(viewModel: viewModel, foodTypes: foodTypes)
                MenuEditView(viewModel: viewModel)
                DrinksEditView(viewModel: viewModel)
                DailyDealsEditView(viewModel: viewModel)
                LocationEditView(viewModel: viewModel, searchCompleter: searchCompleter, address: $address, showSuggestions: $showSuggestions)
                
                LogoutEditView()
                DeleteAccountSectionView(viewModel: viewModel)
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
                saveAddressAndComplete()
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
    
    private func saveAddressAndComplete() {
        searchCompleter.searchAddress(address) { coordinate in
            if let coordinate = coordinate {
                viewModel.foodTruck.location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                searchCompleter.reverseGeocodeLocation(location: location) { address in
                    searchCompleter.currentAddress = address
                }
            }
            viewModel.saveFoodTruckData()
            onSave()
        }
    }
}

