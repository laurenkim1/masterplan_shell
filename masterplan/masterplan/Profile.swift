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
    internal let fcmToken: String
    
    init(userId: String, userName: String, userEmail: String, userLocation: CLLocation, fcmToken: String) {
        
        self.userId = userId
        self.userName = userName
        self.userEmail = userEmail
        self.userLocation = userLocation
        self.fcmToken = fcmToken
    }
    
    // MARK: Public Methods
    
    public func toLocation() -> NSDictionary! {
        let geoloc = NSMutableDictionary()
        let coordinates: NSArray = [userLocation.coordinate.longitude, userLocation.coordinate.latitude]
        geoloc.setValue("Point", forKey: "type")
        geoloc.setValue(coordinates, forKey: "coordinates")
        return geoloc
    }
    
    public func toDictionary() -> NSDictionary! {
        let jsonable = NSMutableDictionary()
        let geoloc: NSDictionary = self.toLocation()
        jsonable.setValue(userId, forKey: "userId")
        jsonable.setValue(userName, forKey: "userName")
        jsonable.setValue(userEmail, forKey: "userEmail")
        jsonable.setValue(geoloc, forKey: "userLocation")
        jsonable.setValue(fcmToken, forKey: "fcmToken")
        jsonable.setValue([], forKey: "userRequests")
        return jsonable
    }
}
