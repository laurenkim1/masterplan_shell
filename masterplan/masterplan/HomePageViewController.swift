//
//  HomePageViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/13/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import os.log
import MapKit
import CoreLocation
import DGElasticPullToRefresh
import SwiftMessages
import SystemConfiguration

private let kBaseURL: String = "http://52.14.151.59/"
private let kRequests: String = "requests/"

class HomePageViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, CLLocationManagerDelegate {
    
    // MARK: Properties
    
    var myDisplayName: String!
    var myUserId: String!
    var myPhotoUrl: String!
    var nearbyRequestList = [requestInfo]()
    var filteredNearbyRequestList = [requestInfo]()
    var searchController = UISearchController(searchResultsController: nil)
    var distanceCeiling: CLLocationDistance = 1610.0 as CLLocationDistance
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocation! 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.myUserId)
        self.tableView.delegate = self
        self.tableView.register(NearbyRequestTableViewCell.self, forCellReuseIdentifier: "NearbyRequestTableViewCell")
        self.tableView.rowHeight = 80
        self.tableView.allowsSelection = true
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.isUserInteractionEnabled = true
        
        let internet = self.isInternetAvailable()
        if (!internet) {
            self.warning()
        }
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        self.getNearbyRequests(userLocation, 1)

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        //self.refreshControl?.addTarget(self, action: #selector(HomePageViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        self.tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.getNearbyRequests((self?.userLocation)!, 1)
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        self.tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        self.tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = true
        self.tableView.reloadData()
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK: - UICLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        manager.stopUpdatingLocation()
        
        print("user latitude = \(self.userLocation.coordinate.latitude)")
        print("user longitude = \(self.userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString = searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        
        // Build all the "AND" expressions for each value in the searchString.
        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            // Each searchString creates an OR predicate for: name, yearIntroduced, introPrice.
            //
            // Example if searchItems contains "iphone 599 2007":
            //      name CONTAINS[c] "iphone"
            //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
            //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
            //
            var searchItemsPredicate = [NSPredicate]()
            
            // Below we use NSExpression represent expressions in our predicates.
            // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value).
            
            // Name field matching.
            let titleExpression = NSExpression(forKeyPath: "requestTitle")
            let searchStringExpression = NSExpression(forConstantValue: searchString)
            
            let titleSearchComparisonPredicate = NSComparisonPredicate(leftExpression: titleExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
            
            searchItemsPredicate.append(titleSearchComparisonPredicate)
            
            // Name field matching.
            let tagsExpression = NSExpression(forKeyPath: "tagString")
            
            let tagSearchComparisonPredicate = NSComparisonPredicate(leftExpression: tagsExpression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
            
            searchItemsPredicate.append(tagSearchComparisonPredicate)
            
            
            // Add this OR predicate to our master AND predicate.
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)
            
            return orMatchPredicate
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        
        filteredNearbyRequestList = nearbyRequestList.filter { finalCompoundPredicate.evaluate(with: $0) }
        
        tableView.reloadData()
    }
    
    //MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredNearbyRequestList.count
        }
        return nearbyRequestList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "NearbyRequestTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NearbyRequestTableViewCell else {
            fatalError("The dequeued cell is not an instance of NearbyRequestTableViewCell.")
        }
        
        // Fetches the appropriate request for the data source layout.
        let nearbyRequest: requestInfo
        if searchController.isActive && searchController.searchBar.text != "" {
            nearbyRequest = filteredNearbyRequestList[indexPath.row]
        } else {
            nearbyRequest = nearbyRequestList[indexPath.row]
        }
        
        let photoUrl = nearbyRequest.photoUrl
        
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
        
        cell.inlabel.text = "in"
        
        let postTime = nearbyRequest.postTime!
        let components: NSDateComponents = NSDateComponents()
        components.setValue(24, forComponent: NSCalendar.Unit.hour)
        let endTime = NSCalendar.current.date(byAdding: components as DateComponents, to: postTime as Date)
        let nowTime = Date()
        let timeLeft: TimeInterval = (endTime?.timeIntervalSince(nowTime))!
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        let timeString = formatter.string(from: timeLeft)
        cell.timeLabel.text = timeString
        
        cell.requestTitle.text = nearbyRequest.requestTitle
        cell.nameLabel.text = nearbyRequest.userName
        cell.requestPrice.text = "$" + String(format:"%.2f", nearbyRequest.requestPrice)
        
        let _meterDistance: CLLocationDistance = userLocation.distance(from: nearbyRequest.location)
        let _distance: Double = _meterDistance/1609.34
        let _distanceString: String = "(" + String(format:"%.2f", _distance) + " mi)"
        cell.distanceLabel.text = _distanceString
        
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let selectedRequest: requestInfo
        if searchController.isActive && searchController.searchBar.text != "" {
            selectedRequest = nearbyRequestList[indexPath.row]
        } else {
            selectedRequest = nearbyRequestList[indexPath.row]
        }
        print(selectedRequest)
        cellSelected(selectedRequest: selectedRequest)
    }
    
    // Mark: Private Methods
    
    func getNearbyRequests(_ loc: CLLocation, _ rad: Float) -> Void {
        let requests: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kRequests).absoluteString
        let lon: String = String(format:"%f", loc.coordinate.longitude)
        let lat: String = String(format:"%f", loc.coordinate.latitude)
        let radius: String = String(format:"%f", rad)
        let parameterString: String = radius + "?lat=" + lat + "&lon=" + lon
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
                    self.nearbyRequestList = []
                    self.tableView.reloadData()
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
                nearbyRequestList.append(request)
            }
        }
    }
    
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }


    /*
    func handleRefresh(refreshControl: UIRefreshControl) -> Void {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        self.nearbyRequestList = []
        self.getNearbyRequests(userLocation, 1)
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    */
    
    // MARK: Actions

    @IBAction func unwindToHomePage(sender: UIStoryboardSegue) {
    }
    
    // MARK: - Navigation
    
    func cellSelected(selectedRequest: requestInfo){
        let nextViewController: RequestDetailsViewController = RequestDetailsViewController()
        nextViewController.request = selectedRequest
        nextViewController.myDisplayName = myDisplayName
        nextViewController.myUserId = myUserId
        nextViewController.myPhotoUrl = myPhotoUrl
        nextViewController.userLocation = userLocation
        navigationController?.pushViewController(nextViewController,
                                                 animated: true)
    }

    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let CreateProffrViewController = segue.destination as? CreateProffrViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectedRequestCell = sender as? NearbyRequestTableViewCell else {
            fatalError("Unexpected sender: \(sender)")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedRequestCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let selectedRequest: requestInfo
        if searchController.isActive && searchController.searchBar.text != "" {
            selectedRequest = nearbyRequestList[indexPath.row]
        } else {
            selectedRequest = nearbyRequestList[indexPath.row]
        }
        
        CreateProffrViewController.request = selectedRequest
        CreateProffrViewController.senderDisplayName = myDisplayName
        CreateProffrViewController.senderId = myUserId
    }
 */

}
