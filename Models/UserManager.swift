//
//  UserManager.swift
//  FoodTruckFinder
//
//  Created by Alvin Johansson on 2024-05-29.
//

import Foundation
class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    var userType: Int? = nil
}
