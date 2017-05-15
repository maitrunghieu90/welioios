//
//  CellAppointment.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/13/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class CellAppointment: UITableViewCell {
    @IBOutlet weak var lbDay: UILabel!
    @IBOutlet weak var lbMonth: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbPatient: UILabel!
    @IBOutlet weak var lbName: MarqueeLabel!
    @IBOutlet weak var lbNumber: UILabel!
    @IBOutlet weak var viewNumber: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
