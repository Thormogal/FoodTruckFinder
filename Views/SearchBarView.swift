//
//  SearchbarView.swift
//  FoodTruckFinder
//
//  Created by Frida Dahlqvist on 2024-05-28.
//

import SwiftUI
import UIKit
import MapKit

struct SearchBarView: UIViewRepresentable {
    @Binding var text: String
    @Binding var suggestions: [MKLocalSearchCompletion]
    var onSearchButtonClicked: () -> Void
    var onSuggestionSelected: (MKLocalSearchCompletion) -> Void
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        var onSearchButtonClicked: () -> Void
        var onSuggestionSelected: (MKLocalSearchCompletion) -> Void
        var parent: SearchBarView
        
        init(parent: SearchBarView, text: Binding<String>, onSearchButtonClicked: @escaping () -> Void, onSuggestionSelected: @escaping (MKLocalSearchCompletion) -> Void) {
            self.parent = parent
            _text = text
            self.onSearchButtonClicked = onSearchButtonClicked
            self.onSuggestionSelected = onSuggestionSelected
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
        return Coordinator(parent: self, text: $text, onSearchButtonClicked: onSearchButtonClicked, onSuggestionSelected: onSuggestionSelected)
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
