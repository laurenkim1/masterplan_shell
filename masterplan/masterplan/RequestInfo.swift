//
//  Request.swift
//  masterplan
//
//  Created by Lauren Kim on 7/4/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import os.log
import CoreLocation

class requestInfo: NSObject, NSCoding {
    
    //MARK: Properties
    
    var userID: String
    var requestTitle: String
    var requestPrice: Float
    var requestID: String?
    var fulfilled: Bool
    var fulfillerID: Int
    var requestTags: [String]
    var tagString: String
    var pickUp: Int
    var distance: Float
    var location: CLLocation
    
    //MARK: Types
    
    struct PropertyKey {
        static let userID = "userID"
        static let requestTitle = "requestTitle"
        static let requestPrice = "requestPrice"
        static let requestID = "requestID"
        static let pickUp = "pickUp"
        static let fulfilled = "fulfilled"
        static let fulfillerID = "fulfillerID"
        static let requestTags = "requestags"
        static let distance = "distance"
        static let location = "location"
        static let tagString = "tagString"
    }
    
    
    //MARK: Initialization
    
    init?(userID: String, requestTitle: String, requestPrice: Float, pickUp: Int, location: CLLocation) {
        
        // Initialization should fail if there is no name or if the price is negative.
        guard !requestTitle.isEmpty else {
            return nil
        }
        guard (requestPrice >= 0) else {
            return nil
        }
        
        // Initialize stored properties.
        self.userID = userID
        self.requestTitle = requestTitle
        self.requestPrice = requestPrice
        self.pickUp = pickUp
        self.location = location
        self.fulfilled = false
        self.fulfillerID = -1
        self.requestTags = []
        self.tagString = ""
        self.distance = 0.0
    }
    
    // MARK: Public Methods
    
    public func toDictionary() -> NSDictionary! {
        let jsonable = NSMutableDictionary()
        var tags: String = ""
        for tag in requestTags {
            tags.append(tag)
            tags.append(" ")
        }
        jsonable.setValue(userID, forKey: "userID")
        jsonable.setValue(requestTitle, forKey: "requestTitle")
        jsonable.setValue(requestPrice, forKey: "requestPrice")
        jsonable.setValue(pickUp, forKey: "pickUp")
        jsonable.setValue(location.coordinate.latitude, forKey: "xCoordinate")
        jsonable.setValue(location.coordinate.longitude, forKey: "yCoordinate")
        jsonable.setValue(fulfilled, forKey: "fulfilled")
        jsonable.setValue(fulfillerID, forKey: "fulfillerID")
        jsonable.setValue(tags, forKey: "requstTags")
        jsonable.setValue(distance, forKey: "distance")
        return jsonable
    }
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(userID, forKey: PropertyKey.userID)
        aCoder.encode(requestTitle, forKey: PropertyKey.requestTitle)
        aCoder.encode(requestPrice, forKey: PropertyKey.requestPrice)
        aCoder.encode(requestID, forKey: PropertyKey.requestID)
        aCoder.encode(pickUp, forKey: PropertyKey.pickUp)
        aCoder.encode(location, forKey: PropertyKey.location)
        aCoder.encode(fulfilled, forKey: PropertyKey.fulfilled)
        aCoder.encode(fulfillerID, forKey: PropertyKey.fulfillerID)
        aCoder.encode(distance, forKey: PropertyKey.distance)
        aCoder.encode(location, forKey: PropertyKey.location)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let userID = aDecoder.decodeObject(forKey: PropertyKey.userID) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let requestTitle = aDecoder.decodeObject(forKey: PropertyKey.requestTitle) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let requestPrice = aDecoder.decodeObject(forKey: PropertyKey.requestPrice) as? Float else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let pickUp = aDecoder.decodeObject(forKey: PropertyKey.pickUp) as? Int else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let location = aDecoder.decodeObject(forKey: PropertyKey.location) as? CLLocation else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Must call designated initializer.
        self.init(userID: userID, requestTitle: requestTitle, requestPrice: requestPrice, pickUp: pickUp, location: location)
        
    }
}
