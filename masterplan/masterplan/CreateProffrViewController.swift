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
    var senderDisplayName: String?
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
    @IBAction func createChannel(_ sender: UIButton) {
        if let subTitle = request?.requestTitle { // username actually
            let newChannelRef = channelRef.childByAutoId() // 2
            newChannelRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in // 1
                let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
                let id = snapshot.key
                if let name = channelData["name"] as! String!, name.characters.count > 0 { // 3
                    let channel = ProffrChannel(id: id, name: name, subTitle: channelData["subTitle"] as! String)
                    self.performSegue(withIdentifier: "ShowProffr", sender: channel)
                } else {
                    print("Error! Could not decode channel data")
                }
                
            })
            let channelItem = [ // 3
                "name": senderDisplayName,
                "subTitle": subTitle
            ]
            newChannelRef.setValue(channelItem) // 4
        }
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let channel = sender as? ProffrChannel {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.senderDisplayName = senderDisplayName
            chatVc.channel = channel
            chatVc.channelRef = channelRef.child(channel.id)
        }
    }

}
