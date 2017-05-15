//
//  TermsVC.swift
//  Welio
//
//  Created by Pham Khanh Hoa on 4/13/17.
//  Copyright © 2017 SDC. All rights reserved.
//

import UIKit

class TermsVC: UIViewController {
    @IBOutlet weak var tvTerm: UITextView!
    @IBOutlet weak var btDone: UIButton!
    @IBOutlet weak var lbTitleNav: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionDone(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
