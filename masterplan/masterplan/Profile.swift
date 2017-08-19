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
    internal let userLocation: CLLocation
    
    init(userId: String, userName: String, userLocation: CLLocation) {
        
        self.userId = userId
        self.userName = userName
        self.userLocation = userLocation
    }
}
