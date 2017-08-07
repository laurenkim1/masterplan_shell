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
    @IBOutlet weak var requesterName: UILabel!
    @IBOutlet weak var requestTitle: UILabel!
    @IBOutlet weak var requestPrice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
