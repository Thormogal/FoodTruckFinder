//
//  FTLocationMapView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-10.
//

import SwiftUI
import MapKit

struct FTLocationMapView: View {
    var foodTruck: FoodTruckModel
    var userLocation: CLLocationCoordinate2D?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Map {
                Marker(foodTruck.name, coordinate: CLLocationCoordinate2D(latitude: foodTruck.location.latitude, longitude: foodTruck.location.longitude))
                if let userLocation = userLocation {
                    Marker("Your Location", coordinate: userLocation)
                }
            }
            .mapStyle(.standard)
            .navigationTitle("\(foodTruck.name) Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(foodTruck.name) Location")
                        .font(.largeTitle)
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
