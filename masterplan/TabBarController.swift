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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let button = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: self.view.frame.minY), size: CGSize(width: self.view.frame.width/5, height: self.view.frame.height/9)));
        button.setTitle("Button", for: UIControlState.normal)
        self.view.addSubview(button)
         */
        var nav1 = UINavigationController()
        var HomeVC = HomePageViewController()
        HomeVC.myDisplayName = myDisplayName
        HomeVC.myUserId = myUserId
        nav1.viewControllers = [HomeVC]
        nav1.tabBarItem.title = "Home"
        
        var nav2 = UINavigationController()
        var ProffrsVC = MyProffrsViewController()
        nav2.viewControllers = [ProffrsVC]
        nav2.tabBarItem.title = "Proffrs"
        
        var nav3 = NewRequestPlaceholderVC()
        nav3.myDisplayName = myDisplayName
        nav3.myUserId = myUserId
        nav3.tabBarItem.title = "New"
        
        var nav4 = UINavigationController()
        var NotificationsVC = NotificationsTableViewController()
        NotificationsVC.myUserId = myUserId
        nav4.viewControllers = [NotificationsVC]
        nav4.tabBarItem.title = "Notifications"
        
        let tabs = [nav1, nav2, nav3, nav4] as [UIViewController]
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
