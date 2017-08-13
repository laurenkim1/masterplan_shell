//
//  NotificationsTableViewCell.swift
//  masterplan
//
//  Created by Lauren Kim on 8/6/17.
//  Copyright © 2017 Lauren Kim. All rights reserved.
//

import UIKit
import EasyPeasy
import Neon

class NotificationsTableViewCell: UITableViewCell {
    
    //MARK: Properties
    //var requesterName: UILabel!
    //var requestTitle: UILabel!
    //var requestPrice: UILabel!
    
    fileprivate let padding: CGFloat = 2.0
    var CellHeight = CGFloat()
    
    lazy var requesterName: UILabel = {
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
    
    var ProfilePhoto : UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        CellHeight = 85
        
        ProfilePhoto = UIImageView()
        ProfilePhoto.frame = CGRect(x: 20, y: CellHeight/2-20, width: 50, height: 50)
        ProfilePhoto.layer.borderWidth = 1
        ProfilePhoto.layer.masksToBounds = false
        ProfilePhoto.layer.borderColor = UIColor.green.cgColor
        ProfilePhoto.layer.cornerRadius = ProfilePhoto.frame.height/2
        ProfilePhoto.clipsToBounds = true
        contentView.addSubview(ProfilePhoto)
        
        requesterName.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10 , y: 10, width: 100, height: CellHeight/2-10)
        requesterName.textColor = UIColor.black
        contentView.addSubview(requesterName)
        
        requestTitle.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10, y: requesterName.frame.origin.y+requesterName.frame.size.height+10, width: 100, height: CellHeight/2-10)
        requestTitle.textColor = UIColor.black
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
