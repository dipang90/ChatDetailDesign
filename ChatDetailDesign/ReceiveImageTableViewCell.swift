//
//  ReceiveImageTableViewCell.swift
//  ChatDetailDesign
//
//  Created by Dipang Shetn on 19/08/17.
//  Copyright © 2017 Dipang iOS. All rights reserved.
//

import UIKit

class ReceiveImageTableViewCell: UITableViewCell {

    @IBOutlet weak var IBimgStatus: UIImageView!
    @IBOutlet weak var IBimageReceiver: UIImageView!
    @IBOutlet weak var IBlblDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
