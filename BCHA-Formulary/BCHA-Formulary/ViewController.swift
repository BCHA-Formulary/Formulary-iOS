//
//  ViewController.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-02-18.
//  Copyright © 2016 BCHA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchBttn: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func searchDrug(sender: UIButton) {
//        let drugName = searchField.text
        let request = HttpRequest()
        request.makeGetRequest()
        
    }

    @IBAction func helpScreen(sender: AnyObject) {
    }
}

