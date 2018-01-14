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
import SwiftMessages
import FirebaseStorage
import os.log

private let kBaseURL: String = "http://18.221.170.199/"
private let kRequests: String = "requests/"
private let kNotifications: String = "notifications/"
private let kUsers: String = "users/"

class NewProffrViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    lazy var notificationChannelRef: DatabaseReference = Database.database().reference().child("notifications")
    let semaphore = DispatchSemaphore(value: 1)
    
    private let imageURLNotSetKey = "NOTSET"
    var senderId: String!
    var senderDisplayName: String?
    var request: requestInfo?
    var photoReferenceUrl: String!
    var myPhotoUrl: String!
    var imageData: Data!
    
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
        // updateCreateButtonState()=
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
        
        imageData = UIImageJPEGRepresentation(selectedImage, 0.1)
        
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
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
            case .authorized:
                let imagePickerController = UIImagePickerController()
                
                // Only allow photos to be picked, not taken.
                imagePickerController.sourceType = .photoLibrary
                
                // Make sure ViewController is notified when the user picks an image.
                imagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
                self.present(imagePickerController, animated: true, completion: nil)
                break
            //handle denied status
            case .denied, .restricted:
                self.accessWarning()
            case .notDetermined:
                // ask for permissions
                PHPhotoLibrary.requestAuthorization() { (status) -> Void in
                    switch status {
                        case .authorized:
                            // UIImagePickerController is a view controller that lets a user pick media from their photo library.
                            let imagePickerController = UIImagePickerController()
                            
                            // Only allow photos to be picked, not taken.
                            imagePickerController.sourceType = .photoLibrary
                            
                            // Make sure ViewController is notified when the user picks an image.
                            imagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
                            self.present(imagePickerController, animated: true, completion: nil)
                            break
                        // as above
                        case .denied, .restricted:
                            return
                        // as above
                        case .notDetermined: break
                            // won't happen but still
                        }
                }
        }
    }
    
    func accessWarning() -> Void {
        let error = MessageView.viewFromNib(layout: .CenteredView)
        error.backgroundView.backgroundColor = UIColor.purple
        error.bodyLabel?.textColor = UIColor.white
        error.configureTheme(.error)
        error.configureContent(title: "Oops!", body: "Please Allow Access to Photos in Settings.")
        error.configureDropShadow()
        var errorConfig = SwiftMessages.defaultConfig
        errorConfig.duration = .forever
        error.button?.setTitle("Okay", for: .normal)
        error.button?.titleLabel?.font = UIFont(name: "Arial", size: 20)
        error.button?.addTarget(self, action: #selector(self.hide(_:)), for: .touchUpInside)
        SwiftMessages.show(config: errorConfig, view: error)
    }
    
    @objc func hide(_ sender: AnyObject) {
        SwiftMessages.hide()
    }
    
    @objc func createProffr(_ sender: UIButton) {
        
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
                let id = newChannelRef.key
                let channel = ProffrChannel(id: id, proffrerId: self.senderId, name: self.request!.userName, subTitle: subTitle, photoUrl: requesterPhotoUrlString, requestId: self.request!.requestID!, alreadyAccepted: 0)
                self.segueToNewChannel(channel: channel)
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
        
        messageTextField = UITextField(frame: CGRect(x:10, y: self.navigationController!.navigationBar.frame.maxY + 15, width: self.view.frame.width-20, height: 50))
        messageTextField.placeholder = "  Write a message..."
        messageTextField.layer.borderColor = UIColor.lightGray.cgColor
        messageTextField.layer.borderWidth = 1.0
        messageTextField.delegate = self
        messageTextField.layer.cornerRadius = 5
        
        let photoLabel = UILabel(frame: CGRect(x: 15, y: self.navigationController!.navigationBar.frame.maxY + 15+messageTextField.frame.height, width: self.view.frame.width-40, height: 25))
        photoLabel.textColor = UIColor.lightGray
        photoLabel.text = "Upload a photo..."
    
        photoImageView = UIImageView(image: UIImage(named: "DefaultPhoto"))
        photoImageView.frame = CGRect(x: 10, y: self.navigationController!.navigationBar.frame.maxY + 15+messageTextField.frame.height+photoLabel.frame.height, width: self.view.frame.width-20, height: self.view.frame.width-20)
        photoImageView.isUserInteractionEnabled = true
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = UIViewContentMode.scaleAspectFill
        photoImageView.layer.borderColor = UIColor.lightGray.cgColor
        photoImageView.layer.borderWidth = 2.0
        photoImageView.layer.cornerRadius = 5
        
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        gestureRecognizer.delegate = self
        photoImageView.addGestureRecognizer(gestureRecognizer)
        
        self.doneButton = UIButton(frame: CGRect(x: 20, y: self.navigationController!.navigationBar.frame.maxY + 25+messageTextField.frame.height+photoLabel.frame.height+photoImageView.frame.height, width: self.view.frame.width-40, height: 40))
        doneButton.addTarget(self, action: #selector(self.createProffr(_:)), for: .touchUpInside)
        doneButton.layer.backgroundColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
        doneButton.layer.cornerRadius = 5
        doneButton.setTitle("Done", for: .normal)
        
        doneButton.layer.shouldRasterize = true
        doneButton.layer.shadowColor = UIColor.black.cgColor
        doneButton.layer.shadowOpacity = 1
        doneButton.layer.shadowOffset = CGSize.zero
        doneButton.layer.shadowRadius = 1
        
        self.view.addSubview(messageTextField)
        self.view.addSubview(photoLabel)
        self.view.addSubview(photoImageView)
        self.view.addSubview(doneButton)
    }
    
    // MARK: - Navigation
    
    func segueToNewChannel(channel: ProffrChannel){
        self.getFcmTokenSend(id: (self.request?.userID)!)
        let chatVc: NewChatViewController = NewChatViewController()
        chatVc.myDisplayName = senderDisplayName
        chatVc.channel = channel
        chatVc.channelRef = channelRef.child(channel.id)
        chatVc.imageData = imageData
        if !self.photoReferenceUrl.isEmpty {
            chatVc.proffrPhotoUrlString = self.photoReferenceUrl
            chatVc.messageText = self.messageTextField.text!
        }
        chatVc.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(chatVc,
                                                 animated: true)
    }
    
    // Mark: Get recipient fcmToken and update badge
    
    func getFcmTokenSend(id: String) {
        let users: String = kBaseURL + kUsers + "badge/"
        let parameterString: String = id
        let url = URL(string: (users + parameterString))
        print(url as Any)
        //1
        var networkrequest = URLRequest(url: url!)
        networkrequest.httpMethod = "PUT"
        
        let data: Data? = try? JSONSerialization.data(withJSONObject: badgeToDict(), options: [])
        networkrequest.httpBody = data
        networkrequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask: URLSessionDataTask? = session.dataTask(with: networkrequest, completionHandler: {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            //5
            if error == nil {
                os_log("Success")
                let responseDict = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                guard let fcmToken = responseDict!["fcmToken"] as? String else {
                    os_log("Unable to decode the fcmToken for a user.", log: OSLog.default, type: .debug)
                    return
                }
                let noti: NSMutableDictionary! = NSMutableDictionary()
                noti.setValue(fcmToken, forKey: "registrationToken")
                noti.setValue(self.senderId, forKey: "message")
                if let badgeCount = responseDict!["badgeCount"] as? Int {
                    noti.setValue(badgeCount, forKey: "badgeCount")
                } else {
                    noti.setValue(1, forKey: "badgeCount")
                }
                
                let newChannelRef = self.notificationChannelRef.childByAutoId() // 2
                newChannelRef.setValue(noti)
            }
        })
        dataTask?.resume()
    }
    
    func badgeToDict() -> NSDictionary! {
        let jsonable = NSMutableDictionary()
        jsonable.setValue(1, forKey: "badgeCount")
        return jsonable
    }
}
