//
//  TabBarController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/13/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var myDisplayName: String!
    var myUserId: String!
    var myPhotoUrl: String!
    
    var firstName: String!
    var lastName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        let button = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: self.view.frame.minY), size: CGSize(width: self.view.frame.width/5, height: self.view.frame.height/9)));
        button.setTitle("Button", for: UIControlState.normal)
        self.view.addSubview(button)
         */
        let nav1 = UINavigationController()
        let HomeVC = HomePageViewController()
        HomeVC.myDisplayName = myDisplayName
        HomeVC.myUserId = myUserId
        HomeVC.myPhotoUrl = myPhotoUrl
        nav1.viewControllers = [HomeVC]
        nav1.tabBarItem.title = "Home"
        nav1.tabBarItem.image = UIImage(named: "icon_home")
        
        let nav2 = UINavigationController()
        let ProffrsVC = MyProffrsViewController()
        ProffrsVC.myUserId = myUserId
        nav2.viewControllers = [ProffrsVC]
        nav2.tabBarItem.title = "Proffrs"
        nav2.tabBarItem.image = UIImage(named: "icons8-Price Tag Filled-50")
        
        let nav3 = NewRequestPlaceholderVC()
        nav3.myDisplayName = myDisplayName
        nav3.myUserId = myUserId
        nav3.myPhotoUrl = myPhotoUrl
        nav3.tabBarItem.title = "New"
        nav3.tabBarItem.image = UIImage(named: "icons8-Plus 2 Math-50")
        
        let nav4 = UINavigationController()
        let NotificationsVC = NotificationsTableViewController()
        NotificationsVC.myUserId = myUserId
        nav4.viewControllers = [NotificationsVC]
        nav4.tabBarItem.title = "Notifications"
        nav4.tabBarItem.image = UIImage(named: "notifications-btn")
        
        let nav5 = UINavigationController()
        let ProfileVC = ProfileViewController()
        ProfileVC.myUserId = myUserId
        ProfileVC.myPhotoUrl = myPhotoUrl
        nav5.viewControllers = [ProfileVC]
        nav5.tabBarItem.title = "Profile"
        nav5.tabBarItem.image = UIImage(named: "icons8-Badge-50")
        
        let tabs = [nav1, nav2, nav3, nav4, nav5] as [UIViewController]
        self.viewControllers = tabs
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
