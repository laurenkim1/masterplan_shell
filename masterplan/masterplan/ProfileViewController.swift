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
import SwiftMessages

private let kBaseURL: String = "http://localhost:3000/"
private let kRequests: String = "requests/"
private let kUsers: String = "users/"

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myUserId: String!
    var myPhotoUrl: String!
    var userLocation: CLLocation!
    var myRequestList = [requestInfo]()
    var tableView: UITableView!
    var ProfilePhoto : UIImageView!
    var firstName: String!
    var lastName: String!
    
    lazy var firstNameLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        return view
    }()
    
    lazy var lastNameLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "Proffr"
        self.setNavigationBar()
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        ProfilePhoto = UIImageView()
        ProfilePhoto.frame = CGRect(x: 20, y: 80, width: self.view.frame.width-230, height: self.view.frame.width-230)
        ProfilePhoto.layer.borderWidth = 1
        ProfilePhoto.layer.masksToBounds = false
        ProfilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        ProfilePhoto.layer.cornerRadius = 10
        ProfilePhoto.clipsToBounds = true
        view.addSubview(ProfilePhoto)
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: self.ProfilePhoto.frame.origin.y+self.ProfilePhoto.frame.height+20, width: self.view.frame.width, height: self.view.frame.height-200))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.tableView.rowHeight = 80
        self.tableView.register(NearbyRequestTableViewCell.self, forCellReuseIdentifier: "NearbyRequestTableViewCell")
        self.getMyRequests()
        
        self.setProfilePhoto()
        self.setNameLabels()
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
    
    func setProfilePhoto() {
        let photoUrl = URL(string: myPhotoUrl)
        URLSession.shared.dataTask(with: photoUrl!) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print("Download Started")
            print(response?.suggestedFilename ?? photoUrl?.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                let image = UIImage(data: data)
                self.ProfilePhoto.image = image
            }
            }.resume()
    }
    
    func setNameLabels() {
        firstNameLabel.frame = CGRect(x: self.ProfilePhoto.frame.origin.x+self.ProfilePhoto.frame.width+10, y: 90, width: 150, height: 30)
        firstNameLabel.text = firstName
        firstNameLabel.textColor = UIColor.darkGray
        firstNameLabel.font = UIFont(name: "Ubuntu-Bold", size: 30)
        lastNameLabel.frame = CGRect(x: self.firstNameLabel.frame.origin.x, y: self.firstNameLabel.frame.origin.y+self.firstNameLabel.frame.height+10, width: 150, height: 30)
        lastNameLabel.text = lastName
        lastNameLabel.textColor = UIColor.darkGray
        lastNameLabel.font = UIFont(name: "Ubuntu-Bold", size: 30)
        self.view.addSubview(firstNameLabel)
        self.view.addSubview(lastNameLabel)
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
                if (!(response != nil)) {
                    self.warning()
                } else {
                    self.parseAndAddRequest(requestlist: response!)
                    self.tableView.reloadData()
                }
            }
        })
        dataTask?.resume()
    }
    
    func parseAndAddRequest(requestlist: Array<Any>) -> Void {
        for item in requestlist {
            if let request = requestInfo(dict: item as! NSDictionary) {
                //2
                myRequestList.insert(request, at: 0)
            }
        }
    }
    
    func warning() -> Void {
        let error = MessageView.viewFromNib(layout: .StatusLine)
        error.backgroundView.backgroundColor = UIColor.lightGray
        error.bodyLabel?.textColor = UIColor.white
        error.configureContent(body: "No Internet Connection")
        error.configureDropShadow()
        var errorConfig = SwiftMessages.defaultConfig
        errorConfig.duration = .seconds(seconds: 10)
        SwiftMessages.show(config: errorConfig, view: error)
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
        nextViewController.userLocation = userLocation
        navigationController?.pushViewController(nextViewController,
                                                 animated: true)
    }

}
