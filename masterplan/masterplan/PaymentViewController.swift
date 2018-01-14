//
//  PaymentViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 9/10/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftMessages
import os.log

private let kBaseURL: String = "http://18.221.170.199/"
private let kRequests: String = "requests/"
private let kNotifications: String = "notifications/"
private let kUsers: String = "users/"

class PaymentViewController: UIViewController {
    
    var myUserId: String!
    var request: requestInfo!
    var requestId: String!
    var myPhotoUrl: String!
    var otherPhotoUrl: String!
    var requestTitle: String!
    var myProfilePhoto: UIImageView!
    var otherProfilePhoto: UIImageView!
    var submitButton: UIButton!
    var userLocation: CLLocation!
    var proffrerName: String!
    var proffrerId: String!
    
    var ratingControl: RatingControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.setView()
        self.setNavBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setNavBar() {
        
        let screenSize: CGRect = UIScreen.main.bounds
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: self.navigationController!.navigationBar.frame.maxY, width: screenSize.width, height: 30))
        let buttonString: String = "For: \"" + self.requestTitle + "\""
        let button = UIBarButtonItem(title: buttonString, style: .plain, target: self, action: #selector(titleTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let color : UIColor = UIColor.black
        let titleFont : UIFont = UIFont(name: "Ubuntu-Bold", size: 20)!
        let attributes = [
            NSForegroundColorAttributeName : color,
            NSFontAttributeName : titleFont
        ]
        
        button.setTitleTextAttributes(attributes, for: UIControlState.normal)
        toolbar.barTintColor = UIColor.white
        
        toolbar.items = [flexibleSpace, button, flexibleSpace]
        let toolBarSeparator = UIView(frame: CGRect(x: 0, y: toolbar.frame.size.height-0.75, width: toolbar.frame.size.width, height: 0.75))
        toolBarSeparator.backgroundColor = UIColor.gray // Here your custom color
        toolBarSeparator.isOpaque = true
        toolbar.addSubview(toolBarSeparator)
        self.view.addSubview(toolbar)
        self.navigationItem.hidesBackButton = true
    }
    
    @objc func doneButtonTapped(){
        // guard let controllers = navigationController?.viewControllers else { return }
        // guard let homeViewController = controllers[0] as? HomePageViewController else { return }
        self.updateUser()
        navigationController?.popToRootViewController(animated: true)
    }
    
    func setView() {
        
        let arrow = UIImageView()
        arrow.image = UIImage(named: "right-arrow")
        arrow.frame = CGRect(x: 2*self.view.frame.width/5+10, y: 170, width: self.view.frame.width/5-20, height: self.view.frame.width/5-20)
        view.addSubview(arrow)
        
        myProfilePhoto = UIImageView()
        myProfilePhoto.frame = CGRect(x: self.view.frame.width/5-20, y: 160, width: self.view.frame.width/5+10, height: self.view.frame.width/5+10)
        myProfilePhoto.layer.borderWidth = 1
        myProfilePhoto.layer.masksToBounds = false
        myProfilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        myProfilePhoto.layer.cornerRadius = myProfilePhoto.frame.height/2
        myProfilePhoto.clipsToBounds = true
        view.addSubview(myProfilePhoto)
        
        otherProfilePhoto = UIImageView()
        otherProfilePhoto.frame = CGRect(x: 3*self.view.frame.width/5+10, y: 160, width: self.view.frame.width/5+10, height: self.view.frame.width/5+10)
        otherProfilePhoto.layer.borderWidth = 1
        otherProfilePhoto.layer.masksToBounds = false
        otherProfilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        otherProfilePhoto.layer.cornerRadius = myProfilePhoto.frame.height/2
        otherProfilePhoto.clipsToBounds = true
        view.addSubview(otherProfilePhoto)
        
        self.setProfilePhoto(PhotoUrl: self.myPhotoUrl, photo: myProfilePhoto)
        self.setProfilePhoto(PhotoUrl: self.otherPhotoUrl, photo: otherProfilePhoto)
        
        self.submitButton = UIButton(frame: CGRect(x: self.view.frame.width/5, y: 140+myProfilePhoto.frame.height+270, width: 3*self.view.frame.width/5, height: 50))
        
        submitButton.addTarget(self, action: #selector(self.doneButtonTapped), for: .touchUpInside)
        submitButton.layer.backgroundColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
        submitButton.layer.cornerRadius = 5
        submitButton.setTitle("Submit", for: .normal)
        
        let separator = UIView(frame: CGRect(x: 0, y: 140+myProfilePhoto.frame.height+90, width: self.view.frame.size.width, height: 0.75))
        separator.backgroundColor = UIColor.gray // Here your custom color
        separator.isOpaque = true
        view.addSubview(separator)
        
        let separator1 = UIView(frame: CGRect(x: 0, y: 140+myProfilePhoto.frame.height+140, width: self.view.frame.size.width, height: 0.75))
        separator1.backgroundColor = UIColor.gray // Here your custom color
        separator1.isOpaque = true
        view.addSubview(separator1)
        
        let centerpoint: CGPoint = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
        
        let leaveReviewlabel = UILabel(frame: CGRect(x: centerpoint.x-90, y: 140+myProfilePhoto.frame.height+90, width: 180, height: 50))
        leaveReviewlabel.text = "Leave a review for"
        leaveReviewlabel.font = UIFont(name: "Arial", size: 20)
        leaveReviewlabel.textAlignment = .center
        self.view.addSubview(leaveReviewlabel)
        
        let meetlabel = UILabel(frame: CGRect(x: centerpoint.x-90, y: 105, width: 180, height: 50))
        meetlabel.text = "Meet in person!"
        meetlabel.font = UIFont(name: "Arial", size: 25)
        meetlabel.textAlignment = .center
        self.view.addSubview(meetlabel)
        
        let itemlabel = UILabel(frame: CGRect(x: 3*self.view.frame.width/5+10, y: 170+myProfilePhoto.frame.height, width: self.view.frame.width/5+10, height: 20))
        itemlabel.text = self.requestTitle
        itemlabel.font = UIFont(name: "Arial", size: 16)
        itemlabel.textAlignment = .center
        self.view.addSubview(itemlabel)
        
        let itemprice = UILabel(frame: CGRect(x: self.view.frame.width/5-20, y: 170+myProfilePhoto.frame.height, width: self.view.frame.width/5+10, height: 20))
        itemprice.text = "$" + String(format:"%.2f", request.requestPrice)
        itemprice.font = UIFont(name: "Arial", size: 20)
        itemprice.textAlignment = .center
        self.view.addSubview(itemprice)
        
        let namelabel = UILabel(frame: CGRect(x: centerpoint.x-100, y: 140+myProfilePhoto.frame.height+150, width: 200, height: 50))
        namelabel.text = self.proffrerName
        namelabel.font = UIFont(name: "Arial", size: 30)
        namelabel.textAlignment = .center
        self.view.addSubview(namelabel)
        
        ratingControl = RatingControl(frame: CGRect(x: centerpoint.x-75, y: 140+myProfilePhoto.frame.height+210, width: 150, height: 30))
        self.view.addSubview(ratingControl)
        
        self.view.addSubview(self.submitButton)
    }
    
    @objc func titleTapped() {
        self.getRequest()
    }
    
    func getRequest() -> Void {
        let requests: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kRequests).absoluteString
        let url = URL(string: (requests + "/search/" + self.requestId!))
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
                let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                DispatchQueue.main.async() {
                    if response != nil {
                        self.parseRequest(request: response!)
                    } else {
                        self.warning()
                    }
                }
            }
        })
        dataTask?.resume()
    }
    
    func parseRequest(request: NSDictionary) -> Void {
        let request = requestInfo(dict: request)
        let detailVc: RequestDetailsViewController = RequestDetailsViewController()
        detailVc.userLocation = userLocation
        detailVc.request = request
        detailVc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(detailVc,
                                                 animated: true)
    }
    
    func warning() -> Void {
        let error = MessageView.viewFromNib(layout: .TabView)
        error.configureTheme(.warning)
        error.backgroundView.backgroundColor = UIColor.purple
        error.configureContent(title: "Sorry", body: "This request has already expired!")
        error.configureDropShadow()
        error.button?.isHidden = true
        let errorConfig = SwiftMessages.defaultConfig
        SwiftMessages.show(config: errorConfig, view: error)
    }
    
    func setProfilePhoto(PhotoUrl: String, photo: UIImageView) {
        let photoUrl = URL(string: PhotoUrl)
        URLSession.shared.dataTask(with: photoUrl!) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                let image = UIImage(data: data)
                photo.image = image
            }
            }.resume()
    }
    
    func rateToDict() -> NSDictionary! {
        let jsonable = NSMutableDictionary()
        let newRating: Int! = self.ratingControl.rating
        jsonable.setValue(newRating, forKey: "rating")
        return jsonable
    }
    
    func updateUser() {
        if self.proffrerId == nil {
            return
            //input safety check
        }
        let users: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kUsers).absoluteString
        let url = URL(string: users + "/rating/" + self.proffrerId)
        //1
        var networkrequest = URLRequest(url: url!)
        networkrequest.httpMethod = "PUT"
        //2
        
        let data: Data? = try? JSONSerialization.data(withJSONObject: self.rateToDict(), options: [])
        //3
        networkrequest.httpBody = data
        networkrequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask: URLSessionDataTask? = session.dataTask(with: networkrequest, completionHandler: {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            //5
            if error == nil {
                os_log("Success")
            }
        })
        dataTask?.resume()
    }
    
}
