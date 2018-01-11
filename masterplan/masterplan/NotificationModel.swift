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
    var requestPrice: Double
    var requestId: String
    var requesterId: String
    var requesterName: String
    var photoUrl: URL
    var postTime: NSDate?
    var postTimeString: String?
    var badgeCount: Int?
    
    //MARK: Types
    
    struct PropertyKey {
        static let userID = "userID"
        static let requestTitle = "requestTitle"
        static let requestPrice = "requestPrice"
        static let requestId = "requestId"
        static let requesterId = "requesterId"
        static let requesterName = "requesterName"
        static let photoURL = "photoUrl"
    }
    
    
    //MARK: Initialization
    
    init?(userID: String, requestTitle: String, requestPrice: Double, requestId: String, requesterId: String, requesterName: String, photoUrl: String) {
        
        // Initialization should fail if there is no name or if the price is negative.
        guard !requestTitle.isEmpty else {
            return nil
        }
        guard (requestPrice >= 0) else {
            return nil
        }
        
        let photoURL: URL = URL(string: photoUrl)!
        
        // Initialize stored properties.
        self.userID = userID
        self.requestTitle = requestTitle
        self.requestPrice = requestPrice
        self.requestId = requestId
        self.requesterId = requesterId
        self.requesterName = requesterName
        self.photoUrl = photoURL
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
            os_log("Unable to decode the requestprice for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let requesterId = dict["requesterId"] as? String else {
            os_log("Unable to decode the requsterId for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let requesterName = dict["requesterName"] as? String else {
            os_log("Unable to decode the requestername for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let photoUrl = dict["photoUrl"] as? String else {
            os_log("Unable to decode the userphoto for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let date = dict["createdAt"] as? String else {
            os_log("Unable to decode the date object for a request.", log: OSLog.default, type: .debug)
            return nil
        }
        
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
        self.init(userID: userID, requestTitle: requestTitle, requestPrice: Double(requestPrice), requestId: requestId, requesterId: requesterId, requesterName: requesterName, photoUrl: photoUrl)
        self.postTime = stringToDate(date: date)
    }
    
    // MARK: Public Methods
    
    public func toDictionary() -> NSDictionary! {
        let jsonable = NSMutableDictionary()
        
        let photoUrlString: String = photoUrl.absoluteString
        print(photoUrlString)
        
        jsonable.setValue(userID, forKey: "userID")
        jsonable.setValue(requestTitle, forKey: "requestTitle")
        jsonable.setValue(requestPrice, forKey: "requestPrice")
        jsonable.setValue(requestId, forKey: "requestId")
        jsonable.setValue(requesterId, forKey: "requesterId")
        jsonable.setValue(requesterName, forKey: "requesterName")
        jsonable.setValue(photoUrlString, forKey: "photoUrl")

        return jsonable
    }
}
