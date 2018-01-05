//
//  ProffrChannel.swift
//  masterplan
//
//  Created by Lauren Kim on 7/26/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import Foundation

internal class ProffrChannel {
    internal let id: String
    internal let proffrerId: String
    internal let name: String
    internal let subTitle: String
    internal let photoUrl: URL
    internal let requestId: String
    internal let alreadyAccepted: Int
    
    init(id: String, proffrerId: String, name: String, subTitle: String, photoUrl: String, requestId: String, alreadyAccepted: Int) {
        
        let photoURL: URL = URL(string: photoUrl)!
        
        self.id = id
        self.proffrerId = proffrerId
        self.name = name
        self.subTitle = subTitle
        self.photoUrl = photoURL
        self.requestId = requestId
        self.alreadyAccepted = alreadyAccepted
    }
}
