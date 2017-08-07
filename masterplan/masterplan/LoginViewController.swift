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
                UserProfile.fetch(userId: accessToken.userId!, completion: self.completion)
                self.performSegue(withIdentifier: "loggedIn", sender: nil)
            }
        }
        loginButton.center = view.center
        view.addSubview(loginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private Methods
    
    func completion(fetchResult: UserProfile.FetchResult) {}
    
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
        let navVc = segue.destination as! UITabBarController
        let channelVc = navVc.viewControllers?[0] as! UINavigationController
        let homeVc = channelVc.viewControllers.first as! HomePageViewController
        homeVc.myDisplayName = myDisplayName
        homeVc.myUserId = myUserId
        let newVc = navVc.viewControllers?[2] as! NewRequestPlaceholderVC
        newVc.myDisplayName = myDisplayName
        newVc.myUserId = myUserId
        let notificationsVc = navVc.viewControllers?[3] as! UINavigationController
        let notificationTable = notificationsVc.viewControllers.first as! NotificationsTableViewController
        notificationsTable.myUserId = myUserId
    }
    

}
