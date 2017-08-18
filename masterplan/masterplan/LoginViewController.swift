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

class LogInViewController: UIViewController {
    
    // MARK: Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        UserProfile.updatesOnAccessTokenChange = true
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends ])
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
            // User is logged in, do work such as go to next view controller.
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.FBGraphRequest(graphPath: "\(accessToken.userId!)")
                UserProfile.fetch(userId: accessToken.userId!, completion: {(_ fetchResult: UserProfile.FetchResult) -> Void in
                    self.performSegue(withIdentifier: "loggedIn", sender: nil)
                })
                
                /*self.FBGraphRequest(graphPath: "\(accessToken.userId!)")
                 
                 let when = DispatchTime.now() + 5 // change 2 to desired number of seconds
                 DispatchQueue.main.asyncAfter(deadline: when) {
                 // Your code with delay
                 print(UserProfile.current?.firstName)
                 self.performSegue(withIdentifier: "loggedIn", sender: nil)
                 }
                 */
            }
        }
        loginButton.center = view.center
        view.addSubview(loginButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Private Methods
    
    // func completion(fetchResult: UserProfile.FetchResult) {}
    
    //getting image data
    
    func FBGraphRequest(graphPath: String) {
        let graphRequest = GraphRequest(graphPath: graphPath, parameters: ["fields": "id, picture.type(large)"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: .defaultVersion)
        let connection = GraphRequestConnection()
        connection.add(graphRequest, batchEntryName: "ProfilePicture", completion: { httpResponse, result in
            switch result {
            case .success(let response):
                print("Graph Request Succeeded: \(response.dictionaryValue?["picture"])")
                let photoData: [String : Any] = response.dictionaryValue?["picture"] as! [String : Any]
                let photoMetaData: [String : Any] = photoData["data"] as! [String : Any]
                let photoUrlString: String = photoMetaData["url"] as! String
                let photoUrl: URL = URL(string: photoUrlString)!
                self.getDataFromUrl(url: photoUrl, completion: {(data, response, error) -> Void in
                    print(error)
                    print(data)
                    print(response)
                })
            case .failed(let error):
                print("Graph Request Failed: \(error)")
            }})
        connection.start()
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            print(response)
            }.resume()
    }
    
    /*
    func toggleHiddenState(_ shouldHide: Bool) {
        loginButton.isHidden = shouldHide
    }
 */
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        let myDisplayName = (UserProfile.current?.firstName)! + " " + (UserProfile.current?.lastName)!
        let myUserId = (UserProfile.current?.userId)!
        
        
        let navVc = segue.destination as! TabBarController
        navVc.myDisplayName = myDisplayName
        navVc.myUserId = myUserId
        let channelVc = navVc.viewControllers?[0] as! UINavigationController
        let homeVc = channelVc.viewControllers.first as! HomePageViewController
        homeVc.myDisplayName = myDisplayName
        homeVc.myUserId = myUserId
        let newVc = navVc.viewControllers?[2] as! NewRequestPlaceholderVC
        newVc.myDisplayName = myDisplayName
        newVc.myUserId = myUserId
        let notificationsVc = navVc.viewControllers?[3] as! UINavigationController
        let notificationsTable = notificationsVc.viewControllers.first as! NotificationsTableViewController
        notificationsTable.myUserId = myUserId
    }
    

}
