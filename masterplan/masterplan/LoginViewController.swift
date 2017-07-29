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
    @IBOutlet weak var nameField: UITextField!

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
    
    /*
    func toggleHiddenState(_ shouldHide: Bool) {
        loginButton.isHidden = shouldHide
    }
 */
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let navVc = segue.destination as! UITabBarController
        let channelVc = navVc.viewControllers?[1] as! UINavigationController
        let myProffrsVc = channelVc.viewControllers.first as! MyProffrsViewController
        myProffrsVc.senderDisplayName = nameField?.text
    }
    

}
