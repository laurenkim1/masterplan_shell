//
//  MyProffrsViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/26/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import Firebase

class MyProffrsViewController: UITableViewController {
    
    
    // MARK: Properties
    
    private var channels: [ProffrChannel] = []
    
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    private var channelRefHandle: DatabaseHandle?

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(MyProffrsTableViewCell.self, forCellReuseIdentifier: "proffrChannel")
        
        self.refreshControl?.addTarget(self, action: #selector(MyProffrsViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        observeChannels()
    }
    
    deinit {
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "proffrChannel"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MyProffrsTableViewCell else {
            fatalError("The dequeued cell is not an instance of ProffrChannel.")
        }

        // Configure the cell...
        cell.senderLabel?.text = channels[(indexPath as NSIndexPath).row].name
        cell.subTitle?.text = channels[(indexPath as NSIndexPath).row].subTitle

        return cell
    }
    
    // MARK: Firebase related methods
    
    private func observeChannels() {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in // 1
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            let id = snapshot.key
            if let name = channelData["proffererName"] as! String!, name.characters.count > 0 { // 3
                self.channels.append(ProffrChannel(id: id, name: name, subTitle: channelData["subTitle"] as! String))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) -> Void {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let proffrChatVc = segue.destination as? ChatViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectedProffrCell = sender as? MyProffrsTableViewCell else {
            fatalError("Unexpected sender: \(sender)")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedProffrCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let channel = channels[indexPath.row]
        
        proffrChatVc.senderDisplayName = channel.name
        proffrChatVc.channel = channel
        let channeldataref = channelRef.child(channel.id)
        proffrChatVc.channelRef = channeldataref
        proffrChatVc.hidesBottomBarWhenPushed = true
    }

}
