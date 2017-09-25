//
//  RequestDetailsViewController.swift
//  masterplan
//
//  Created by Lauren Kim on 9/1/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import CoreLocation

class RequestDetailsViewController: UIViewController {
    
    //MARK: Properties
    
    fileprivate let padding: CGFloat = 2.0
    var ProfilePhoto : UIImageView!
    var userLocation: CLLocation!
    var request: requestInfo!
    var myDisplayName: String!
    var myUserId: String!
    var myPhotoUrl: String!
    var proffrButton: UIButton!
    
    let needslabel: UILabel = UILabel()
    let forlabel: UILabel = UILabel()
    let inlabel: UILabel = UILabel()
    let hourslabel: UILabel = UILabel()
    
    lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        return view
    }()
    
    lazy var requestPrice: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        return view
    }()
    
    lazy var requestTitle: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        return view
    }()
    
    lazy var distanceLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        return view
    }()
    
    lazy var timeLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.title = "Proffr"

        ProfilePhoto = UIImageView()
        ProfilePhoto.frame = CGRect(x: 30, y: 100, width: 80, height: 80)
        ProfilePhoto.layer.borderWidth = 1
        ProfilePhoto.layer.masksToBounds = false
        ProfilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        ProfilePhoto.layer.cornerRadius = ProfilePhoto.frame.height/2
        ProfilePhoto.clipsToBounds = true
        view.addSubview(ProfilePhoto)
        
        needslabel.text = "needs:"
        forlabel.text = "for:"
        inlabel.text = "in:"
        
        let photoUrl = request.photoUrl
        
        URLSession.shared.dataTask(with: photoUrl) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print("Download Started")
            print(response?.suggestedFilename ?? photoUrl.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                let image = UIImage(data: data)
                self.ProfilePhoto.image = image
            }
            }.resume()
        
        // change these parameters to match a request table cell
        requestTitle.text = request.requestTitle
        nameLabel.text = request.userName
        requestPrice.text = "$" + String(format:"%.2f", request.requestPrice)
        
        let postTime = request.postTime!
        let components: NSDateComponents = NSDateComponents()
        components.setValue(24, forComponent: NSCalendar.Unit.hour)
        let endTime = NSCalendar.current.date(byAdding: components as DateComponents, to: postTime as Date)
        let nowTime = Date()
        let timeLeft: TimeInterval = (endTime?.timeIntervalSince(nowTime))!
        
        if timeLeft > 0 {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .short
            let timeString = formatter.string(from: timeLeft)
            timeLabel.text = timeString
            inlabel.text = "in"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            timeLabel.text = formatter.string(from: request.postTime as! Date)
            inlabel.text = "on"
        }
        
        let _meterDistance: CLLocationDistance = userLocation.distance(from: request.location)
        let _distance: Double = _meterDistance/1609.34
        let _distanceString: String = "(" + String(format:"%.2f", _distance) + " mi)"
        distanceLabel.text = _distanceString
        
        nameLabel.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+20 , y: 110, width: 200, height: 30)
        nameLabel.textColor = UIColor.darkGray
        nameLabel.font = UIFont(name: "Ubuntu-Bold", size: 30)
        view.addSubview(nameLabel)
        
        needslabel.frame = CGRect(x: 50 , y: ProfilePhoto.frame.origin.y+ProfilePhoto.frame.size.height+10, width: 70, height: 30)
        needslabel.textColor = UIColor.lightGray
        needslabel.font = UIFont(name: "Ubuntu-Bold", size: 20)
        view.addSubview(needslabel)
        
        requestTitle.frame = CGRect(x: needslabel.frame.origin.x+needslabel.frame.width, y: ProfilePhoto.frame.origin.y+ProfilePhoto.frame.size.height+10, width: 400, height: 30)
        requestTitle.textColor = UIColor.darkGray
        requestTitle.font = UIFont(name: "Ubuntu-Bold", size: 20)
        view.addSubview(requestTitle)
        
        forlabel.frame = CGRect(x: 50, y: needslabel.frame.origin.y+needslabel.frame.size.height, width: 40, height: 30)
        forlabel.textColor = UIColor.lightGray
        forlabel.font = UIFont(name: "Ubuntu-Bold", size: 20)
        view.addSubview(forlabel)
        
        requestPrice.frame = CGRect(x: forlabel.frame.origin.x+forlabel.frame.width, y: needslabel.frame.origin.y+needslabel.frame.size.height, width: 70, height: 30)
        requestPrice.textColor = UIColor.darkGray
        requestPrice.font = UIFont(name: "Ubuntu-Bold", size: 20)
        view.addSubview(requestPrice)
        
        inlabel.frame = CGRect(x: 50, y: forlabel.frame.origin.y+forlabel.frame.size.height, width: 30, height: 30)
        inlabel.textColor = UIColor.lightGray
        inlabel.font = UIFont(name: "Ubuntu-Bold", size: 20)
        view.addSubview(inlabel)
        
        timeLabel.frame = CGRect(x: inlabel.frame.origin.x+inlabel.frame.width, y: forlabel.frame.origin.y+forlabel.frame.size.height, width: 250, height: 30)
        timeLabel.textColor = UIColor.darkGray
        timeLabel.font = UIFont(name: "Ubuntu-Bold", size: 20)
        view.addSubview(timeLabel)
        
        distanceLabel.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+20, y: nameLabel.frame.origin.y+nameLabel.frame.height, width: 100, height: 30)
        distanceLabel.textColor = UIColor.lightGray
        distanceLabel.font = UIFont(name: "Ubuntu", size: 20)
        view.addSubview(distanceLabel)
        
        self.isButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func isButton() {
        if let navController = self.parent as! UINavigationController? {
            let parentVCIndex = navController.viewControllers.count - 2
            if navController.viewControllers[parentVCIndex] is HomePageViewController {
                self.proffrButton = UIButton(frame: CGRect(x: 40, y: inlabel.frame.height+inlabel.frame.origin.y+20, width: self.view.frame.width-80, height: 40))
                proffrButton.addTarget(self, action: #selector(self.createProffr(_:)), for: .touchUpInside)
                proffrButton.layer.backgroundColor = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1).cgColor
                proffrButton.layer.cornerRadius = 5
                proffrButton.setTitle("Proffr", for: .normal)
                
                proffrButton.layer.shouldRasterize = true
                proffrButton.layer.shadowColor = UIColor.black.cgColor
                proffrButton.layer.shadowOpacity = 1
                proffrButton.layer.shadowOffset = CGSize.zero
                proffrButton.layer.shadowRadius = 1
                view.addSubview(proffrButton)
            }
        }
    }
    
    // MARK: - Navigation
    
    func createProffr(_ sender: UIButton) {
        
        let nextViewController: NewProffrViewController = NewProffrViewController()
        
        nextViewController.request = self.request
        nextViewController.senderDisplayName = myDisplayName
        nextViewController.senderId = myUserId
        nextViewController.myPhotoUrl = myPhotoUrl
        navigationController?.pushViewController(nextViewController,
                                                 animated: true)
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
