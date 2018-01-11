//
//  ChatViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/26/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import Photos
import os.log
import Firebase
import FirebaseStorage
import JSQMessagesViewController
import XLActionController
import CoreLocation
import SwiftMessages

private let kBaseURL: String = "http://18.221.170.199/"
private let kRequests: String = "requests/"
private let kNotifications: String = "notifications/"
private let kUsers: String = "users/"

class ChatViewController: JSQMessagesViewController {
    
    lazy var notificationChannelRef: DatabaseReference = Database.database().reference().child("notifications")

    // MARK: Properties
    private let imageURLNotSetKey = "NOTSET"

    var channelRef: DatabaseReference?
    var outgoing: Int!
    var acceptButton: UIBarButtonItem!
    var requestId: String!
    var requestTitle: String!
    var userLocation: CLLocation!
    var myPhotoUrl: String!
    var otherPhotoUrl: String!
    var acceptedName: String!
    var acceptedId: String!
    var alreadyAccepted: Int!
    var button: UIBarButtonItem!
    
    private lazy var accepted: DatabaseReference = self.channelRef!.child("Accepted")
    private lazy var messageRef: DatabaseReference = self.channelRef!.child("messages")
    fileprivate lazy var storageRef = Storage.storage().reference(forURL: "gs://proffr-d0848.appspot.com/")
    private lazy var userIsTypingRef: DatabaseReference = self.channelRef!.child("typingIndicator").child(self.senderId)
    private lazy var usersTypingQuery: DatabaseQuery = self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    
    private var messages: [JSQMessage] = []
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    
    private var localTyping = false
    var channel: ProffrChannel? {
        didSet {
            title = channel?.name
        }
    }
    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = Auth.auth().currentUser?.uid
        observeMessages()
        self.setNavBar()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    // MARK: Collection view data source (and related) methods
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId { // 1
            cell.textView?.textColor = UIColor.white // 2
        } else {
            cell.textView?.textColor = UIColor.black // 3
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    // MARK: Actions
    
    private func setNavBar() {
        self.acceptButton = UIBarButtonItem(title: "Accept", style: .plain, target: self, action: #selector(acceptButtonTapped))
        if self.alreadyAccepted == 1 {
            self.acceptButton.isEnabled = false
        }
        if self.outgoing == 0 {
            self.navigationItem.rightBarButtonItem = acceptButton
        }
        
        let screenSize: CGRect = UIScreen.main.bounds
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: self.navigationController!.navigationBar.frame.maxY, width: screenSize.width, height: 30))
        let buttonString: String = "For: \"" + self.requestTitle + "\""
        self.button = UIBarButtonItem(title: buttonString, style: .plain, target: self, action: #selector(titleTapped))
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
    
    @objc func acceptButtonTapped(){
        let actionController = PeriscopeActionController()
        actionController.headerData = "Accept Proffr?"
        actionController.addAction(Action("Accept", style: .destructive, handler: { action in
            self.channelRef?.observeSingleEvent(of: .value, with: { (snapshot) -> Void in // 1
                let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
                if (channelData["requestId"] as! String!) != nil {
                    self.acceptedId = channelData["proffrerId"] as! String
                    self.acceptedName = channelData["proffererName"] as! String
                    self.otherPhotoUrl = channelData["proffrerPhotoUrl"] as! String!
                    
                    self.sendNotification(recipientId: self.acceptedId, channelSnapshot: channelData as NSDictionary)
                    self.getFcmTokenSend(id: self.acceptedId, channelSnapshot: channelData as NSDictionary)
                    self.updateRequest(requestId: self.requestId)
                    
                    // self.deleteOtherProffrs(requestId: requestId, acceptedId: self.acceptedId)
                    self.accepted.setValue(1)
                    self.getRequest(nxt: 0)
                } else {
                    print("Error! Could not decode channel data in Create Proffr")
                }
            })
        }))
        actionController.addAction(Action("Cancel", style: .cancel, handler: { action in
        }))
        present(actionController, animated: true, completion: nil)
    }
    
    func titleTapped() {
        button.isEnabled = false
        self.getRequest(nxt: 1)
    }
    
    func getRequest(nxt: Int) -> Void {
        let requests: String = kBaseURL + kRequests
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
                        if nxt == 1 {
                            self.parseRequest(requestdict: response!)
                        } else if nxt == 0 {
                            self.moveToPay(requestdict: response!)
                        }
                    } else {
                        self.warning()
                    }
                }
            }
        })
        dataTask?.resume()
    }
    
    func parseRequest(requestdict: NSDictionary) -> Void {
        let request = requestInfo(dict: requestdict)
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
    
    // MARK: Network Request Methods
    
    /*
    func deleteAcceptedRequests(requestId: String) -> Void {
        print(requestId)
        let requests: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kRequests).absoluteString
        let url = URL(string: (requests + requestId))
        //1
        var networkrequest = URLRequest(url: url!)
        networkrequest.httpMethod = "DELETE"
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
            }
        })
        dataTask?.resume()
    }
 
    //sends notifications to others and updates request as accepted
    
    func deleteOtherProffrs(requestId: String, acceptedId: String) -> Void {
        let allChannels = channelRef?.parent
        let sameRequestProffrs = allChannels?.queryEqual(toValue: requestId, childKey: "requestId")
        let sameRequestRef = sameRequestProffrs?.ref
        sameRequestRef?.observeSingleEvent(of: .value, with: { (snapshot) -> Void in // 1
            for child in snapshot.children {
                let childData = (child as! DataSnapshot).value as! NSDictionary
                if (childData["requestId"] as! String) == requestId {
                    let proffrerId: String = childData["proffrerId"] as! String
                    if proffrerId == acceptedId {
                        self.sendNotification(recipientId: acceptedId, channelSnapshot: childData)
                        self.getFcmTokenSend(id: acceptedId, channelSnapshot: childData)
                        self.updateRequest(requestId: self.requestId)
                    } else {
                        sameRequestRef?.child((child as! DataSnapshot).key).removeValue()
                    }
                }
            }
        })
    }
    */
    
    func updateRequest(requestId: String) {
        let requests: String = kBaseURL + kRequests
        let url = URL(string: requests + requestId)
        //1
        var networkrequest = URLRequest(url: url!)
        networkrequest.httpMethod = "PUT"
        //2
        let jsonable = NSMutableDictionary()
        jsonable.setValue(true, forKey: "fulfilled")
        
        let data: Data? = try? JSONSerialization.data(withJSONObject: jsonable, options: [])
        //3
        
        networkrequest.httpBody = data
        networkrequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask: URLSessionDataTask? = session.dataTask(with: networkrequest, completionHandler: {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            //5
            if error == nil {
                os_log("Success")
                _ = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            }
        })
        dataTask?.resume()
    }
    
    func sendNotification(recipientId: String, channelSnapshot: NSDictionary) {
        let notifications: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kNotifications).absoluteString
        let url = URL(string: notifications)
        //1
        var networkrequest = URLRequest(url: url!)
        networkrequest.httpMethod = "POST"
        //2
        
        let userId = recipientId 
        let requesterName = channelSnapshot["requesterName"] as! String
        let requesterId = channelSnapshot["requesterId"] as! String
        let requestPrice = channelSnapshot["requestPrice"] as! Double
        let requestTitle = channelSnapshot["subTitle"] as! String
        let requestId = channelSnapshot["requestId"] as! String
        let photoUrl = channelSnapshot["requesterPhotoUrl"] as! String
        
        let notification = notificationModel(userID: userId, requestTitle: requestTitle, requestPrice: requestPrice, requestId: requestId, requesterId: requesterId, requesterName: requesterName, photoUrl: photoUrl)
        let data: Data? = try? JSONSerialization.data(withJSONObject: notification?.toDictionary()!, options: [])
        //3
        networkrequest.httpBody = data
        networkrequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask: URLSessionDataTask? = session.dataTask(with: networkrequest, completionHandler: {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            //5
            if error == nil {
                os_log("Success")
                _ = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            }
        })
        dataTask?.resume()
    }
    
    func moveToPay(requestdict: NSDictionary) -> Void {
        let request = requestInfo(dict: requestdict)
        let nextViewController: PaymentViewController = PaymentViewController()
        nextViewController.requestId = requestId
        nextViewController.request = request
        nextViewController.requestTitle = requestTitle
        nextViewController.userLocation = userLocation
        nextViewController.myPhotoUrl = self.myPhotoUrl
        nextViewController.otherPhotoUrl = self.otherPhotoUrl
        nextViewController.proffrerName = self.acceptedName
        nextViewController.proffrerId = self.acceptedId
        navigationController?.pushViewController(nextViewController,
                                                 animated: true)
    }

    
    // MARK: Firebase related methods
    
    private func observeMessages() {
        messageRef = self.channelRef!.child("messages")
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String! {
                self.addMessage(withId: id, name: name, text: text)
                self.finishReceivingMessage()
            } else if let id = messageData["senderId"] as String!, let photoURL = messageData["photoURL"] as String! {
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let photoURL = messageData["photoURL"] as String! {
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] {
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
                }
            }
        })
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        let storageRef = self.storageRef.storage.reference(forURL: photoURL)
        storageRef.getData(maxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                mediaItem.image = UIImage.init(data: data!)
                self.collectionView.reloadData()
                
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    private func observeTyping() {
        let typingIndicatorRef = channelRef!.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
        
        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            
            // You're the only typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // 1
        let itemRef = messageRef.childByAutoId()
        
        // 2
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        // 3
        itemRef.setValue(messageItem)
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
        isTyping = false
    }
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    // MARK: UI and User Interaction
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = (self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    // MARK: UITextViewDelegate methods
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
}

// MARK: Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        // 1
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            // Handle picking a Photo from the Photo Library
            // 2
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            // 3
            if let key = sendPhotoMessage() {
                // 4
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                    // 5
                    let path = "\(String(describing: Auth.auth().currentUser?.uid))/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    
                    // 6
                    self.storageRef.child(path).putFile(from: imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        // 7
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        } else {
            // Handle picking a Photo from the Camera - TODO
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    // Mark: Get recipient fcmToken and update badge
    
    func getFcmTokenSend(id: String, channelSnapshot: NSDictionary) {
        
        let userId = id
        let requesterName = channelSnapshot["requesterName"] as! String
        let requesterId = channelSnapshot["requesterId"] as! String
        let requestPrice = channelSnapshot["requestPrice"] as! Double
        let requestTitle = channelSnapshot["subTitle"] as! String
        let requestId = channelSnapshot["requestId"] as! String
        let photoUrl = channelSnapshot["requesterPhotoUrl"] as! String
        
        let notification = notificationModel(userID: userId, requestTitle: requestTitle, requestPrice: requestPrice, requestId: requestId, requesterId: requesterId, requesterName: requesterName, photoUrl: photoUrl)
        let noti: NSDictionary? = notification?.toDictionary()!
        
        let requests: String = kBaseURL + kUsers + "badge/"
        let parameterString: String = id
        let url = URL(string: (requests + parameterString))
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
                //let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! Array<Any>
                let responseDict = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                //let responseDict = response?[0] as! NSDictionary
                guard let fcmToken = responseDict!["fcmToken"] as? String else {
                    os_log("Unable to decode the fcmToken for a user.", log: OSLog.default, type: .debug)
                    return
                }
                noti?.setValue(fcmToken, forKey: "registrationToken")
                noti?.setValue(self.acceptedName, forKey: "message")
                if let badgeCount = responseDict!["badgeCount"] as? String {
                    noti?.setValue(badgeCount, forKey: "badgeCount")
                } else {
                    noti?.setValue(1, forKey: "badgeCount")
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

