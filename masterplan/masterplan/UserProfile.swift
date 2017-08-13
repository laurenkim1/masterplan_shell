//
//  UserProfile.swift
//  masterplan
//
//  Created by Lauren Kim on 8/10/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import os.log
import CoreLocation

class UserProfile: NSObject {
    
    //MARK: Properties
    
    var userID: String
    var userName: String
    var homeLocation: CLLocation
    
    //MARK: Types
    
    struct PropertyKey {
        static let userID = "userID"
        static let userName = "userName"
        static let homeLocation = "homeLocation"
    }
    
    //MARK: Initialization
    
    init?(userID: String, userName: String, homeLocation: CLLocation) {
        
        // Initialization should fail if there is no name or if the price is negative.
        guard !userID.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.userID = userID
        self.userName = userName
        self.homeLocation = homeLocation
    }
    
    convenience init?(dict: NSDictionary) {
        guard let userID = dict["userID"] as? String else {
            os_log("Unable to decode the userID for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let userName = dict["userName"] as? String else {
            os_log("Unable to decode the userName for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let geoloc = dict["homeLocation"] as? NSDictionary else {
            os_log("Unable to decode the location for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let coordinates = geoloc["coordinates"] as? Array<Double> else {
            os_log("Unable to decode the coordinates for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        let homeLocation = CLLocation(latitude: coordinates[1], longitude: coordinates[0])
        /*guard let dateObject = dict["dateObject"] as? NSDictionary else {
         os_log("Unable to decode the date object for a request.", log: OSLog.default, type: .debug)
         return nil
         }
         guard let date = dateObject["$date"] as? String else {
         os_log("Unable to decode the date for a request.", log: OSLog.default, type: .debug)
         return nil
         }*/
        
        func stringToDate(date:String) -> NSDate {
            let formatter = DateFormatter()
            
            // Format 1
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let parsedDate = formatter.date(from: date) {
                return parsedDate as NSDate
            }
            return NSDate()
        }
        
        //let dateTime = stringToDate(date: date)
        self.init(userID: userID, userName: userName, homeLocation: homeLocation)
    }
    
    // MARK: Public Methods
    
    public func toLocation() -> NSDictionary! {
        let geoloc = NSMutableDictionary()
        let coordinates: NSArray = [homeLocation.coordinate.longitude, homeLocation.coordinate.latitude]
        geoloc.setValue("Point", forKey: "type")
        geoloc.setValue(coordinates, forKey: "coordinates")
        return geoloc
    }
    
    public func toDictionary() -> NSDictionary! {
        let jsonable = NSMutableDictionary()
        let geoloc: NSDictionary = self.toLocation()
        jsonable.setValue(userID, forKey: "userID")
        jsonable.setValue(userName, forKey: "userName")
        jsonable.setValue(geoloc, forKey: "homeLocation")
        return jsonable
    }
    
}
