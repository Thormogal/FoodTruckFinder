//
//  SearchCompleter.swift
//  FoodTruckFinder
//
//  Created by Frida Dahlqvist on 2024-05-28.
//

import SwiftUI
import Combine
import MapKit

class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var queryFragment: String = ""
    @Published var results: [MKLocalSearchCompletion] = []
    @Published var currentAddress: String = "Loading current location..."
    private var completer: MKLocalSearchCompleter
    private var cancellables = Set<AnyCancellable>()

    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        self.completer.delegate = self
        self.completer.resultTypes = .address

        $queryFragment
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] fragment in
                self?.completer.queryFragment = fragment
            }
            .store(in: &cancellables)
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Failed to find search suggestions: \(error.localizedDescription)")
    }

    func searchAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = address
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, let item = response.mapItems.first else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            completion(item.placemark.coordinate)
        }
    }

    func selectSuggestion(_ suggestion: MKLocalSearchCompletion, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let searchRequest = MKLocalSearch.Request(completion: suggestion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, let item = response.mapItems.first else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            completion(item.placemark.coordinate)
        }
    }

    func reverseGeocodeLocation(location: CLLocation, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let street = placemark.thoroughfare ?? ""
                let city = placemark.locality ?? ""
                let formattedAddress = "\(street), \(city)"
                completion(formattedAddress)
            } else {
                completion("Unknown location")
                print("Error reverse geocoding location: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}



