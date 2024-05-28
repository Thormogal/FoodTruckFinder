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
    @State private var searchText = ""
    @State private var showSuggestions = false
    @StateObject private var searchCompleter = SearchCompleter()
    private let foodTruckService = FoodTruckService()

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
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
                                    .foregroundColor(.black)
                                    .font(.title)
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    fetchFoodTrucks()
                }
                
                VStack {
                    HStack {
                        SearchBar(
                            text: $searchCompleter.queryFragment,
                            suggestions: $searchCompleter.results,
                            onSearchButtonClicked: search,
                            onSuggestionSelected: selectSuggestion
                        )
                        .padding(.horizontal)
                        .background(Color.white.opacity(0.4))
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                    }
                    .padding(.top, 10) // Adjust this value to move the search bar higher or lower

                    if showSuggestions && !searchCompleter.results.isEmpty {
                        List(searchCompleter.results, id: \.self) { suggestion in
                            Button(action: {
                                selectSuggestion(suggestion)
                            }) {
                                VStack(alignment: .leading) {
                                    Text(suggestion.title)
                                    Text(suggestion.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                        .padding(.top, 5)
                    }

                    Spacer()
                }
            }
        }
        .onChange(of: searchCompleter.queryFragment) { _ in
            showSuggestions = true
        }
    }

    private func fetchFoodTrucks() {
        foodTruckService.fetchFoodTrucks { trucks in
            foodTrucks = trucks
        }
    }

    private func search() {
        guard let firstResult = searchCompleter.results.first else { return }
        selectSuggestion(firstResult)
    }

    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let item = response.mapItems.first {
                withAnimation {
                    locationManager.region = MKCoordinateRegion(
                        center: item.placemark.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
                searchText = suggestion.title
                showSuggestions = false
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
