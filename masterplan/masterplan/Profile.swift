//
//  Profile.swift
//  masterplan
//
//  Created by Lauren Kim on 8/18/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import Foundation
import CoreLocation
import os.log

internal class Profile {
    internal let userId: String
    internal let userName: String
    internal let firstName: String
    internal let lastName: String
    internal let userEmail: String
    internal let userLocation: CLLocation
    internal let fcmToken: String
    
    init(userId: String, userName: String, firstName: String, lastName: String, userEmail: String, userLocation: CLLocation, fcmToken: String) {
        
        self.userId = userId
        self.userName = userName
        self.firstName = firstName
        self.lastName = lastName
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
        jsonable.setValue(firstName, forKey: "firstName")
        jsonable.setValue(lastName, forKey: "lastName")
        jsonable.setValue(userEmail, forKey: "userEmail")
        jsonable.setValue(geoloc, forKey: "userLocation")
        jsonable.setValue(fcmToken, forKey: "fcmToken")
        jsonable.setValue([], forKey: "userRequests")
        return jsonable
    }
    
    convenience init?(dict: NSDictionary) {
        guard let userId = dict["userId"] as? String else {
            os_log("Unable to decode the userID for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let userName = dict["userName"] as? String else {
            os_log("Unable to decode the userName for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let firstName = dict["firstName"] as? String else {
            os_log("Unable to decode the firstName for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let lastName = dict["lastName"] as? String else {
            os_log("Unable to decode the lastName for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let fcmToken = dict["fcmToken"] as? String else {
            os_log("Unable to decode the name for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let geoloc = dict["userLocation"] as? NSDictionary else {
            os_log("Unable to decode the location for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let coordinates = geoloc["coordinates"] as? Array<Double> else {
            os_log("Unable to decode the coordinates for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        let userLocation = CLLocation(latitude: coordinates[1], longitude: coordinates[0])
        
        guard let userEmail = dict["userEmail"] as? String else {
            os_log("Unable to decode the photoUrl for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(userId: userId, userName: userName, firstName: firstName, lastName: lastName, userEmail: userEmail, userLocation: userLocation, fcmToken: fcmToken)
    }

}
