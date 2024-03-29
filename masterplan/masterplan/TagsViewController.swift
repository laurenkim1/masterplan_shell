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
import XLActionController

private let kBaseURL: String = "http://18.221.170.199/"
private let kRequests: String = "requests/"
private let kUsers: String = "users/"
private let kFiles: String = "files"

class TagsViewController: UIViewController, UITextFieldDelegate, AMTagListDelegate {
    
    // Mark: Properties
    var tagListView: AMTagListView!
    var textField: UITextField!
    var request: requestInfo?
    var myUserId: String!
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
        textField = UITextField(frame: CGRect(x:10, y: self.navigationController!.navigationBar.frame.maxY + 15, width: self.view.frame.width-20, height: 50))
        textField.placeholder = "  Add tags..."
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.delegate = self
        textField.layer.cornerRadius = 5
        
        AMTagView.appearance().tagLength = 10
        AMTagView.appearance().textFont = UIFont(name: "Futura", size: 14)
        AMTagView.appearance().tagColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1)
        
        tagListView = AMTagListView(frame: CGRect(x:10, y: self.navigationController!.navigationBar.frame.maxY + 15+textField.frame.height+10, width: self.view.frame.width-20, height: 400))
        self.tagListView.tagListDelegate = self
        tagListView.layer.borderColor = UIColor.lightGray.cgColor
        tagListView.layer.borderWidth = 2.0
        tagListView.layer.cornerRadius = 5
        
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
        dismiss(animated: true, completion: nil)
    }
    
    func persist(_ request: requestInfo) {
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
                
                request.postTimeString = response?["createdAt"] as? String
            }
        })
        dataTask?.resume()
    }

}
