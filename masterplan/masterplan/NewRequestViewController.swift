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
                $0.title = "Delivery Required:"
                $0.options = ["Yes", "No"]
                $0.value = "Yes"
        }
            +++ Section("PickUpDistance")
            <<< DecimalRow("Distance") {
                $0.title = "I can travel (mi):"
                $0.placeholder = "0.5"
                $0.disabled = Eureka.Condition.function(["pickUp"], { (form) -> Bool in
                    let row: SegmentedRow<String> = form.rowBy(tag: "pickUp")!
                    return (row.value == "Yes")
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
            request = requestInfo(userID: myUserId, userName: myDisplayName, requestTitle: _title, requestPrice: _price, pickUp: _pickup, location: userLocation, photoUrl: myPhotoUrl)
            
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


