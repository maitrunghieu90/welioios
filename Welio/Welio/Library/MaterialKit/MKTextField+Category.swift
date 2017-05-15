//
//  MKTextField+Category.swift
//  Birth Announcement
//
//  Copyright © 2016 Birth Announcement. All rights reserved.
//

import Foundation
import UIKit

extension MKTextField {
    
    func configureTextField(){
        self.layer.borderColor = UIColor.clear.cgColor
        self.floatingPlaceholderEnabled = true
        self.tintColor = UIColor(red: 135/255 , green: 135/255, blue: 135/255, alpha: 1.0)
        self.rippleLocation = .right
        self.cornerRadius = 0
        self.bottomBorderEnabled = true
    }
}
