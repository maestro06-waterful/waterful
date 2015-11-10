//
//  WaterLogTableViewCell.swift
//  waterful
//
//  Created by HONGYOONSEOK on 2015. 11. 5..
//  Copyright © 2015년 suz. All rights reserved.
//

import UIKit

class WaterLogTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var label_logDate: UILabel!

    @IBOutlet weak var label_logCount: UILabel!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
