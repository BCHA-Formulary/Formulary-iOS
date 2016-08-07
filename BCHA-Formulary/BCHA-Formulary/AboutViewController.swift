//
//  AboutViewController.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-08-07.
//  Copyright © 2016 BCHA. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController : UIViewController{
    
    //@IBOutlet weak var emailSupportLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About This App"
        
        //let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapResponse:")
        //tapGesture.numberOfTapsRequired = 1
        //emailSupportLabel.userInteractionEnabled =  true
        //emailSupportLabel.addGestureRecognizer(tapGesture)
    }
    
    func tapResponse(recognizer: UITapGestureRecognizer) {
        print("tap")
    }
    
}
