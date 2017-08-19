//
//  newRequestPlaceholder.swift
//  masterplan
//
//  Created by Lauren Kim on 7/15/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import CircleMenu

class NewRequestPlaceholderVC: UIViewController, CircleMenuDelegate {
    
    var myDisplayName: String!
    var myUserId: String!
    var myPhotoUrl: String!
    var button: CircleMenu!
    
    let items: [(icon: String, color: UIColor)] = [
        ("icons8-Edit Filled-50", UIColor(red:0.19, green:0.57, blue:1, alpha:1)),
        ("icons8-Update Tag Filled-50", UIColor(red:0.22, green:0.74, blue:0, alpha:1)),
        //("notifications-btn", UIColor(red:0.96, green:0.23, blue:0.21, alpha:1)),
        //("settings-btn", UIColor(red:0.51, green:0.15, blue:1, alpha:1)),
        ("nearby-btn", UIColor(red:1, green:0.39, blue:0, alpha:1)),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.setNavigationBar()
        self.setCircleMenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    func setCircleMenu() {
        button = CircleMenu(
            frame: CGRect(x: 200, y: 200, width: 50, height: 50),
            normalIcon:"icons8-Add-50",
            selectedIcon:"icon_close",
            buttonsCount: 3,
            duration: 1,
            distance: 120)
        
        button.delegate = self
        button.center = self.view.center
        button.layer.cornerRadius = button.frame.size.width / 2.0
        self.view.addSubview(button)
    }
    
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 70))
        let navItem = UINavigationItem(title: "Proffr")
        navBar.setItems([navItem], animated: false)
        self.view.addSubview(navBar)
    }
    
    @IBAction func unwindToNewRequestPlaceholder(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? TagListViewController, let request = sourceViewController.request {
            
            // Add the new request
            
            // Trigger unwind to homepage
        }
    }
    
    // MARK: <CircleMenuDelegate>
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = items[atIndex].color
        
        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
        
        // set highlited image
        let highlightedImage  = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        print("button will selected: \(atIndex)")
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        print("button did selected: \(atIndex)")
        
        let navVc: UINavigationController! = UINavigationController()
        if atIndex == 0 {
            let newRequestVc = NewRequestViewController()
            newRequestVc.myUserId = myUserId
            newRequestVc.myDisplayName = myDisplayName
            newRequestVc.myPhotoUrl = myPhotoUrl
            navVc.viewControllers.append(newRequestVc)
            //navVc.viewControllers = [newRequestVc]
        } else if atIndex == 1 {
            let newRequestVc = NewRequestViewController()
            newRequestVc.myUserId = myUserId
            newRequestVc.myDisplayName = myDisplayName
            newRequestVc.myPhotoUrl = myPhotoUrl
            navVc.viewControllers = [newRequestVc]
        } else if atIndex == 2 {
            let newRequestVc = NewRequestViewController()
            newRequestVc.myUserId = myUserId
            newRequestVc.myDisplayName = myDisplayName
            newRequestVc.myPhotoUrl = myPhotoUrl
            navVc.viewControllers = [newRequestVc]
        }
        
        self.present(navVc, animated: true, completion: nil)
    }
    
    /*

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVc = segue.destination as! UINavigationController
        let newRequestVc = navVc.viewControllers.first as! NewRequestViewController
        newRequestVc.myUserId = myUserId
        newRequestVc.myDisplayName = myDisplayName
    }
 */

}
