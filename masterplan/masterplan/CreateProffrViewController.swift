//
//  CreateProffrViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/26/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import Firebase

class CreateProffrViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    private var channelRefHandle: DatabaseHandle?
    var senderDisplayName: String?
    var request: requestInfo?
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text field’s user input through delegate callbacks.
        messageTextField.delegate = self
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        // createProffrButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // updateCreateButtonState()
        navigationItem.title = textField.text
    }

    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Actions
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        messageTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func createProffr(_ sender: UIButton) {
        if let subTitle = request?.requestTitle { // username actually
            let newChannelRef = channelRef.childByAutoId() // 2
            newChannelRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in // 1
                let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
                let id = snapshot.key
                if let name = channelData["name"] as! String!, name.characters.count > 0 { // 3
                    let channel = ProffrChannel(id: id, name: name, subTitle: channelData["subTitle"] as! String)
                    self.performSegue(withIdentifier: "OpenProffrChat", sender: channel)
                } else {
                    print("Error! Could not decode channel data in Create Proffr")
                }
                
            })
            let channelItem: NSDictionary = [ // 3
                "name": senderDisplayName!,
                "subTitle": subTitle
            ]
            newChannelRef.setValue(channelItem) // 4
        }
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let channel = sender as? ProffrChannel {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.senderDisplayName = senderDisplayName
            chatVc.channel = channel
            chatVc.channelRef = channelRef.child(channel.id)
            chatVc.hidesBottomBarWhenPushed = true
        }
    }
    
    //MARK: Private Methods
    
    private func updateCreateProffrButtonState() {
        // Disable the Save button if the text field is empty.
        let text = messageTextField.text ?? ""
        // createProffrButton.isEnabled = !text.isEmpty
    }

}
