//
//  sendImageTableViewCell.swift
//  ChatDetailDesign
//
//  Created by Binita Modi on 19/08/17.
//  Copyright © 2017 SYNC Technologies. All rights reserved.
//

import UIKit

class sendImageTableViewCell: UITableViewCell {

    @IBOutlet weak var IBlblDate: UILabel!
    @IBOutlet weak var IBimageSender: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        IBimageSender.layer.masksToBounds = true
        IBimageSender.layer.cornerRadius = 5.0
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
