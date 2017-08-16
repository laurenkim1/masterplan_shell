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

private let kBaseURL: String = "http://localhost:3000/"
private let kRequests: String = "requests/"

class HomePageViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, CLLocationManagerDelegate {
    
    // MARK: Properties
    
    var myDisplayName: String!
    var myUserId: String!
    var nearbyRequestList = [requestInfo]()
    var filteredNearbyRequestList = [requestInfo]()
    var searchController = UISearchController(searchResultsController: nil)
    var distanceCeiling: CLLocationDistance = 1610.0 as CLLocationDistance
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocation(latitude: 42.3770, longitude: -71.1167)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Proffr"
        
        self.tableView.delegate = self
        self.tableView.register(NearbyRequestTableViewCell.self, forCellReuseIdentifier: "NearbyRequestTableViewCell")
        self.tableView.allowsSelection = true
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.isUserInteractionEnabled = true
        
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
        
        self.tableView.reloadData()
        //self.refreshControl?.addTarget(self, action: #selector(HomePageViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        self.tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.nearbyRequestList = []
            self?.getNearbyRequests((self?.userLocation)!, 1)
            self?.tableView.reloadData()
            self?.tableView.dg_stopLoading()
            self?.tableView.reloadData()
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
            
            /*
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .none
            numberFormatter.formatterBehavior = .default
            
            let targetNumber = numberFormatter.number(from: searchString)
            
            // `searchString` may fail to convert to a number.
            if targetNumber != nil {
                // Use `targetNumberExpression` in both the following predicates.
                let targetNumberExpression = NSExpression(forConstantValue: targetNumber!)
                
                // `yearIntroduced` field matching.
                let yearIntroducedExpression = NSExpression(forKeyPath: "yearIntroduced")
                let yearIntroducedPredicate = NSComparisonPredicate(leftExpression: yearIntroducedExpression, rightExpression: targetNumberExpression, modifier: .direct, type: .equalTo, options: .caseInsensitive)
                
                searchItemsPredicate.append(yearIntroducedPredicate)
                
                // `price` field matching.
                let lhs = NSExpression(forKeyPath: "introPrice")
                
                let finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: targetNumberExpression, modifier: .direct, type: .equalTo, options: .caseInsensitive)
                
                searchItemsPredicate.append(finalPredicate)
            }
 

            
            let requestLocation: CLLocation = value(forKeyPath: "location") as! CLLocation
            let distanceBetween: CLLocationDistance = userLocation.distance(from: requestLocation)
            let NSDistanceBetween = NSExpression(forConstantValue: distanceBetween)
            let NSDistanceCeiling = NSExpression(forConstantValue: distanceCeiling)
            let distancePredicate = NSComparisonPredicate(leftExpression: NSDistanceBetween, rightExpression: NSDistanceCeiling, modifier: .direct, type: .lessThanOrEqualTo, options: .caseInsensitive)
            searchItemsPredicate.append(distancePredicate)
 */
            
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
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
        
        // change these parameters to match a request table cell
        cell.requestTitle.text = nearbyRequest.requestTitle
        cell.nameLabel.text = nearbyRequest.userName
        
        userLocation = CLLocation(latitude: 42.3770, longitude: -71.1167)
        
        let _meterDistance: CLLocationDistance = userLocation.distance(from: nearbyRequest.location)
        let _distance: Double = _meterDistance/1609.34
        let _distanceString: String = String(format:"%.2f", _distance)
        cell.distanceLabel.text = _distanceString
        
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        os_log("hi - selected row")
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
                nearbyRequestList += [request]
            }
        }
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
        print(selectedRequest)
        let nextViewController: NewProffrViewController = NewProffrViewController()
        
        nextViewController.request = selectedRequest
        nextViewController.senderDisplayName = myDisplayName
        nextViewController.senderId = myUserId
        navigationController?.pushViewController(nextViewController,
                                                 animated: false)
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
