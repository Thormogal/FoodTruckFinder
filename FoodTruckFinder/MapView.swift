//
//  MapView.swift
//  FoodTruckFinder
//
//  Created by Irfan Sarac on 2024-05-17.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var foodTrucks: [FoodTruck] = []
    private let foodTruckService = FoodTruckService()

    var body: some View {
        NavigationView {
            Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: foodTrucks) { truck in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: truck.location.latitude, longitude: truck.location.longitude)) {
                    NavigationLink(destination: FoodTruckProfileView(viewModel: FoodTruckViewModel(foodTruck: truck))) {
                        VStack {
                            Text(truck.name)
                                .font(.caption)
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                            
                            Image(systemName: "truck.box.fill")
                                .foregroundColor(.black
                                )
                                .font(.title)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                fetchFoodTrucks()
            }
        }
    }

    private func fetchFoodTrucks() {
        foodTruckService.fetchFoodTrucks { trucks in
            foodTrucks = trucks
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
