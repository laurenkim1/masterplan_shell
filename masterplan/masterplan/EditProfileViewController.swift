//
//  EditProfileViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 8/18/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import os.log
import MapKit
import CoreLocation
import Eureka
import Firebase

private let kBaseURL: String = "http://localhost:3000/"
private let kUsers: String = "users/"

class EditProfileViewController: FormViewController {
    
    var userId: String!
    var userName: String!
    var userEmail: String!
    var userLocation: CLLocation!
    var myPhotoUrl: String!
    var firstName: String!
    var lastName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Proffr"
        self.setNavigationBar()
        
        form +++ Section() {
            $0.header = HeaderFooterView<BufferView>(.class)
            }
            <<< TextRow("firstName"){ row in
                row.title = "First Name:"
                row.placeholder = ""
                row.value = self.firstName
            }
            <<< TextRow("lastName"){ row in
                row.title = "Last Name:"
                row.placeholder = ""
                row.value = self.lastName
            }
            <<< TextRow("Email"){
                $0.title = "Email:"
                $0.placeholder = ""
                $0.value = self.userEmail
            }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func finishSegue() {
        
        let firstnamerow: TextRow = form.rowBy(tag: "firstName")!
        let lastnamerow: TextRow = form.rowBy(tag: "lastName")!
        self.firstName = firstnamerow.value ?? ""
        self.lastName = lastnamerow.value ?? ""
        self.userName = (firstnamerow.value ?? "") + " " + (lastnamerow.value ?? "")
        let emailrow: TextRow = form.rowBy(tag: "Email")!
        self.userEmail = emailrow.value ?? ""
        
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        
        let updateUser: Profile = Profile(userId: self.userId, userName: self.userName, firstName: self.firstName, lastName: self.lastName, userEmail: self.userEmail, userLocation: self.userLocation, fcmToken: token!)
        
        self.updateUser(updateUser)
        
        let navVc: TabBarController = TabBarController()
        navVc.myDisplayName = self.userName
        navVc.myUserId = self.userId
        navVc.myPhotoUrl = self.myPhotoUrl
        let channelVc = navVc.viewControllers?[0] as! UINavigationController
        let homeVc = channelVc.viewControllers.first as! HomePageViewController
        homeVc.myDisplayName = self.userName
        homeVc.myUserId = self.userId
        homeVc.userLocation = self.userLocation
        homeVc.myPhotoUrl = self.myPhotoUrl
        let proffrsNavVc = navVc.viewControllers?[1] as! UINavigationController
        let proffrsVc = proffrsNavVc.viewControllers.first as! MyProffrsViewController
        proffrsVc.myUserId = self.userId
        let newVc = navVc.viewControllers?[2] as! NewRequestPlaceholderVC
        newVc.myDisplayName = self.userName
        newVc.myUserId = self.userId
        newVc.myPhotoUrl = self.myPhotoUrl
        let notificationsVc = navVc.viewControllers?[3] as! UINavigationController
        let notificationsTable = notificationsVc.viewControllers.first as! NotificationsTableViewController
        notificationsTable.myUserId = self.userId
        let profileVcNav = navVc.viewControllers?[4] as! UINavigationController
        let profileVc = profileVcNav.viewControllers.first as! ProfileViewController
        profileVc.myUserId = self.userId
        profileVc.myPhotoUrl = self.myPhotoUrl
        profileVc.firstName = self.firstName
        profileVc.lastName = self.lastName
        
        UIApplication.shared.keyWindow?.rootViewController = navVc
        self.dismiss(animated: true, completion: nil)
    }
    
    func setNavigationBar() {
        let doneButton = UIBarButtonItem(image: UIImage(named: "icons8-Ok-50"), style: .plain, target: self, action: #selector(finishSegue))
        
        if self.navigationController == nil {
            let navItem = UINavigationItem()
            navItem.rightBarButtonItem = doneButton
            let screenSize: CGRect = UIScreen.main.bounds
            let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 65))
            navBar.setItems([navItem], animated: false)
            self.view.addSubview(navBar)
        }
        
        self.navigationItem.leftBarButtonItem = doneButton
    }
    
    func updateUser(_ user: Profile) {
        if user.userId == nil {
            return
            //input safety check
        }
        let users: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kUsers).absoluteString
        let url = URL(string: users + self.userId)
        //1
        var networkrequest = URLRequest(url: url!)
        networkrequest.httpMethod = "PUT"
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
                print(response)
            }
        })
        dataTask?.resume()
    }
    
    class BufferView: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            let screenSize: CGRect = UIScreen.main.bounds
            self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 80)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
