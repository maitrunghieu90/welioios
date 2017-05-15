//
//  CellChat.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/28/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class CellChat: UITableViewCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var imBg: UIImageView!
    @IBOutlet weak var tvMessage: UITextView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var ctrWidthTvMessage: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
