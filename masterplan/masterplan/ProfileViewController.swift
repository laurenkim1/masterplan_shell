//
//  ProfileViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 8/12/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import os.log
import MapKit
import CoreLocation

private let kBaseURL: String = "http://localhost:3000/"
private let kRequests: String = "requests/"
private let kUsers: String = "users/"

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myUserId: String!
    var myRequestList = [requestInfo]()
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "Proffr"
        self.setNavigationBar()
        self.tableView = UITableView(frame: CGRect(x: 0, y: 200, width: self.view.frame.width, height: self.view.frame.height-200))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.tableView.rowHeight = 80
        self.tableView.register(NearbyRequestTableViewCell.self, forCellReuseIdentifier: "NearbyRequestTableViewCell")
        self.getMyRequests()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: Private Methods
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        // let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 70))
        
    }
    
    func getMyRequests() -> Void {
        let users: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kUsers).absoluteString
        let url = URL(string: (users + "myRequests/" + myUserId))
        //1
        var networkrequest = URLRequest(url: url!)
        networkrequest.httpMethod = "GET"
        //2
        networkrequest.addValue("application/json", forHTTPHeaderField: "Accept")
        //3
        let config = URLSessionConfiguration.default
        //4
        let session = URLSession(configuration: config)
        let dataTask: URLSessionDataTask? = session.dataTask(with: networkrequest, completionHandler: {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            //5
            if error == nil {
                os_log("Success")
                let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! Array<Any>
                self.parseAndAddRequest(requestlist: response!)
                self.tableView.reloadData()
            }
        })
        dataTask?.resume()
    }
    
    func parseAndAddRequest(requestlist: Array<Any>) -> Void {
        for item in requestlist {
            if let request = requestInfo(dict: item as! NSDictionary) {
                //2
                myRequestList += [request]
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myRequestList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "NearbyRequestTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NearbyRequestTableViewCell else {
            fatalError("The dequeued cell is not an instance of NearbyRequestTableViewCell.")
        }
        
        // Fetches the appropriate request for the data source layout.
        let myRequest = myRequestList[indexPath.row]
        
        let photoUrl = myRequest.photoUrl
        
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
        
        // change these parameters to match a request table cell
        cell.requestTitle.text = myRequest.requestTitle
        cell.nameLabel.text = myRequest.userName
        cell.requestPrice.text = "$" + String(format:"%.2f", myRequest.requestPrice)
        cell.distanceLabel.text = ""
        
        let components: NSDateComponents = NSDateComponents()
        components.setValue(24, forComponent: NSCalendar.Unit.hour)
        let endTime = NSCalendar.current.date(byAdding: components as DateComponents, to: myRequest.postTime as! Date)
        let nowTime = Date()
        let timeLeft: TimeInterval = (endTime?.timeIntervalSince(nowTime))!
        
        if timeLeft > 0 {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated
            let timeString = formatter.string(from: timeLeft)
            cell.timeLabel.text = timeString
            cell.inlabel.text = "in"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            cell.timeLabel.text = formatter.string(from: myRequest.postTime as! Date)
            cell.inlabel.text = ""
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let selectedRequest: requestInfo
        selectedRequest = myRequestList[indexPath.row]
        print(selectedRequest)
        cellSelected(selectedRequest: selectedRequest)
    }
    
    // MARK: - Navigation
    
    func cellSelected(selectedRequest: requestInfo){
        let nextViewController: RequestDetailsViewController = RequestDetailsViewController()
        nextViewController.request = selectedRequest
        nextViewController.myUserId = myUserId
        navigationController?.pushViewController(nextViewController,
                                                 animated: true)
    }

}
