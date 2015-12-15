//
//  TimelineTableViewCell.swift
//  SoundByte
//
//  Created by Jeff Cohen on 12/14/15.
//  Copyright (c) 2015 Jeff Cohen. All rights reserved.
//

import UIKit

class TimelineTableViewCell: UITableViewCell {


    @IBOutlet weak var usernameLabel: UILabel!
    var user: PFUser?{
        didSet {
           // usernameLabel.text = //usernameLabel.text = user?.username
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
