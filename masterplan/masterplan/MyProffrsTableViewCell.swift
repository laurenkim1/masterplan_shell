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
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
