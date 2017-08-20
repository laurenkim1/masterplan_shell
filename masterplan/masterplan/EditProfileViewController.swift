//
//  EditProfileViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 8/18/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import os.log
import MapKit
import CoreLocation
import Eureka

class EditProfileViewController: FormViewController {
    
    var userId: String!
    var userName: String!
    var userEmail: String!
    var userLocation: CLLocation!
    var neighborhood: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Proffr"
        
        form +++ Section("Profile")
            <<< TextRow("requestTitle"){ row in
                row.title = "Name:"
                row.placeholder = ""
                row.value = self.userName
            }
            <<< TextRow("Email"){
                $0.title = "Email:"
                $0.placeholder = ""
                $0.value = self.userEmail
            }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
