//
//  newRequestPlaceholder.swift
//  masterplan
//
//  Created by Lauren Kim on 7/15/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit

class NewRequestPlaceholderVC: UIViewController {
    
    var myDisplayName: String!
    var myUserId: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func unwindToNewRequestPlaceholder(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? TagListViewController, let request = sourceViewController.request {
            
            // Add the new request
            
            // Trigger unwind to homepage
        }
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVc = segue.destination as! UINavigationController
        let newRequestVc = navVc.viewControllers.first as! NewRequestViewController
        newRequestVc.myUserId = myUserId
        newRequestVc.myDisplayName = myDisplayName
    }

}
