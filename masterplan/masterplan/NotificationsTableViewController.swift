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
import Material
import DGElasticPullToRefresh
import SwiftMessages

private let kBaseURL: String = "http://52.14.151.59/"
private let kNotifications: String = "notifications/"

class NotificationsTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var myUserId: String!
    private var notifications: [notificationModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(NotificationsTableViewCell.self, forCellReuseIdentifier: "notificationCell")
        tableView.rowHeight = 80
        self.getNotifications()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        self.tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.getNotifications()
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        self.tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        self.tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
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
    
    // Mark: Private Methods
    
    func getNotifications() -> Void {
        let requests: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kNotifications).absoluteString
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
        let dataTask: URLSessionDataTask? = session.dataTask(with: networkrequest, completionHandler: {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            //5
            if error == nil {
                os_log("Success")
                let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! Array<Any>
                if (!(response != nil)) {
                    self.warning()
                } else {
                    self.notifications = []
                    self.tableView.reloadData()
                    self.parseAndAddNotification(notificationlist: response!)
                    self.tableView.reloadData()
                }
            }
        })
        dataTask?.resume()
    }
    
    func parseAndAddNotification(notificationlist: Array<Any>) -> Void {
        for item in notificationlist {
            if let notification = notificationModel(dict: item as! NSDictionary) {
                //2
                notifications.append(notification)
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

}
