//
//  NotificationModel.swift
//  masterplan
//
//  Created by Lauren Kim on 8/4/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import os.log
import CoreLocation

class notificationModel: NSObject {
    
    //MARK: Properties
    
    var userID: String
    var requestTitle: String
    var requestPrice: Float
    var requestId: String
    var requesterId: String
    var requesterName: String
    
    //MARK: Types
    
    struct PropertyKey {
        static let userID = "userID"
        static let requestTitle = "requestTitle"
        static let requestPrice = "requestPrice"
        static let requestId = "requestId"
        static let requesterId = "requesterId"
        static let requesterName = "requesterName"
    }
    
    
    //MARK: Initialization
    
    init?(userID: String, requestTitle: String, requestPrice: Float, requestId: String, requesterId: String, requesterName: String) {
        
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
        self.requestId = requestId
        self.requesterId = requesterId
        self.requesterName = requesterName
    }
    
    convenience init?(dict: NSDictionary) {
        guard let requestId = dict["requestId"] as? String else {
            os_log("Unable to decode the id for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let userID = dict["userID"] as? String else {
            os_log("Unable to decode the userID for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let requestTitle = dict["requestTitle"] as? String else {
            os_log("Unable to decode the name for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let requestPrice = dict["requestPrice"] as? Float else {
            os_log("Unable to decode the price for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let requesterId = dict["requesterId"] as? String else {
            os_log("Unable to decode the name for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let requesterName = dict["requesterName"] as? String else {
            os_log("Unable to decode the name for a request.", log: OSLog.default, type: .debug)
            return nil
        }
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
        self.init(userID: userID, requestTitle: requestTitle, requestPrice: requestPrice, requestId: requestId, requesterId: requesterId, requesterName: requesterName)
        //self.postTime = dateTime
    }
    
    // MARK: Public Methods
    
    public func toDictionary() -> NSDictionary! {
        let jsonable = NSMutableDictionary()
        jsonable.setValue(userID, forKey: "userID")
        jsonable.setValue(requestTitle, forKey: "requestTitle")
        jsonable.setValue(requestPrice, forKey: "requestPrice")
        jsonable.setValue(requestId, forKey: "requestId")
        jsonable.setValue(requesterId, forKey: "requsterId")
        jsonable.setValue(requesterName, forKey: "requesterName")

        return jsonable
    }
}
