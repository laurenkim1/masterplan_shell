//
//  NotificationsTableViewCell.swift
//  masterplan
//
//  Created by Lauren Kim on 8/6/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit

class NotificationsTableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    fileprivate let padding: CGFloat = 2.0
    var CellHeight = CGFloat()
    let acceptlabel: UILabel = UILabel()
    
    lazy var requesterName: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.textColor = UIColor.darkGray
        view.font = UIFont(name: "Ubuntu-Bold", size: 20)
        return view
    }()
    
    lazy var requestTitle: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.textColor = UIColor.darkGray
        view.font = UIFont(name: "Ubuntu-Bold", size: 16)
        return view
    }()
    
    lazy var timeLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .right
        return view
    }()
    
    var ProfilePhoto : UIImageView!
    
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
        ProfilePhoto.contentMode = UIViewContentMode.scaleAspectFill
        contentView.addSubview(ProfilePhoto)
        
        requesterName.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10 , y: 5, width: 160, height: CellHeight/3)
        contentView.addSubview(requesterName)
        
        acceptlabel.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10 , y: requesterName.frame.origin.y+requesterName.frame.size.height-5, width: 200, height: CellHeight/3)
        acceptlabel.text = "accepted your Proffr for:"
        acceptlabel.textColor = UIColor.lightGray
        acceptlabel.font = UIFont(name: "Ubuntu-Bold", size: 16)
        contentView.addSubview(acceptlabel)
        
        timeLabel.frame = CGRect(x: self.bounds.maxX-120, y: 5, width: 120, height: CellHeight/3)
        timeLabel.textColor = UIColor.darkGray
        timeLabel.font = UIFont(name: "Ubuntu-Bold", size: 16)
        contentView.addSubview(timeLabel)
        
        requestTitle.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10, y: acceptlabel.frame.origin.y+acceptlabel.frame.size.height-5, width: 200, height: CellHeight/3)
        contentView.addSubview(requestTitle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
