//
//  TagsViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 8/14/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import TagListView
import os.log

private let kBaseURL: String = "http://localhost:3000/"
private let kRequests: String = "requests"
private let kFiles: String = "files"

class TagsViewController: UIViewController, TagListViewDelegate, UITextFieldDelegate {
    
    // Mark: Properties
    var tagListView: TagListView!
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
        textField = UITextField(frame: CGRect(origin: CGPoint(x: self.view.center.x, y: (self.view.center.y+200)), size: CGSize(width: 200, height: 20)))
        textField.layer.borderColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
        textField.layer.borderWidth = 2.0
        textField.delegate = self
        
        
        
        tagListView = TagListView(frame: CGRect(origin: self.view.center, size: CGSize(width: 200, height: 200)))
        tagListView.delegate = self
        tagListView.addTag("TagListView")
        tagListView.addTag("TEAChart")
        tagListView.addTag("To Be Removed")
        tagListView.addTag("To Be Removed")
        tagListView.addTag("Quark Shell")
        tagListView.removeTag("To Be Removed")
        tagListView.addTag("On tap will be removed").onTap = { [weak self] tagView in
            self?.tagListView.removeTagView(tagView)
        }
        
        let tagView = tagListView.addTag("gray")
        tagView.tagBackgroundColor = UIColor.gray
        tagView.onTap = { tagView in
            print("Don’t tap me!")
        }
        
        tagListView.insertTag("This should be the third tag", at: 2)
        self.view.addSubview(tagListView)
    }
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
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
