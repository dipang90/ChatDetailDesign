//
//  sendTableViewCell.swift
//  ChatDetailDesign
//
//  Created by Dipang Shetn on 14/08/17.
//  Copyright © 2017 Dipang iOS. All rights reserved.
//

import UIKit

class sendTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var txtvMsg: UITextView!
    @IBOutlet weak var viewSender: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code 
        
        self.viewSender.layer.masksToBounds = true
        self.viewSender.layer.cornerRadius = 5.0
        txtvMsg.isEditable = false
        txtvMsg.isScrollEnabled = false
        let padding = txtvMsg.textContainer.lineFragmentPadding
        txtvMsg.textContainerInset = UIEdgeInsetsMake(0, -padding, 0, -padding) //top, left, bottom, right
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
