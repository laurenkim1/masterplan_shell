//
//  MyProffrsViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/26/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class MyProffrsViewController: UITableViewController {
    
    
    // MARK: Properties
    
    var myUserId: String!
    var userLocation: CLLocation!
    private var incomingChannels: [ProffrChannel] = []
    private var outgoingChannels: [ProffrChannel] = []
    
    var segmentedControl: UISegmentedControl!
    
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    private var channelRefHandle: DatabaseHandle?

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let segmentTextContent = [
            NSLocalizedString("Incoming", comment: ""),
            NSLocalizedString("Outgoing", comment: "")
        ]
        
        // Segmented control as the custom title view
        segmentedControl = UISegmentedControl(items: segmentTextContent)
        segmentedControl.autoresizingMask = .flexibleWidth
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 400, height: 30)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(action(_:)), for: .valueChanged)
        
        self.navigationItem.titleView = segmentedControl
        
        tableView.register(MyProffrsTableViewCell.self, forCellReuseIdentifier: "proffrChannel")
        self.tableView.delegate = self
        self.tableView.rowHeight = 80
        self.tableView.allowsSelection = true
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.isUserInteractionEnabled = true
        
        //self.refreshControl?.addTarget(self, action: #selector(MyProffrsViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        observeIncomingChannels()
        observeOutgoingChannels()
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
        let channels: [ProffrChannel]!
        if self.segmentedControl.selectedSegmentIndex == 0 {
            channels = self.incomingChannels
        } else {
            channels = self.outgoingChannels
        }
        return channels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "proffrChannel"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MyProffrsTableViewCell else {
            fatalError("The dequeued cell is not an instance of ProffrChannel.")
        }
        
        let channels: [ProffrChannel]!
        if self.segmentedControl.selectedSegmentIndex == 0 {
            channels = self.incomingChannels
        } else {
            channels = self.outgoingChannels
        }
        
        // let senderId: String = channels[(indexPath as NSIndexPath).row].id
        let photoUrl: URL = channels[(indexPath as NSIndexPath).row].photoUrl 

        // Configure the cell...
        cell.senderLabel.text = channels[(indexPath as NSIndexPath).row].name
        cell.subTitle.text = channels[(indexPath as NSIndexPath).row].subTitle
        
        URLSession.shared.dataTask(with: photoUrl) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print("Download Started")
            print(response?.suggestedFilename ?? photoUrl.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                let image = UIImage(data: data)
                cell.ProfilePhoto.image = image
            }
        }.resume()

        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channels: [ProffrChannel]!
        if self.segmentedControl.selectedSegmentIndex == 0 {
            channels = self.incomingChannels
        } else {
            channels = self.outgoingChannels
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let selectedProffr: ProffrChannel = channels[indexPath.row]
        print(selectedProffr)
        cellSelected(channel: selectedProffr)
    }
    
    // MARK: Firebase related methods
    
    private func observeIncomingChannels() {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        
        // let channelRefQuery = channelRef.queryOrderedByKey().queryLimited(toLast: 100)
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in // 1
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            let id = snapshot.key
            if let name = channelData["proffererName"] as! String!, name.characters.count > 0 { // 3
                let requesterId: String = channelData["requesterId"] as! String
                if requesterId == self.myUserId {
                    let photoUrl: String = channelData["proffrerPhotoUrl"] as! String
                    self.incomingChannels.append(ProffrChannel(id: id, name: name, subTitle: channelData["subTitle"] as! String, photoUrl: photoUrl, requestId: channelData["requestId"] as! String))
                }
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
        
    }
    
    private func observeOutgoingChannels() {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        
        // let channelRefQuery = channelRef.queryOrderedByKey().queryLimited(toLast: 20)
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in // 1
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            let id = snapshot.key
            if let name = channelData["proffererName"] as! String!, name.characters.count > 0 { // 3
                let senderId: String = channelData["proffrerId"] as! String
                if senderId == self.myUserId {
                    let photoUrl: String = channelData["proffrerPhotoUrl"] as! String
                    self.outgoingChannels.append(ProffrChannel(id: id, name: name, subTitle: channelData["subTitle"] as! String, photoUrl: photoUrl, requestId: channelData["requestId"] as! String))
                }
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
        
    }
    
    func action(_ sender: AnyObject) {
        print("CustomTitleViewController IBAction invoked!")
        self.tableView.reloadData()
    }
    
    /*
    func handleRefresh(refreshControl: UIRefreshControl) -> Void {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        self.observeChannels()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
 */


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
    
    func cellSelected(channel: ProffrChannel){
        let proffrChatVc: ChatViewController = ChatViewController()
        
        proffrChatVc.senderDisplayName = channel.name
        proffrChatVc.channel = channel
        proffrChatVc.requestId = channel.requestId
        proffrChatVc.requestTitle = channel.subTitle
        proffrChatVc.userLocation = self.userLocation
        let channeldataref = channelRef.child(channel.id)
        proffrChatVc.channelRef = channeldataref
        proffrChatVc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(proffrChatVc,
                                                 animated: false)
    }
    
    /*
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
 */

}
