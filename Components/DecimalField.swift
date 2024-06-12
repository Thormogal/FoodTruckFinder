//
//  DecimalField.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-06-11.
//

import SwiftUI

struct DecimalField: View {
    let title: String
    @Binding var value: Double
    @State private var textValue: String
    
    init(_ title: String, value: Binding<Double>) {
        self.title = title
        self._value = value
        self._textValue = State(initialValue: String(format: "%g", value.wrappedValue))
    }
    
    var body: some View {
        TextField(title, text: $textValue)
            .keyboardType(.decimalPad)
            .onChange(of: textValue) { oldValue, newValue in
                let sanitizedValue = newValue.replacingOccurrences(of: ",", with: ".")
                if let doubleValue = Double(sanitizedValue) {
                    value = doubleValue
                }
            }
            .onAppear {
                textValue = String(format: "%g", value)
            }
    }
}
