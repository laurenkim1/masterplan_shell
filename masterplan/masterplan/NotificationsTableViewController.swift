//
//  NotificationsTableViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 8/6/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import Photos
import os.log
import Firebase
import SwiftMessages

private let kBaseURL: String = "http://18.221.170.199/"
private let kNotifications: String = "notifications/"
private let kRequests: String = "requests/"

class NotificationsTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var myUserId: String!
    var userLocation: CLLocation!
    private var notifications: [notificationModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(NotificationsTableViewCell.self, forCellReuseIdentifier: "notificationCell")
        tableView.rowHeight = 80
        self.getNotifications()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "notificationCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NotificationsTableViewCell else {
            fatalError("The dequeued cell is not an instance of TableViewCell.")
        }

        // Configure the cell...
        
        let photoUrl: URL = notifications[(indexPath as NSIndexPath).row].photoUrl 
        
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
        
        cell.requestTitle.text = notifications[(indexPath as NSIndexPath).row].requestTitle
        cell.requesterName.text = notifications[(indexPath as NSIndexPath).row].requesterName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let selectedRequest: String!
        selectedRequest = notifications[indexPath.row].requestId
        print(selectedRequest)
        getRequest(requestId: selectedRequest)
    }
    
    // Mark: Private Methods
    
    func getNotifications() -> Void {
        let requests: String = kBaseURL + kNotifications
        let parameterString: String = self.myUserId
        let url = URL(string: (requests + parameterString))
        //1
        var networkrequest = URLRequest(url: url!)
        networkrequest.httpMethod = "GET"
        //2
        networkrequest.addValue("application/json", forHTTPHeaderField: "Accept")
        //3
        let config = URLSessionConfiguration.default
        //4
        let session = URLSession(configuration: config)
        self.notifications = []
        self.tableView.reloadData()
        let group = DispatchGroup()
        group.enter()
        
        let dataTask: URLSessionDataTask? = session.dataTask(with: networkrequest, completionHandler: {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            //5
            if error == nil {
                os_log("Success")
                let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! Array<Any>
                if (!(response != nil)) {
                    self.warning()
                } else {
                    self.parseAndAddNotification(notificationlist: response!)
                    group.leave()
                }
            }
        })
        dataTask?.resume()
        group.wait()
        self.tableView.reloadData()
    }
    
    func parseAndAddNotification(notificationlist: Array<Any>) -> Void {
        for item in notificationlist {
            if let notification = notificationModel(dict: item as! NSDictionary) {
                //2
                notifications.append(notification)
            }
        }
    }
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) -> Void {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        self.getNotifications()
        refreshControl.endRefreshing()
    }
    
    func getRequest(requestId: String) -> Void {
        let requests: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kRequests).absoluteString
        let url = URL(string: (requests + "/search/" + requestId))
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
                let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                DispatchQueue.main.async() {
                    if response != nil {
                        self.parseRequest(request: response!)
                    } else {
                        self.warning()
                    }
                }
            }
        })
        dataTask?.resume()
    }
    
    func parseRequest(request: NSDictionary) -> Void {
        let request = requestInfo(dict: request)
        let detailVc: RequestDetailsViewController = RequestDetailsViewController()
        detailVc.userLocation = userLocation
        detailVc.request = request
        detailVc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(detailVc,
                                                 animated: true)
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

}
