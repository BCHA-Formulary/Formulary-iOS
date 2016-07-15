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
        if(!firebase.isUpToDate()){ //TODO this should be !isUpToDate, to save calls for now, set to opposite
            print("Needs update")
            FirebaseHelper.updateFirebaseDrugList(Status.FORMULARY)
            FirebaseHelper.updateFirebaseDrugList(Status.EXCLUDED)
            FirebaseHelper.updateFirebaseDrugList(Status.RESTRICTED)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func searchDrug(sender: UIButton) {
//        retrieveFirebaseDrugList(Status.FORMULARY)
//        FirebaseHelper.updateFirebaseDrugList(Status.EXCLUDED)
//        SqlHelper.init().dropAndRemakeTables()
        let list = SqlHelper.init().getAllDrugNames()
        for name in list{
            print(name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
        }
    }

    @IBAction func helpScreen(sender: AnyObject) {
//        FirebaseHelper.init().isUpToDate()
        SqlHelper.init().rowCount()
    }
}

