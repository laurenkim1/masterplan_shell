//
//  CreateProffrViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/26/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import Firebase

class CreateProffrViewController: UIViewController {
    
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    private var channelRefHandle: DatabaseHandle?
    var request: requestInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK :Actions
    @IBAction func createChannel(_ sender: AnyObject) {
        if let subTitle = request?.requestTitle { // username actually
            let newChannelRef = channelRef.childByAutoId() // 2
            let channelItem = [ // 3
                "name": name,
                "subTitle": subTitle
            ]
            newChannelRef.setValue(channelItem) // 4
        }
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
