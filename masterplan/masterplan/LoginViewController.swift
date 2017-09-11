
//
//  LogInViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/26/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import os.log
import MapKit
import CoreLocation

private let kBaseURL: String = "http://localhost:3000/"
private let kUsers: String = "users/"

class LogInViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: Properties
    
    let locationManager = CLLocationManager()
    
    var myPhotoUrl: String!
    var myDisplayName: String! //(UserProfile.current?.firstName)! + " " + (UserProfile.current?.lastName)!
    var myUserId: String! //(UserProfile.current?.userId)!
    var myEmail: String!
    var userLocation: CLLocation!
    var user: Profile!
    
    var firstName: String!
    var lastName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        UserProfile.updatesOnAccessTokenChange = true
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends ])
        
        loginButton.center = view.center
        view.addSubview(loginButton)
        
        let imageView = UIImageView(image: UIImage(named: "pimage"))
        imageView.center = view.center
        imageView.autoresizingMask = .flexibleWidth
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
            // User is logged in, do work such as go to next view controller.
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.myUserId = accessToken.userId!
                
                self.checkUserExist(id: self.myUserId)
                
                // self.FBGraphRequest(graphPath: "\(accessToken.userId!)")
                /*
                UserProfile.fetch(userId: accessToken.userId!, completion: {(_ fetchResult: UserProfile.FetchResult) -> Void in
                    self.performSegue(withIdentifier: "loggedIn", sender: nil)
                })
                 
                 let when = DispatchTime.now() + 5 // change 2 to desired number of seconds
                 DispatchQueue.main.asyncAfter(deadline: when) {
                 // Your code with delay
                 print(UserProfile.current?.firstName)
                 self.performSegue(withIdentifier: "loggedIn", sender: nil)
                 }
                 */
            }
        } else {
            imageView.removeFromSuperview()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {

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
    
    
    
    // MARK: Private Methods
    
    func checkUserExist(id: String) {
        let requests: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kUsers).absoluteString
        //let lon: String = String(format:"%f", loc.coordinate.longitude)
        //let lat: String = String(format:"%f", loc.coordinate.latitude)
        let parameterString: String = id
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
                if (response == nil || (response?.isEmpty)!) {
                    self.FBGraphRequest(graphPath: "\(id)", exist: false)
                } else {
                    // print(response!)
                    let responseDict = response?[0] as! NSDictionary
                    self.user = Profile(dict: responseDict)
                    
                    guard let geoloc = responseDict["userLocation"] as? NSDictionary else {
                        os_log("Unable to decode the location for a user.", log: OSLog.default, type: .debug)
                        return
                    }
                    guard let coordinates = geoloc["coordinates"] as? Array<Double> else {
                        os_log("Unable to decode the coordinates for a user.", log: OSLog.default, type: .debug)
                        return
                    }
                    let location = CLLocation(latitude: coordinates[1], longitude: coordinates[0])
                    self.userLocation = location
                    
                    self.FBGraphRequest(graphPath: "\(id)", exist: true)
                }
            }
        })
        dataTask?.resume()
    }
    
    // func completion(fetchResult: UserProfile.FetchResult) {}
    
    //getting image data
    
    func FBGraphRequest(graphPath: String, exist: Bool) {
        let graphRequest = GraphRequest(graphPath: graphPath, parameters: ["fields": "name, first_name, last_name, email, picture.type(large)"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: .defaultVersion)
        let connection = GraphRequestConnection()
        connection.add(graphRequest, batchEntryName: "ProfilePicture", completion: { httpResponse, result in
            switch result {
            case .success(let response):
                // print("Graph Request Succeeded: \(response)")
                let photoData: [String : Any] = response.dictionaryValue?["picture"] as! [String : Any]
                let photoMetaData: [String : Any] = photoData["data"] as! [String : Any]
                let photoUrlString: String = photoMetaData["url"] as! String
                self.myPhotoUrl = photoUrlString
                
                if exist == true {
                    self.myDisplayName = self.user.userName
                    self.firstName = self.user.firstName
                    self.lastName = self.user.lastName
                    self.myEmail = self.user.userEmail
                    
                    let navVc: TabBarController = TabBarController()
                    navVc.myDisplayName = self.myDisplayName
                    navVc.myUserId = self.myUserId
                    navVc.myPhotoUrl = self.myPhotoUrl
                    navVc.firstName = self.firstName
                    navVc.lastName = self.lastName
                    let channelVc = navVc.viewControllers?[0] as! UINavigationController
                    let homeVc = channelVc.viewControllers.first as! HomePageViewController
                    homeVc.myDisplayName = self.myDisplayName
                    homeVc.myUserId = self.myUserId
                    homeVc.userLocation = self.userLocation
                    homeVc.myPhotoUrl = self.myPhotoUrl
                    let proffrsNavVc = navVc.viewControllers?[1] as! UINavigationController
                    let proffrsVc = proffrsNavVc.viewControllers.first as! MyProffrsViewController
                    proffrsVc.myUserId = self.myUserId
                    proffrsVc.userLocation = self.userLocation
                    proffrsVc.myPhotoUrl = self.myPhotoUrl
                    let newVc = navVc.viewControllers?[2] as! NewRequestPlaceholderVC
                    newVc.myDisplayName = self.myDisplayName
                    newVc.myUserId = self.myUserId
                    newVc.myPhotoUrl = self.myPhotoUrl
                    newVc.userLocation = self.userLocation
                    let notificationsVc = navVc.viewControllers?[3] as! UINavigationController
                    let notificationsTable = notificationsVc.viewControllers.first as! NotificationsTableViewController
                    notificationsTable.myUserId = self.myUserId
                    let profileVcNav = navVc.viewControllers?[4] as! UINavigationController
                    let profileVc = profileVcNav.viewControllers.first as! ProfileViewController
                    profileVc.myUserId = self.myUserId
                    profileVc.myPhotoUrl = self.myPhotoUrl
                    profileVc.firstName = self.firstName
                    profileVc.lastName = self.lastName
                    profileVc.userLocation = self.userLocation
                    profileVc.userProfile = self.user
                    
                    UIApplication.shared.keyWindow?.rootViewController = navVc
                    self.dismiss(animated: true, completion: nil)
                } else {
                    
                    self.myDisplayName = response.dictionaryValue?["name"] as! String
                    self.firstName = response.dictionaryValue?["first_name"] as! String
                    self.lastName = response.dictionaryValue?["last_name"] as! String
                    self.myEmail = response.dictionaryValue?["email"] as! String
                    
                    let token = Messaging.messaging().fcmToken
                    print("FCM token: \(token ?? "")")
                    
                    let newUser: Profile = Profile(userId: graphPath, userName: self.myDisplayName, firstName: self.firstName, lastName: self.lastName, userEmail: self.myEmail, userLocation: self.userLocation, fcmToken: token!)
                    
                    self.postUser(newUser)
                    
                    let profileVC: EditProfileViewController = EditProfileViewController()
                    profileVC.userId = graphPath
                    profileVC.userName = self.myDisplayName
                    profileVC.userEmail = self.myEmail
                    profileVC.userLocation = self.userLocation
                    profileVC.myPhotoUrl = self.myPhotoUrl
                    profileVC.firstName = self.firstName
                    profileVC.lastName = self.lastName
                    
                    UIApplication.shared.keyWindow?.rootViewController = profileVC
                    self.dismiss(animated: true, completion: nil)
                }
            case .failed(let error):
                print("Graph Request Failed: \(error)")
                return
            }
        })
        connection.start()
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func postUser(_ user: Profile) {
        if user == nil || user.userId == nil {
            return
            //input safety check
        }
        let users: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kUsers).absoluteString
        let url = URL(string: users)
        //1
        var networkrequest = URLRequest(url: url!)
        networkrequest.httpMethod = "POST"
        //2
        let data: Data? = try? JSONSerialization.data(withJSONObject: user.toDictionary(), options: [])
        //3
        networkrequest.httpBody = data
        networkrequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
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

}
