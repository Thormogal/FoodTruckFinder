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
    @State private var searchText = ""
    @GestureState private var zoomScale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, onSearchButtonClicked: search)
            Map(coordinateRegion: $locationManager.region, showsUserLocation: true)
                .edgesIgnoringSafeArea(.all)
                .gesture(
                    MagnificationGesture()
                        .updating($zoomScale) { (value, state, _) in
                            state = value
                        }
                        .onEnded { value in
                            let delta = value - 1.0
                            let currentSpan = locationManager.region.span
                            let newSpan = MKCoordinateSpan(latitudeDelta: currentSpan.latitudeDelta / Double(1 + delta), longitudeDelta: currentSpan.longitudeDelta / Double(1 + delta))
                            
                            locationManager.region.span = newSpan
                        }
                )
        }
    }
    
    private func search() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = locationManager.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Update the region to the first result
            if let item = response.mapItems.first {
                withAnimation {
                    locationManager.region = MKCoordinateRegion(
                        center: item.placemark.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
        }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var onSearchButtonClicked: () -> Void
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        var onSearchButtonClicked: () -> Void
        
        init(text: Binding<String>, onSearchButtonClicked: @escaping () -> Void) {
            _text = text
            self.onSearchButtonClicked = onSearchButtonClicked
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            onSearchButtonClicked()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, onSearchButtonClicked: onSearchButtonClicked)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search"
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
