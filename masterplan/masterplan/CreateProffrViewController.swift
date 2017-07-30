//
//  CreateProffrViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/26/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import Firebase
import Photos

private let kBaseURL: String = "https://"

class CreateProffrViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    private let imageURLNotSetKey = "NOTSET"
    var senderId: String!
    var photoReferenceUrl: URL!
    
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    
    fileprivate lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://proffr-d0848.appspot.com")
    
    var senderDisplayName: String?
    var request: requestInfo?
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = Auth.auth().currentUser?.uid

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
        
        self.photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as! URL
        print(photoReferenceUrl)

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
        if let subTitle = request?.requestTitle {
            let newChannelRef = channelRef.childByAutoId() // 2
            let channelItem: NSDictionary = [ // 3
                "name": senderDisplayName!,
                "subTitle": subTitle
            ]
            newChannelRef.setValue(channelItem) // 4
            
            let messageRef: DatabaseReference = newChannelRef.child("messages")
            let assets = PHAsset.fetchAssets(withALAssetURLs: [self.photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            // 3
            if let key = sendPhotoMessage(messageRef: messageRef) {
                // 4
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                    // 5
                    let path = "\(Auth.auth().currentUser?.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(self.photoReferenceUrl.lastPathComponent)"
                    
                    // 6
                    self.storageRef.child(path).putFile(from: imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        // 7
                        
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
                        
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key, messageRef: messageRef)
                    }
                })
            }
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
    
    private func sendPhotoMessage(messageRef: DatabaseReference) -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem: NSDictionary = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            "senderName": "Lauren Kim - hardcoded"
            ]
        
        itemRef.setValue(messageItem)
        return itemRef.key
    }
    
    private func setImageURL(_ url: String, forPhotoMessageWithKey key: String, messageRef: DatabaseReference) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }

}
