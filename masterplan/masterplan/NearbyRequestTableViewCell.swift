//
//  nearbyRequestTableViewCell.swift
//  masterplan
//
//  Created by Lauren Kim on 7/15/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import EasyPeasy
import Neon

class NearbyRequestTableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    fileprivate let padding: CGFloat = 2.0
    var CellHeight = CGFloat()
    var ProfilePhoto : UIImageView!
    
    let needslabel: UILabel = UILabel()
    let forlabel: UILabel = UILabel()
    let inlabel: UILabel = UILabel()
    let hourslabel: UILabel = UILabel()
    
    lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 17)
        view.textColor = .darkText
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy var requestPrice: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 17)
        view.textColor = .darkText
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy var requestTitle: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 17)
        view.textColor = .darkText
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy var distanceLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 17)
        view.textColor = .darkText
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy var timeLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 17)
        view.textColor = .darkText
        self.contentView.addSubview(view)
        return view
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        CellHeight = 80
        
        ProfilePhoto = UIImageView()
        ProfilePhoto.frame = CGRect(x: 20, y: CellHeight/2-30, width: 60, height: 60)
        ProfilePhoto.layer.borderWidth = 1
        ProfilePhoto.layer.masksToBounds = false
        ProfilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        ProfilePhoto.layer.cornerRadius = ProfilePhoto.frame.height/2
        ProfilePhoto.clipsToBounds = true
        contentView.addSubview(ProfilePhoto)
        
        needslabel.text = "needs:"
        forlabel.text = "for"
        inlabel.text = "in"
        hourslabel.text = "hrs"
        
        nameLabel.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10 , y: 5, width: 200, height: CellHeight/3)
        nameLabel.textColor = UIColor.darkGray
        nameLabel.font = UIFont(name: "Ubuntu-Bold", size: 20)
        contentView.addSubview(nameLabel)
        
        needslabel.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10 , y: nameLabel.frame.origin.y+nameLabel.frame.size.height-5, width: 60, height: CellHeight/3)
        contentView.addSubview(needslabel)
        
        requestTitle.frame = CGRect(x: needslabel.frame.origin.x+ProfilePhoto.frame.width, y: nameLabel.frame.origin.y+nameLabel.frame.size.height-5, width: 200, height: CellHeight/3)
        requestTitle.textColor = UIColor.darkGray
        requestTitle.font = UIFont(name: "Ubuntu-Bold", size: 16)
        contentView.addSubview(requestTitle)
        
        forlabel.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10, y: needslabel.frame.origin.y+needslabel.frame.size.height-5, width: 30, height: CellHeight/3)
        contentView.addSubview(forlabel)
        
        requestPrice.frame = CGRect(x: forlabel.frame.origin.x+forlabel.frame.width, y: needslabel.frame.origin.y+needslabel.frame.size.height-5, width: 70, height: CellHeight/3)
        requestPrice.textColor = UIColor.darkGray
        requestPrice.font = UIFont(name: "Ubuntu-Bold", size: 16)
        contentView.addSubview(requestPrice)
        
        inlabel.frame = CGRect(x: requestPrice.frame.origin.x+requestPrice.frame.width, y: needslabel.frame.origin.y+needslabel.frame.size.height-5, width: 20, height: CellHeight/3)
        contentView.addSubview(inlabel)
        
        timeLabel.frame = CGRect(x: inlabel.frame.origin.x+inlabel.frame.width, y: needslabel.frame.origin.y+needslabel.frame.size.height-5, width: 30, height: CellHeight/3)
        timeLabel.textColor = UIColor.darkGray
        timeLabel.font = UIFont(name: "Ubuntu-Bold", size: 16)
        contentView.addSubview(timeLabel)
        
        hourslabel.frame = CGRect(x: timeLabel.frame.origin.x+timeLabel.frame.width, y: needslabel.frame.origin.y+needslabel.frame.size.height-5, width: 50, height: CellHeight/3)
        contentView.addSubview(hourslabel)
        
        distanceLabel.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10+nameLabel.frame.width, y: 5, width: 100, height: CellHeight/3)
        distanceLabel.textColor = UIColor.black
        contentView.addSubview(distanceLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
