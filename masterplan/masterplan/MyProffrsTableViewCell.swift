//
//  MyProffrsTableViewCell.swift
//  masterplan
//
//  Created by Lauren Kim on 7/28/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit

class MyProffrsTableViewCell: UITableViewCell {
    
    //MARK: Properties
    fileprivate let padding: CGFloat = 2.0
    var CellHeight = CGFloat()
    
    lazy var senderLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.textColor = UIColor.darkGray
        view.font = UIFont(name: "Ubuntu-Bold", size: 20)
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy var subTitle: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textAlignment = .left
        view.textColor = UIColor.darkGray
        view.font = UIFont(name: "Ubuntu-Bold", size: 16)
        self.contentView.addSubview(view)
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
        contentView.addSubview(ProfilePhoto)
        
        senderLabel.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10 , y: 10, width: 200, height: CellHeight/2-10)
        contentView.addSubview(senderLabel)
        
        let forlabel = UILabel(frame: CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10, y: senderLabel.frame.origin.y+senderLabel.frame.size.height, width: 40, height: CellHeight/2-10))
        forlabel.text = "For:"
        forlabel.textColor = UIColor.lightGray
        forlabel.font = UIFont(name: "Ubuntu-Bold", size: 16)
        contentView.addSubview(forlabel)
        
        subTitle.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10+forlabel.frame.width, y: senderLabel.frame.origin.y+senderLabel.frame.size.height, width: 100, height: CellHeight/2-10)
        contentView.addSubview(subTitle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
