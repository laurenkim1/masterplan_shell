//
//  newRequestViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/7/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import os.log
import MapKit
import CoreLocation

class NewRequestViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    var myDisplayName: String!
    var myUserId: String!
    
    var requestName: UITextField!
    var price: UITextField!
    var pickUpBool: UISegmentedControl!
    let nextPhaseButton: UIButton! = UIButton()
    
    let _location = CLLocation(latitude: 42.3770, longitude: -71.1167)
    
    var request: requestInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.setUpSubViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        nextPhaseButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateNextPhaseButtonState()
    }
    
    //MARK: Private Methods
    
    private func updateNextPhaseButtonState() {
        // Disable the Save button if the text field is empty.
        let titleText = requestName.text ?? ""
        let priceText = price.text ?? ""
        nextPhaseButton.isEnabled = !titleText.isEmpty && !priceText.isEmpty
    }
    
    // MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToNewRequestPage(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? DistancePageViewController {
        }
        else if let sourceViewController = sender.source as? TagListViewController {
        }
    }
    
    func setUpSubViews() {
        requestName = UITextField(frame: CGRect(origin: CGPoint(x: self.view.center.x, y: 100), size: CGSize(width: 100, height: 30)))
        price = UITextField(frame: CGRect(origin: CGPoint(x: self.view.center.x, y: 120), size: CGSize(width: 100, height: 30)))
        pickUpBool = UISegmentedControl(items: ["Yes", "No"])
        pickUpBool.selectedSegmentIndex = 0
        pickUpBool.frame = (frame: CGRect(origin: CGPoint(x: self.view.center.x, y: 140), size: CGSize(width: 100, height: 30)))
        
        // Do any additional setup after loading the view.
        
        // Handle the text field’s user input through delegate callbacks.
        requestName.delegate = self
        price.delegate = self
        
        nextPhaseButton.frame = (frame: CGRect(origin: CGPoint(x: self.view.center.x, y: 160), size: CGSize(width: 30, height: 20)))
        nextPhaseButton.tintColor = UIColor.blue
        nextPhaseButton.setTitle("Next", for: UIControlState.normal)
        nextPhaseButton.addTarget(self, action: #selector(buttonTapped),
                                  for: .touchUpInside)
        
        updateNextPhaseButtonState()
        
        self.view.addSubview(requestName)
        self.view.addSubview(price)
        self.view.addSubview(pickUpBool)
        self.view.addSubview(nextPhaseButton)
    }

    
    // MARK: - Navigation
    
    func buttonTapped(){
        let nextViewController: UIViewController!
        if pickUpBool.selectedSegmentIndex == 0 {
            nextViewController = DistancePageViewController()
        }
        else {
            nextViewController = TagListViewController()
        }
        
        let _title = requestName.text ?? ""
        let _price = Float(price.text!)!
        let _pickup = pickUpBool.selectedSegmentIndex
        
        if request != nil {
        }
        else {
            request = requestInfo(userID: myUserId, userName: myDisplayName, requestTitle: _title, requestPrice: _price, pickUp: _pickup, location: _location)
            request?.requestTags.append("Add Tags")
        }
        
        if let destinationViewController = nextViewController as? TagListViewController {
            destinationViewController.request = request
        }
            
        else if let destinationViewController = nextViewController as? DistancePageViewController {
            destinationViewController.request = request
        }
        
        navigationController?.pushViewController(nextViewController,
                                                 animated: false)
    }
    
    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        let _title = requestName.text ?? ""
        let _price = Float(price.text!)!
        let _pickup = pickUpBool.selectedSegmentIndex
        
        if request != nil {
        }
        else {
            request = requestInfo(userID: myUserId, userName: myDisplayName, requestTitle: _title, requestPrice: _price, pickUp: _pickup, location: _location)
            request?.requestTags.append("Add Tags")
        }
        
        if let destinationViewController = segue.destination as? TagListViewController {
            destinationViewController.request = request
        }
        
        else if let destinationViewController = segue.destination as? DistancePageViewController {
            destinationViewController.request = request
        }
        
    }
 */

}
