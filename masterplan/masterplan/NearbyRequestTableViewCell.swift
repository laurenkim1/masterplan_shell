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
        
        needslabel.text = "needs 1"
        forlabel.text = "for"
        inlabel.text = "in"
        hourslabel.text = "hrs"
        
        nameLabel.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10 , y: 10, width: 100, height: CellHeight/2-10)
        nameLabel.textColor = UIColor.black
        contentView.addSubview(nameLabel)
        
        needslabel.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10 , y: nameLabel.frame.origin.y+(nameLabel.frame.size.height / 2)+5 , width: 50, height: CellHeight/2-10)
        
        requestTitle.frame = CGRect(x: needslabel.frame.origin.x+(ProfilePhoto.frame.width / 2)+5, y: nameLabel.frame.origin.y+(nameLabel.frame.size.height / 2)+5, width: 100, height: CellHeight/2-10)
        requestTitle.textColor = UIColor.black
        contentView.addSubview(requestTitle)
        
        forlabel.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+10, y: needslabel.frame.origin.y+(needslabel.frame.size.height / 2)+5, width: 15, height: CellHeight/2-10)
        contentView.addSubview(forlabel)
        
        requestPrice.frame = CGRect(x: forlabel.frame.origin.x+(forlabel.frame.width / 2)+5, y: needslabel.frame.origin.y+(needslabel.frame.size.height / 2)+5, width: 30, height: CellHeight/2-10)
        contentView.addSubview(requestPrice)
        
        inlabel.frame = CGRect(x: requestPrice.frame.origin.x+(requestPrice.frame.width / 2)+5, y: needslabel.frame.origin.y+(needslabel.frame.size.height / 2)+5, width: 10, height: CellHeight/2-10)
        contentView.addSubview(inlabel)
        
        timeLabel.frame = CGRect(x: inlabel.frame.origin.x+(inlabel.frame.width / 2)+5, y: needslabel.frame.origin.y+(needslabel.frame.size.height / 2)+5, width: 10, height: CellHeight/2-10)
        contentView.addSubview(timeLabel)
        
        hourslabel.frame = CGRect(x: timeLabel.frame.origin.x+(timeLabel.frame.width / 2)+5, y: needslabel.frame.origin.y+(needslabel.frame.size.height / 2)+5, width: 10, height: CellHeight/2-10)
        contentView.addSubview(hourslabel)
        
        //distanceLabel.frame = CGRect(x: ProfilePhoto.frame.origin.x+ProfilePhoto.frame.width+110 , y: 10, width: 100, height: CellHeight/2-10)
        //distanceLabel.textColor = UIColor.black
        //contentView.addSubview(distanceLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
