//
//  SplashView.swif.swift
//  FoodTruckFinder
//
//  Created by Irfan Sarac on 2024-05-17.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            ContentView() 
        } else {
            Image("image 2")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
