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
    internal let name: String
    internal let subTitle: String
    internal let photoURL: URL
    
    init(id: String, name: String, subTitle: String, photoUrl: String) {
        
        let photoURL: URL = URL(string: photoUrl)!
        
        self.id = id
        self.name = name
        self.subTitle = subTitle
        self.photoURL = photoURL
    }
}
