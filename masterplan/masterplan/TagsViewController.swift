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

private let kBaseURL: String = "http://localhost:3000/"
private let kRequests: String = "requests"
private let kFiles: String = "files"

class TagsViewController: UIViewController, UITextFieldDelegate {
    
    // Mark: Properties
    var tagListView: AMTagListView!
    var textField: UITextField!
    var doneButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var request: requestInfo?
    var objects: NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Proffr"
        self.view.backgroundColor = UIColor.white
        self.setTagList()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        tagListView.addTag(textField.text!)
        textField.text = ""
        return false;
    }
    
    // MARK: Actions
    
    func setTagList() {
        textField = UITextField(frame: CGRect(origin: CGPoint(x: self.view.center.x, y: (self.view.center.y-200)), size: CGSize(width: 200, height: 20)))
        textField.layer.borderColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
        textField.layer.borderWidth = 2.0
        textField.delegate = self
        
        AMTagView.appearance().tagLength = 10
        AMTagView.appearance().textFont = UIFont(name: "Futura", size: 14)
        AMTagView.appearance().tagColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1)
        
        tagListView = AMTagListView(frame: CGRect(origin: self.view.center, size: CGSize(width: 200, height: 200)))
        
        self.view.addSubview(textField)
        self.view.addSubview(tagListView)
        tagListView.addTag("my tag")
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
