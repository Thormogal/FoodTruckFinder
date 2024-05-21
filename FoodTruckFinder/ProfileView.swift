//
//  ProfileView.swift
//  FoodTruckFinder
//
//  Created by Irfan Sarac on 2024-05-17.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 30.0) {
                Image("ProfilePic")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .padding(.leading)

                VStack(alignment: .leading) {
                    Text("Ahmad Saidan")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Göteborg, Sweden")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.leading)
            }
            .padding(.top)
            VStack(alignment: .leading) {
                HStack {
                    Image("HamburgerIcon")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Reviews")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.leading)
                Spacer()
            }
            .frame(maxHeight: .infinity)
            
            Spacer()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

