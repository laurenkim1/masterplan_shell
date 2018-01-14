//
//  newRequestPlaceholder.swift
//  masterplan
//
//  Created by Lauren Kim on 7/15/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import CoreLocation
import ChameleonFramework

class NewRequestPlaceholderVC: UIViewController {
    
    var myDisplayName: String!
    var myUserId: String!
    var myPhotoUrl: String!
    var userLocation: CLLocation!
    var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initChameleonColors()
        self.setNavigationBar()
        self.setButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    func setButton() {
        button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 250, height: 75)
        button.center = view.center;
        button.setTitle("New Request", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.flatYellow, for: .normal)
        button.titleLabel?.font = UIFont(name: "Ubuntu-Bold", size: 30)
        button.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    func setNavigationBar() {
        self.navigationItem.title = "Proffr"
    }
    
    func initChameleonColors() {
        self.view.backgroundColor = UIColor.init(gradientStyle: .topToBottom, withFrame: self.view.frame, andColors: [.flatYellow, .flatOrange])
    }
    
    @objc func buttonClicked() {
        let navVc: UINavigationController! = UINavigationController()
        let newRequestVc = NewRequestViewController()
        newRequestVc.myUserId = myUserId
        newRequestVc.myDisplayName = myDisplayName
        newRequestVc.myPhotoUrl = myPhotoUrl
        newRequestVc.userLocation = userLocation
        navVc.viewControllers = [newRequestVc]
        self.present(navVc, animated: true, completion: nil)
    }

}
