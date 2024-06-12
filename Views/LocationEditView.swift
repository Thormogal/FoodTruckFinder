//
//  LocationSectionView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI
import MapKit

struct LocationEditView: View {
    @ObservedObject var viewModel: FoodTruckViewModel
    @ObservedObject var searchCompleter: SearchCompleter
    @Binding var address: String
    @Binding var showSuggestions: Bool
    
    var body: some View {
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
                        updateLocation(with: suggestion)
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
    }
    
    private func updateLocation(with suggestion: MKLocalSearchCompletion) {
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
    }
}
