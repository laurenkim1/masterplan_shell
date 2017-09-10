//
//  PaymentViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 9/10/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import Braintree

class PaymentViewController: UIViewController, BTDropInViewControllerDelegate {
    var braintree: Braintree?
    var myUserId: String!
    var requestId: String!
    var requestTitle: String!
    var myProfilePhoto: UIImageView!
    var otherProfilePhoto: UIImageView!
    var payButton: UIButton!

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
        //braintree = Braintree(clientToken: CLIENT_TOKEN_FROM_SERVER)
        
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
        let messageLabel: UILabel = UILabel(frame: CGRect(x:20, y: 70, width: self.view.frame.width-40, height: 25))
        messageLabel.text = "Write a message..."
        
        messageTextField = UITextField(frame: CGRect(x:20, y: 70+messageLabel.frame.height+10, width: self.view.frame.width-40, height: 50))
        messageTextField.layer.borderColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
        messageTextField.layer.borderWidth = 2.0
        messageTextField.delegate = self
        
        myProfilePhoto = UIImageView()
        myProfilePhoto.frame = CGRect(x: 20, y: 80, width: self.view.frame.width-230, height: self.view.frame.width-230)
        myProfilePhoto.layer.borderWidth = 1
        myProfilePhoto.layer.masksToBounds = false
        myProfilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        myProfilePhoto.layer.cornerRadius = 10
        myProfilePhoto.clipsToBounds = true
        view.addSubview(myProfilePhoto)
        
        self.payButton = UIButton(frame: CGRect(x: 20, y: 70+messageTextField.frame.height+messageLabel.frame.height+10+photoLabel.frame.height+20+photoImageView.frame.height+10, width: self.view.frame.width-40, height: 50))
        payButton.addTarget(self, action: #selector(self.createProffr(_:)), for: .touchUpInside)
        payButton.layer.backgroundColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
        payButton.layer.cornerRadius = 5
        payButton.setTitle("Done", for: .normal)
        
        self.view.addSubview(messageLabel)
        self.view.addSubview(messageTextField)
        self.view.addSubview(photoLabel)
        self.view.addSubview(myProfilePhoto)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
