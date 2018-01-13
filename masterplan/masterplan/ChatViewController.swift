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
import XLActionController
import CoreLocation
import SwiftMessages
import MessageKit
import Kingfisher
import MapKit

private let kBaseURL: String = "http://18.221.170.199/"
private let kRequests: String = "requests/"
private let kNotifications: String = "notifications/"
private let kUsers: String = "users/"

class ChatViewController: MessagesViewController {
    
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
    var myUserId: String!
    var myDisplayName: String!
    
    lazy var accepted: DatabaseReference = self.channelRef!.child("Accepted")
    lazy var messageRef: DatabaseReference = self.channelRef!.child("messages")
    fileprivate lazy var storageRef = Storage.storage().reference(forURL: "gs://proffr-d0848.appspot.com/")
    
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    
    var messageList: [ChatMessage] = []
    
    private var localTyping = false
    var channel: ProffrChannel? {
        didSet {
            title = channel?.name
        }
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myUserId = Auth.auth().currentUser?.uid
        observeMessages()
        self.setNavBar()
        
        messagesCollectionView.messagesDataSource = (self as MessagesDataSource)
        messagesCollectionView.messagesLayoutDelegate = (self as MessagesLayoutDelegate)
        messagesCollectionView.messagesDisplayDelegate = (self as MessagesDisplayDelegate)
        messagesCollectionView.messageCellDelegate = (self as MessageCellDelegate)
        messageInputBar.delegate = (self as MessageInputBarDelegate)
        
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        scrollsToBottomOnKeybordBeginsEditing = true // default false
    }
    
    // MARK: Actions
    
    private func setNavBar() {
        self.accepted.observeSingleEvent(of: .value, with: {(snapshot) -> Void in
            self.alreadyAccepted = snapshot.value as! Int
            self.acceptButton = UIBarButtonItem(title: "Accept", style: .plain, target: self, action: #selector(self.acceptButtonTapped))
            if self.alreadyAccepted == 1 {
                self.acceptButton.isEnabled = false
            }
            if self.outgoing == 0 {
                self.navigationItem.rightBarButtonItem = self.acceptButton
            }
        })
        
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
        let data: Data? = try? JSONSerialization.data(withJSONObject: notification?.toDictionary()! as Any, options: [])
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
            let messageId = snapshot.key as String
            let senderId = messageData["senderId"] as String!
            let senderName = messageData["senderName"] as String!
            let dateString = messageData["date"] as String!
            let date: Date = self.stringToDate(date: dateString!) as Date
            let sender = Sender(id: senderId!, displayName: senderName!)
            
            if let text = messageData["text"] as String! {
                let messageIndex = self.messageList.count
                let data: MessageData = self.setMessageData(data: text, contentType: "text", messageIndex: messageIndex)
                let message = ChatMessage(data: data, sender: sender, messageId: messageId, date: date)
                self.messageList.append(message)
            } else if let photoURL = messageData["photoURL"] as String! {
                if photoURL.hasPrefix("gs://") {
                    let messageIndex = self.messageList.count
                    let data: MessageData = self.setMessageData(data: photoURL, contentType: "image", messageIndex: messageIndex)
                    let message = ChatMessage(data: data, sender: sender, messageId: messageId, date: date)
                    self.messageList.append(message)
                }
            } else {
                print("Error! Could not decode message data")
            }
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
        })
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let messageData = snapshot.value as! Dictionary<String, String>
            let messageId = snapshot.key as String
            let senderId = messageData["senderId"] as String!
            let senderName = messageData["senderName"] as String!
            let dateString = messageData["date"] as String!
            let date: Date = self.stringToDate(date: dateString!) as Date
            let sender = Sender(id: senderId!, displayName: senderName!)
            
            if let photoURL = messageData["photoURL"] as String! {
                // The photo has been updated.
                if photoURL.hasPrefix("gs://") {
                    let messageIndex = self.messageList.count
                    let data: MessageData = self.setMessageData(data: photoURL, contentType: "image", messageIndex: messageIndex)
                    let message = ChatMessage(data: data, sender: sender, messageId: messageId, date: date)
                    self.messageList.append(message)
                }
            }
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
        })
    }
    /*
    private func fetchImageDataAtURL(_ photoURL: String, clearsPhotoMessageMapOnSuccessForKey key: String?) -> UIImage {
        let storageRef = self.storageRef.storage.reference(forURL: photoURL)
        var fetchedImage: UIImage!
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
                fetchedImage = UIImage.init(data: data!)
                guard key != nil else {
                    return
                }
            })
        }
        return fetchedImage
    }
*/
    
    func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: String!) {
        // 1
        let itemRef = messageRef.childByAutoId()
        
        // 2
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            "date": date
            ]
        
        // 3
        itemRef.setValue(messageItem)
    }
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": myUserId!,
            "senderName": myDisplayName!,
            "date": dateToString(date: Date())
            ]
        
        itemRef.setValue(messageItem)
        
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    // MARK: UI and User Interaction
    
    func stringToDate(date:String) -> NSDate {
        let formatter = DateFormatter()
        
        // Format 1
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let parsedDate = formatter.date(from: date) {
            return parsedDate as NSDate
        }
        return NSDate()
    }
    
    func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
        let myString = formatter.string(from: date)
        return myString
    }
    
    func iMessage() {
        defaultStyle()
        messageInputBar.isTranslucent = false
        // messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: true)
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: true)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: true)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "ic_up")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        messageInputBar.sendButton.backgroundColor = .clear
        messageInputBar.textViewPadding.right = -38
    }
    
    func defaultStyle() {
        let newMessageInputBar = MessageInputBar()
        newMessageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        newMessageInputBar.delegate = self
        messageInputBar = newMessageInputBar
        reloadInputViews()
    }
    
    // MARK: - Helpers
    
    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
            }.onSelected {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
        }
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
                if let badgeCount = responseDict!["badgeCount"] as? Int {
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

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    func currentSender() -> Sender {
        return Sender(id: self.myUserId, displayName: self.myDisplayName)
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func avatar(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Avatar {
        let initial = message.sender.displayName[message.sender.displayName.startIndex]
        let str = String(initial)
        return Avatar(initals: str)
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: nil)
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        struct ConversationDateFormatter {
            static let formatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter
            }()
        }
        let formatter = ConversationDateFormatter.formatter
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: nil)
    }
    
    func setMessageData(data: String, contentType: String, messageIndex: Int) -> MessageData {
        var messageData: MessageData!
        if contentType.range(of:"image") != nil {
            let loading = UIImage(named: "loading")
            messageData = MessageData.photo(loading!)
            let imageView = ImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.kf.indicatorType = .activity
            let storageRef = Storage.storage().reference(forURL: data)
            storageRef.getData(maxSize: INT64_MAX){ (imagedata, error) in
                if let error = error {
                    print("Error downloading image data: \(error)")
                    return
                }
                
                storageRef.getMetadata(completion: { (metadata, metadataErr) in
                    if let error = metadataErr {
                        print("Error downloading metadata: \(error)")
                        return
                    }
                    if let image = UIImage.init(data: imagedata!){
                        imageView.image = UIImage.init(data: imagedata!)
                        self.reloadMessage(messageIndex, MessageData.photo(image))
                    }
                })
            }
            if (imageView.image != nil) {
                return MessageData.photo(imageView.image!)
            }
        } else if contentType.range(of:"video") != nil {
            let url = URL(string: data)!
            return MessageData.video(file: url, thumbnail: UIImage(named: "videoThumbnail")!)
        } else {
            return MessageData.text(data)
        }
        return messageData
    }
    
    func reloadMessage(_ messageIndex: Int,_ messageData :MessageData) -> Void {
        if messageIndex < self.messageList.count {
            let oldMessage = self.messageList[messageIndex]
            self.messageList[messageIndex] = ChatMessage(
                data: messageData,
                sender: oldMessage.sender,
                messageId: oldMessage.messageId,
                date: oldMessage.sentDate
            )
            self.messagesCollectionView.reloadData()
        }
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    /*
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey : Any] {
        return MessageLabel.defaultAttributes
    }
    */
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        //        let configurationClosure = { (view: MessageContainerView) in}
        //        return .custom(configurationClosure)
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "pin")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(0, 0, 0)
            view.alpha = 0.0
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
                view.alpha = 1.0
            }, completion: nil)
        }
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        if isFromCurrentSender(message: message) {
            return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)
        } else {
            return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
        }
    }
    
    func cellTopLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        } else {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        }
    }
    
    func cellBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        if isFromCurrentSender(message: message) {
            return .messageLeading(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        } else {
            return .messageTrailing(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        }
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: messagesCollectionView.bounds.width, height: 10)
    }
    
    // MARK: - Location Messages
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 200
    }
    
}

extension ChatViewController: MediaMessageLayoutDelegate {
    
    func widthForMedia(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (view.frame.width / 3) * 2
    }
    
    func heightForMedia(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (view.frame.width / 3) * 2
    }
    
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell<UIView>) {
        print("Message tapped")
    }
    
    func didTapTopLabel(in cell: MessageCollectionViewCell<UIView>) {
        print("Top label tapped")
    }
    
    func didTapBottomLabel(in cell: MessageCollectionViewCell<UIView>) {
        print("Bottom label tapped")
    }
    
}

// MARK: - MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String : String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "senderId": myUserId!,
            "senderName": myDisplayName!,
            "text": text,
            "date": dateToString(date: Date())
        ]
        
        itemRef.setValue(messageItem)
        inputBar.inputTextView.text = String()
    }
    
}

