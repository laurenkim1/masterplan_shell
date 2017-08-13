//
//  distancePageViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/6/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import os.log

class DistancePageViewController: UIViewController, UITextFieldDelegate {
    
    // Mark: Properties
    @IBOutlet weak var distanceInput: UITextField!
    @IBOutlet weak var nextPhaseButton: UIButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var request: requestInfo? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceInput.delegate = self
        updateNextPhaseButtonState()
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
        updateNextPhaseButtonState();
    }
    
    // MARK: Actions
    @IBAction func unwindToDistancePage(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? TagListViewController {
        }
    }

    // MARK: Private Methods
    
    private func updateNextPhaseButtonState() {
        // Disable the Save button if the text field is empty.
        let distanceText = distanceInput.text ?? ""
        nextPhaseButton.isEnabled = !distanceText.isEmpty
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIButton, button === nextPhaseButton || button === backButton else {
            os_log("The next phase button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        let _distance = Float(distanceInput.text!)!
        request?.distance = _distance
        
        let tagCount : Int = (self.request?.requestTags.count)!
        
        if tagCount == 0 {
            self.request?.requestTags.append("Add Tags")
        }
        
        if let destinationViewController = segue.destination as? TagListViewController {
            destinationViewController.request = request
        }
    }

}
