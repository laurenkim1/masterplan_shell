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

private let kBaseURL: String = "http://localhost:3000/"
private let kRequests: String = "requests"

class HomePageViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, CLLocationManagerDelegate {
    
    // MARK: Properties
    
    var nearbyRequestList = [requestInfo]()
    var filteredNearbyRequestList = [requestInfo]()
    var searchController = UISearchController(searchResultsController: nil)
    var distanceCeiling: CLLocationDistance = 1610.0 as CLLocationDistance
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocation(latitude: 42.3770, longitude: -71.1167)

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        nearbyRequestList = 
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
        cell.nameLabel.text = nearbyRequest.requestTitle
        let _distance: CLLocationDistance = userLocation.distance(from: nearbyRequest.location)
        let _distanceString: String = String(format:"%.2f", _distance)
        cell.distanceLabel.text = _distanceString
        
        return cell
    }
    
    // Mark: Private Methods
    
    func getNearbyRequests(_ loc: CLLocation) -> NSArray {
        let requests: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kRequests).absoluteString
        let lon: String = String(format:"%f", loc.coordinate.longitude)
        let lat: String = String(format:"%f", loc.coordinate.latitude)
        let parameterString: String = "?lat=" + lat + "&lon=" + lon
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
                let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            }
        })
        dataTask?.resume()
    }

    
    // MARK: Actions

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
