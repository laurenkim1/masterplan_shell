//
//  NewProffrViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 8/14/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import Firebase
import Photos

private let kBaseURL: String = "https://"

class NewProffrViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    
    private let imageURLNotSetKey = "NOTSET"
    var senderId: String!
    var senderDisplayName: String?
    var request: requestInfo?
    var photoReferenceUrl: String!
    var myPhotoUrl: String!
    
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    
    fileprivate lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://proffr-d0848.appspot.com")
    
    var messageTextField: UITextField!
    var photoImageView: UIImageView!
    var doneButton: UIButton!
    var gestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.setView()
        self.updateCreateProffrButtonState()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.updateCreateProffrButtonState()
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
        
        let photoRefNSUrl = info[UIImagePickerControllerReferenceURL] as! NSURL
        self.photoReferenceUrl = photoRefNSUrl.absoluteString
        
        self.updateCreateProffrButtonState()
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        messageTextField.resignFirstResponder()
        
        print("gesture recognized")
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func createProffr(_ sender: UIButton) {
        
        //disable button for further tapping
        sender.isUserInteractionEnabled = false
        if let subTitle = request?.requestTitle {
            let newChannelRef = channelRef.childByAutoId() // 2
            let requesterPhotoUrlString = self.request!.photoUrl.absoluteString
            let channelItem: NSDictionary = [ // 3
                "proffererName": senderDisplayName!,
                "proffrerId": senderId!,
                "proffrerPhotoUrl": self.myPhotoUrl,
                "subTitle": subTitle,
                "requestId": self.request!.requestID!,
                "requestPrice": self.request!.requestPrice,
                "requesterName": self.request!.userName,
                "requesterId": self.request!.userID,
                "requesterPhotoUrl": requesterPhotoUrlString,
                "Accepted": 0
            ]
            
            newChannelRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in // 1
                let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
                let id = snapshot.key
                if let name = channelData["requesterName"] as! String!, name.characters.count > 0 { // 3
                    let photoUrl: String = channelData["requesterPhotoUrl"] as! String!
                    let channel = ProffrChannel(id: id, name: name, subTitle: channelData["subTitle"] as! String, photoUrl: photoUrl)
                    self.segueToNewChannel(channel: channel)
                } else {
                    print("Error! Could not decode channel data in Create Proffr")
                }
                
            })
            
            newChannelRef.setValue(channelItem)
        }
    }
    
    //MARK: Private Methods
    
    private func updateCreateProffrButtonState() {
        // Disable the Save button if the text field is empty.
        let text = messageTextField.text ?? ""
        let photoRefString = self.photoReferenceUrl ?? ""
        self.doneButton.isEnabled = !text.isEmpty && !photoRefString.isEmpty
    }
    
    func setView() {
        let messageLabel: UILabel = UILabel(frame: CGRect(x:20, y: 70, width: self.view.frame.width-40, height: 25))
        messageLabel.text = "Write a message..."
        
        messageTextField = UITextField(frame: CGRect(x:20, y: 70+messageLabel.frame.height+10, width: self.view.frame.width-40, height: 50))
        messageTextField.layer.borderColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
        messageTextField.layer.borderWidth = 2.0
        messageTextField.delegate = self
        
        let photoLabel = UILabel(frame: CGRect(x: 20, y: 70+messageTextField.frame.height+messageLabel.frame.height+20, width: self.view.frame.width-40, height: 25))
        photoLabel.text = "Upload a photo..."
    
        photoImageView = UIImageView(image: UIImage(named: "DefaultPhoto"))
        photoImageView.frame = CGRect(x: 20, y: 70+messageTextField.frame.height+messageLabel.frame.height+10+photoLabel.frame.height+20, width: self.view.frame.width-40, height: self.view.frame.width-40)
        photoImageView.layer.borderColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
        photoImageView.layer.borderWidth = 2.0
        photoImageView.isUserInteractionEnabled = true
        
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        gestureRecognizer.delegate = self
        photoImageView.addGestureRecognizer(gestureRecognizer)
        
        self.doneButton = UIButton(frame: CGRect(x: 20, y: 70+messageTextField.frame.height+messageLabel.frame.height+10+photoLabel.frame.height+20+photoImageView.frame.height+10, width: self.view.frame.width-40, height: 50))
        doneButton.addTarget(self, action: #selector(self.createProffr(_:)), for: .touchUpInside)
        doneButton.layer.backgroundColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
        doneButton.layer.cornerRadius = 5
        doneButton.setTitle("Done", for: .normal)
        
        self.view.addSubview(messageLabel)
        self.view.addSubview(messageTextField)
        self.view.addSubview(photoLabel)
        self.view.addSubview(photoImageView)
        self.view.addSubview(doneButton)
    }
    
    // MARK: - Navigation
    
    func segueToNewChannel(channel: ProffrChannel){
        let chatVc: NewChatViewController = NewChatViewController()
        
        chatVc.senderDisplayName = senderDisplayName
        chatVc.channel = channel
        chatVc.channelRef = channelRef.child(channel.id)
        if !self.photoReferenceUrl.isEmpty {
            chatVc.proffrPhotoUrlString = self.photoReferenceUrl
            chatVc.messageText = self.messageTextField.text!
        }
        chatVc.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(chatVc,
                                                 animated: false)
    }
    
     /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
