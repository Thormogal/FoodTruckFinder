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
}
