//
//  ViewController.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-02-18.
//  Copyright © 2016 BCHA. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController, MPGTextFieldDelegate {

    @IBOutlet weak var searchField: MPGTextField_Swift!
    @IBOutlet weak var searchBttn: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    var firebase:FirebaseHelper!
    var sql:SqlHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        firebase = FirebaseHelper.init()
        if(firebase.isUpToDate()){ //TODO this should be !isUpToDate, to save calls for now, set to opposite
            print("Needs update")
            FirebaseHelper.updateFirebaseDrugList(Status.FORMULARY)
            FirebaseHelper.updateFirebaseDrugList(Status.EXCLUDED)
            FirebaseHelper.updateFirebaseDrugList(Status.RESTRICTED)
        }
        sql = SqlHelper.init()
        searchField.mDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
    
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>]
    {
        var sampleData = [Dictionary<String, AnyObject>]()
        let drugNames = sql.getAllDrugNames()
        for name in drugNames{
            let dictionary = ["DisplayText":name, "DisplaySubText":"", "CustomObject":""]
            sampleData.append(dictionary)
        }
        return sampleData
    }
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool{
        return true
    }
    
    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String,AnyObject>){
        print("Dictionary received = \(data)")
    }
}

