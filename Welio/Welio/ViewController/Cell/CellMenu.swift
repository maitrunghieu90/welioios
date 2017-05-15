//
//  MenuCell.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/28/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class CellMenu: UITableViewCell {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var imIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
