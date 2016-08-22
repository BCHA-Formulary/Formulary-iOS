//
//  NoDrugResultViewController.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-08-21.
//  Copyright © 2016 BCHA. All rights reserved.
//

import Foundation
import UIKit

public class NoDrugResultViewController:UIViewController{
    var drugName:String!
    
    @IBOutlet weak var drugNameTitle: UILabel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "DRUG NOT FOUND"
        drugNameTitle.text = "Sorry, " + drugName + " was not found."
    }
}