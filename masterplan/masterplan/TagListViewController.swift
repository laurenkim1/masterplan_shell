//
//  tagListViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 7/10/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import os.log

private let kBaseURL: String = "http://localhost:3000/"
private let kRequests: String = "requests"
private let kFiles: String = "files"

class TagListViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let reuseIdentifier = "tag";
    
    // Mark: Properties
    @IBOutlet var tagList: UICollectionView!
    @IBOutlet weak var newTag: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    var request: requestInfo?
    var objects: NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UICollectionViewDelegateFlowLayout methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        
        return 4;
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        
        return 1;
    }
    
    
    //UICollectionViewDatasource methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (self.request?.requestTags.count)!
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TagListItemViewCollectionViewCell
        
        let row: Int = indexPath.row
        cell.backgroundColor = self.randomColor()
        cell.tagLabel.text = self.request?.requestTags[row]
        
        return cell
    }
    
    
    // custom function to generate a random UIColor
    func randomColor() -> UIColor{
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    // Mark: Actions
    
    @IBAction func addTagtoList(_ sender: UIButton) {
        self.request?.requestTags.append(newTag.text!)
        self.tagList.reloadData()
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
                os_log("Success")
                let response = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                request.requestID = response?["_id"] as? String
            }
        })
        dataTask?.resume()
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        persist(self.request!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func conditionalUnwind(_ sender: UIBarButtonItem) {
        if let navController = self.parent as! UINavigationController? {
            let parentVCIndex = navController.viewControllers.count - 2
            if navController.viewControllers[parentVCIndex] is NewRequestViewController {
                performSegue(withIdentifier: "unwindToNewRequest", sender: self)
            }
            else if navController.viewControllers[parentVCIndex] is DistancePageViewController {
                performSegue(withIdentifier: "unwindToDistancePage", sender: self)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationViewController = segue.destination as? DistancePageViewController {
            destinationViewController.request = request
        }
        
        else if let destinationViewController = segue.destination as? NewRequestViewController {
            destinationViewController.request = request
        }
    }


}
