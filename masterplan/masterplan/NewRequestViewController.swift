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
import Eureka

class NewRequestViewController: FormViewController {
    
    //MARK: Properties
    
    var myDisplayName: String!
    var myUserId: String!
    var myPhotoUrl: String!
    var userLocation: CLLocation!
    
    var requestName: UITextField!
    var price: UITextField!
    var nextPhaseButton: UIBarButtonItem!
    
    let _location = CLLocation(latitude: 42.3770, longitude: -71.1167)
    
    var request: requestInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        form +++ Section("New Request")
            <<< TextRow("requestTitle"){ row in
                row.title = "I want:"
                row.placeholder = "a spatula"
            }
            <<< DecimalRow("price"){
                $0.title = "For ($):"
                $0.placeholder = "2.00"
            }
            <<< SegmentedRow<String>("pickUp"){
                $0.title = "I am willing to pick up the item:"
                $0.options = ["Yes", "No"]
                $0.value = "Yes"
        }
            +++ Section("PickUpDistance")
            <<< DecimalRow("Distance") {
                $0.title = "I am willing to travel (mi):"
                $0.placeholder = "0.5"
                $0.disabled = Eureka.Condition.function(["pickUp"], { (form) -> Bool in
                    let row: SegmentedRow<String> = form.rowBy(tag: "pickUp")!
                    return (row.value == "No")
                })
        }
    }
    
    // MARK: Actions
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func setNavigationBar() {
        // let cancelImage = UIButton(type: .custom)
        // cancelImage.setImage(UIImage(named: "icon_close"), for: .normal)
        //let cancelButton = UIBarButtonItem(customView: cancelImage)
        //cancelButton.target = self
        //cancelButton.action = #selector(cancel)
        let cancelButton = UIBarButtonItem(image: UIImage(named: "icons8-Cancel-50"), style: .plain, target: self, action: #selector(cancel))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        self.nextPhaseButton = UIBarButtonItem(image: UIImage(named: "icons8-Next page-50"), style: .plain, target: self, action: #selector(buttonTapped))
        self.navigationItem.rightBarButtonItem = nextPhaseButton
    }
    
    private func updateNextPhaseButtonState() {
        // Disable the Save button if the text field is empty.
        
        let titlerow: TextRow = form.rowBy(tag: "requestTitle")!
        let titleText = titlerow.value ?? ""
        
        let pricerow: DecimalRow = form.rowBy(tag: "price")!
        let priceText: Double! = pricerow.value

        nextPhaseButton.isEnabled = !titleText.isEmpty && (priceText>0.0)
    }
    
    // MARK: - Navigation
    
    func buttonTapped(){
        let nextViewController: UIViewController = TagsViewController()
        
        let titlerow: TextRow = form.rowBy(tag: "requestTitle")!
        let _title = titlerow.value ?? ""
        
        let pricerow: DecimalRow = form.rowBy(tag: "price")!
        let _price: Double! = pricerow.value
        
        let row: SegmentedRow<String> = form.rowBy(tag: "pickUp")!
        let _pickup: Int!
        if row.value == "Yes" {
            _pickup = 0
        } else {
            _pickup = 1
        }
        
        if request != nil {
        }
        else {
            request = requestInfo(userID: myUserId, userName: myDisplayName, requestTitle: _title, requestPrice: _price, pickUp: _pickup, location: _location, photoUrl: myPhotoUrl)
            
            if _pickup == 0 {
                let distancerow: DecimalRow = form.rowBy(tag: "Distance")!
                let _distance: Double! = distancerow.value
                request?.distance = _distance
            }
        }
        
        if let destinationViewController = nextViewController as? TagsViewController {
            destinationViewController.request = request
            destinationViewController.myUserId = self.myUserId
        }
        
        navigationController?.pushViewController(nextViewController,
                                                 animated: false)
    }
}


/*
class NewRequestViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    var myDisplayName: String!
    var myUserId: String!
    
    var requestName: UITextField!
    var price: UITextField!
    var pickUpBool: UISegmentedControl!
    let nextPhaseButton: UIButton! = UIButton(type: .system)
    
    let _location = CLLocation(latitude: 42.3770, longitude: -71.1167)
    
    var request: requestInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.title = "New Request"
        
        self.setUpSubViews()
        self.setNavigationBar()
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
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToNewRequestPage(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? DistancePageViewController {
        }
        else if let sourceViewController = sender.source as? TagListViewController {
        }
    }
    
    func setNavigationBar() {
        // let cancelImage = UIButton(type: .custom)
        // cancelImage.setImage(UIImage(named: "icon_close"), for: .normal)
        let cancelButton = UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(cancel))
        //let cancelButton = UIBarButtonItem(customView: cancelImage)
        //cancelButton.target = self
        //cancelButton.action = #selector(cancel)
        self.navigationItem.leftBarButtonItem = cancelButton
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
        
        nextPhaseButton.frame = (frame: CGRect(origin: CGPoint(x: self.view.center.x, y: self.view.center.y), size: CGSize(width: 100, height: 30)))
        nextPhaseButton.tintColor = UIColor.blue
        nextPhaseButton.setTitle("Next", for: .normal)
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

} */
