//
//  Profile.swift
//  masterplan
//
//  Created by Lauren Kim on 8/18/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import Foundation
import CoreLocation

internal class Profile {
    internal let userId: String
    internal let userName: String
    internal let userEmail: String
    internal let userLocation: CLLocation
    internal let neighborhood: String
    
    init(userId: String, userName: String, userEmail: String, userLocation: CLLocation, neighborhood: String) {
        
        self.userId = userId
        self.userName = userName
        self.userEmail = userEmail
        self.userLocation = userLocation
        self.neighborhood = neighborhood
    }
}
