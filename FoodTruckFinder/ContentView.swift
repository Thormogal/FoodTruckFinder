//
//  ContentView.swift
//  FoodTruckFinder
//
//  Created by Oskar Lövstrand on 2024-05-13.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

//Test av kommentar

struct ContentView: View {
        @State var signedIn = false
    
   
        var body: some View {
            if !signedIn{
                SignInView(signedIn: $signedIn)
    
            }else{
                StartViewUser()
            }
    
    
        }
    
}

#Preview {
    ContentView()
}
