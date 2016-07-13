//
//  ViewController.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-02-18.
//  Copyright © 2016 BCHA. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchBttn: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    var firebase:FirebaseHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        firebase = FirebaseHelper.init()
        firebase.getFirebaseLastUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func searchDrug(sender: UIButton) {
//        retrieveFirebaseDrugList(Status.FORMULARY)
        FirebaseHelper.retrieveFirebaseDrugList(Status.EXCLUDED)
    }

    @IBAction func helpScreen(sender: AnyObject) {
        FirebaseHelper.init().isUpToDate()
    }
}

