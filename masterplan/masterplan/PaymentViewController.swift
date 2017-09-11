//
//  PaymentViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 9/10/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import Braintree
import CoreLocation
import SwiftMessages
import os.log

private let kBaseURL: String = "http://localhost:3000/"
private let kRequests: String = "requests/"
private let kNotifications: String = "notifications/"
private let kUsers: String = "users/"

class PaymentViewController: UIViewController, BTDropInViewControllerDelegate {
    
    var braintree: Braintree?
    
    var myUserId: String!
    var request: requestInfo!
    var requestId: String!
    var myPhotoUrl: String!
    var requestTitle: String!
    var myProfilePhoto: UIImageView!
    var otherProfilePhoto: UIImageView!
    var payButton: UIButton!
    var userLocation: CLLocation!

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
    
    
    func tappedMyPayButton() {
        // If you haven't already, create and retain a `Braintree` instance with the client token.
        // Typically, you only need to do this once per session.
        let clientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiJkZTFiMzc1NmY0NjFiODlkNDJkZTY0NDc1NWNlMWIxMTE1ZjE0NGNlNGE5YjcxOTRhM2I3Yzk5MDU2MzIxYmMxfGNyZWF0ZWRfYXQ9MjAxNy0wOS0xMFQyMTowMzo1OS40NTEyMjkxMjMrMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNiZ3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBrOWNnZjNiZ3l3MmIvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tLzM0OHBrOWNnZjNiZ3l3MmIifSwidGhyZWVEU2VjdXJlRW5hYmxlZCI6dHJ1ZSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJtZXJjaGFudEFjY291bnRJZCI6ImFjbWV3aWRnZXRzbHRkc2FuZGJveCIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJtZXJjaGFudElkIjoiMzQ4cGs5Y2dmM2JneXcyYiIsInZlbm1vIjoib2ZmIn0="
        
        braintree = Braintree(clientToken: clientToken)
        
        // Create a BTDropInViewController
        let dropInViewController = braintree!.dropInViewController(with: self)
        
        // This is where you might want to customize your Drop-in. (See below.)
        
        // The way you present your BTDropInViewController instance is up to you.
        // In this example, we wrap it in a new, modally presented navigation controller:
        dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(self.userDidCancelPayment))
        
        let navigationController = UINavigationController(rootViewController: dropInViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func userDidCancelPayment() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func drop(_ viewController: BTDropInViewController!, didSucceedWith paymentMethod: BTPaymentMethod!) {
        postNonceToServer(paymentMethodNonce: paymentMethod.nonce) // Send payment method nonce to your server
        dismiss(animated: true, completion: nil)
    }
    
    func drop(inViewControllerDidCancel viewController: BTDropInViewController!) {
        dismiss(animated: true, completion: nil)
    }
    
    func postNonceToServer(paymentMethodNonce: String) {
        // Update URL with your server
        let paymentURL = URL(string: "https://your-server.example.com/payment-methods")!
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            }.resume()
    }
    
    private func setNavBar() {
        
        let screenSize: CGRect = UIScreen.main.bounds
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 65, width: screenSize.width, height: 30))
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
        self.setProfilePhoto(PhotoUrl: request.photoUrl.absoluteString, photo: otherProfilePhoto)
        
        self.payButton = UIButton(frame: CGRect(x: self.view.frame.width/5, y: 140+myProfilePhoto.frame.height+300, width: 3*self.view.frame.width/5, height: 50))
        payButton.addTarget(self, action: #selector(self.tappedMyPayButton), for: .touchUpInside)
        payButton.layer.backgroundColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
        payButton.layer.cornerRadius = 5
        payButton.setTitle("Pay", for: .normal)
        
        let separator = UIView(frame: CGRect(x: 0, y: 140+myProfilePhoto.frame.height+80, width: self.view.frame.size.width, height: 0.75))
        separator.backgroundColor = UIColor.gray // Here your custom color
        separator.isOpaque = true
        view.addSubview(separator)
        
        let separator1 = UIView(frame: CGRect(x: 0, y: 140+myProfilePhoto.frame.height+130, width: self.view.frame.size.width, height: 0.75))
        separator1.backgroundColor = UIColor.gray // Here your custom color
        separator1.isOpaque = true
        view.addSubview(separator1)
        
        let centerpoint: CGPoint = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
        
        let paymentlabel = UILabel(frame: CGRect(x: centerpoint.x-60, y: 140+myProfilePhoto.frame.height+80, width: 120, height: 50))
        paymentlabel.text = "Payment"
        paymentlabel.font = UIFont(name: "Arial", size: 30)
        self.view.addSubview(paymentlabel)
        
        let itemlabel = UILabel(frame: CGRect(x: centerpoint.x-120, y: separator1.center.y+20, width: 180, height: 20))
        itemlabel.text = "Item"
        itemlabel.font = UIFont(name: "Arial", size: 16)
        self.view.addSubview(itemlabel)
        
        let itemprice = UILabel(frame: CGRect(x: centerpoint.x+60, y: separator1.center.y+20, width: 60, height: 20))
        itemprice.text = "$" + String(format:"%.2f", request.requestPrice)
        itemprice.font = UIFont(name: "Arial", size: 16)
        self.view.addSubview(itemprice)
        
        let servicelabel = UILabel(frame: CGRect(x: centerpoint.x-120, y: itemlabel.center.y+30, width: 180, height: 20))
        servicelabel.text = "Transaction Fee"
        servicelabel.font = UIFont(name: "Arial", size: 16)
        self.view.addSubview(servicelabel)
        
        let serviceprice = UILabel(frame: CGRect(x: centerpoint.x+60, y: itemlabel.center.y+30, width: 60, height: 20))
        serviceprice.text = "$" + String(format:"%.2f", 0.60)
        serviceprice.font = UIFont(name: "Arial", size: 16)
        self.view.addSubview(serviceprice)
        
        let separator2 = UIView(frame: CGRect(x: centerpoint.x-130, y: serviceprice.center.y+20, width: 260, height: 1.25))
        separator2.backgroundColor = UIColor.gray // Here your custom color
        separator2.isOpaque = true
        view.addSubview(separator2)
        
        let totallabel = UILabel(frame: CGRect(x: centerpoint.x-120, y: separator2.center.y+15, width: 180, height: 20))
        totallabel.text = "Total"
        totallabel.font = UIFont(name: "Arial", size: 16)
        self.view.addSubview(totallabel)
        
        let totalprice = UILabel(frame: CGRect(x: centerpoint.x+60, y: separator2.center.y+15, width: 60, height: 20))
        totalprice.text = "$" + String(format:"%.2f", request.requestPrice+0.60)
        totalprice.font = UIFont(name: "Arial", size: 16)
        self.view.addSubview(totalprice)
        
        self.view.addSubview(payButton)
    }
    
    func titleTapped() {
        self.getRequest()
    }
    
    func getRequest() -> Void {
        let requests: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kRequests).absoluteString
        let url = URL(string: (requests + "search/" + self.requestId!))
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
            print("Download Started")
            print(response?.suggestedFilename ?? photoUrl?.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                let image = UIImage(data: data)
                photo.image = image
            }
            }.resume()
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
