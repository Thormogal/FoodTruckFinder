//
//  UserManager.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-29.
//

import Foundation
class UserManagerModel {
    static let shared = UserManagerModel()
    
    private init() {}
    
    var userType: Int? = nil
}
