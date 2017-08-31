//
//  TagsViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 8/14/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import AMTagListView
import os.log
import EasyPeasy
import Neon
import XLActionController

private let kBaseURL: String = "http://localhost:3000/"
private let kRequests: String = "requests"
private let kUsers: String = "users"
private let kFiles: String = "files"

class TagsViewController: UIViewController, UITextFieldDelegate, AMTagListDelegate {
    
    // Mark: Properties
    var tagListView: AMTagListView!
    var textField: UITextField!
    var request: requestInfo?
    var objects: NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Proffr"
        self.view.backgroundColor = UIColor.white
        self.setTagList()
        self.setNavigationBar()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        tagListView.addTag(textField.text!)
        textField.text = ""
        return false;
    }*/
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        tagListView.addTag(textField.text!)
        textField.text = ""
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    
    // MARK: Actions
    
    func setTagList() {
        textField = UITextField(frame: CGRect(x:20, y: 80, width: self.view.frame.width-40, height: 25))
        textField.layer.borderColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
        textField.layer.borderWidth = 2.0
        textField.delegate = self
        
        AMTagView.appearance().tagLength = 10
        AMTagView.appearance().textFont = UIFont(name: "Futura", size: 14)
        AMTagView.appearance().tagColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1)
        
        tagListView = AMTagListView(frame: CGRect(x:20, y: 80+textField.frame.height+10, width: self.view.frame.width-40, height: 400))
        self.tagListView.tagListDelegate = self
        tagListView.layer.borderColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
        tagListView.layer.borderWidth = 2.0
        
        tagListView.setTapHandler({(_ view: AMTagView?) -> Void in
            // self.tagListView.removeTag(view)
            self.removeTag(view!)
            })
        
        self.view.addSubview(textField)
        self.view.addSubview(tagListView)
        tagListView.addTag("Add tags")
    }
    
    func removeTag(_ view: AMTagView) {
        let actionController = PeriscopeActionController()
        actionController.headerData = "Delete Tag?"
        actionController.addAction(Action("Delete", style: .destructive, handler: { action in
            self.tagListView.removeTag(view)
        }))
        actionController.addAction(Action("Cancel", style: .cancel, handler: { action in
        }))
        present(actionController, animated: true, completion: nil)
    }
    
    func setNavigationBar() {
        let saveButton = UIBarButtonItem(image: UIImage(named: "icons8-Ok-50"), style: .plain, target: self, action: #selector(done))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func done() {
        for tag in self.tagListView.tags {
            request?.requestTags.append((tag as! AMTagView).tagText as String)
        }
        persist(self.request!)
        persistToUser(self.request!)
        dismiss(animated: true, completion: nil)
    }
    
    func persist(_ request: requestInfo) {
        if request == nil || request.requestTitle == nil || request.requestPrice == 0 {
            return
            //input safety check
        }
        let requests: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kRequests).absoluteString
        let url = URL(string: requests)
        //1
        var networkrequest = URLRequest(url: url!)
        networkrequest.httpMethod = "POST"
        //2
        let data: Data? = try? JSONSerialization.data(withJSONObject: request.toDictionary(), options: [])
        //3
        networkrequest.httpBody = data
        networkrequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask: URLSessionDataTask? = session.dataTask(with: networkrequest, completionHandler: {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            //5
            if error == nil {
                os_log("Successfully posted to Requests DB")
                let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                request.requestID = response?["_id"] as? String
            }
        })
        dataTask?.resume()
    }
    
    func persistToUser(_ request: requestInfo) {
        if request.userID == nil || request.requestTitle == nil || request.requestPrice == 0 {
            return
            //input safety check
        }
        let users: String = URL(fileURLWithPath: kBaseURL).appendingPathComponent(kUsers).absoluteString
        let url = URL(string: (users + "newreq" + request.userID))
        //1
        var networkrequest = URLRequest(url: url!)
        networkrequest.httpMethod = "PUT"
        //2
        let data: Data? = try? JSONSerialization.data(withJSONObject: request.toDictionary(), options: [])
        //3
        networkrequest.httpBody = data
        networkrequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask: URLSessionDataTask? = session.dataTask(with: networkrequest, completionHandler: {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
            //5
            if error == nil {
                os_log("Successfully posted to User")
            }
        })
        dataTask?.resume()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
