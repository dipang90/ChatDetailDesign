//
//  receiverTableViewCell.swift
//  ChatDetailDesign
//
//  Created by Dipang Shetn on 14/08/17.
//  Copyright © 2017 Dipang iOS. All rights reserved.
//

import UIKit

class receiverTableViewCell: UITableViewCell {

    @IBOutlet weak var IBImageMessageStatus: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var txtvMsg: UITextView!
    @IBOutlet weak var viewReceiver: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.viewReceiver.layer.masksToBounds = true
        self.viewReceiver.layer.cornerRadius = 5.0
        txtvMsg.isEditable = false
        txtvMsg.isScrollEnabled = false
        let padding = txtvMsg.textContainer.lineFragmentPadding
        txtvMsg.textContainerInset = UIEdgeInsetsMake(0, -padding, 0, -padding)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
