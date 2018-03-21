//
//  ChatUserTableViewCell.swift
//  ChatDetailDesign
//
//  Created by Binita Modi on 31/08/17.
//  Copyright © 2017 SYNC Technologies. All rights reserved.
//

import UIKit

class ChatUserTableViewCell: UITableViewCell {

    @IBOutlet weak var imgSendStatus: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblContact: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.layer.cornerRadius = 20
        lblTitle.layer.masksToBounds = true
        
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = self.lblTitle.backgroundColor
        super.setSelected(selected, animated: animated)
        self.lblTitle.backgroundColor = color
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = self.lblTitle.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        self.lblTitle.backgroundColor = color
    }

    
}
