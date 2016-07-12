//
//  ViewController.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-02-18.
//  Copyright © 2016 BCHA. All rights reserved.
//

import UIKit
import Firebase

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
//        let request = HttpRequest()
//        request.makeGetRequest()
        retrieveFirebaseDrugList(Status.EXCLUDED)
    }

    @IBAction func helpScreen(sender: AnyObject) {
        let ref = FIRDatabase.database().reference()
        ref.child("Update").observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            // Get user value
//            let username = snapshot.value!["username"] as! String
//            let user = User.init(username: username)
            print(snapshot)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func retrieveFirebaseDrugList(drugList:Status)->[DrugBase]{
        var drugsFromFirebase = [DrugBase]()
        
        var childNode:String
        switch drugList {
        case Status.FORMULARY:
            childNode = "Formulary"
            break
        case Status.EXCLUDED:
            childNode = "Excluded"
            break
        case Status.RESTRUCTED:
            childNode = "Restructed"
        }
        
        let ref = FIRDatabase.database().reference()
        ref.child(childNode).observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let drug = snapshot.value as! [String : AnyObject]
//            
            switch drugList {
            case Status.FORMULARY:
                //TODO
                break
            case Status.EXCLUDED:
//                var nameType:NameType = NameType.GENERIC //temp HACK for testing
//                if(drug["nameType"] == "GENERIC"){
//                    nameType = NameType.GENERIC
//                }
//                else{
//                    NameType = NameType.BRAND
//                }
                
//                let excludedDrug = ExcludedDrug(primaryName: drug["primaryName"], nameType: nameType, alternateName: drug["alternateName"] as! Array, criteria: drug["criteria"], status: drug["status"], drugClass: drug["drugClass"] as! Array)
                let drugNameType = NameType(rawValue: drug["nameType"] as! String)
                let status = Status.EXCLUDED
                let altName = drug["alternateName"] as! NSArray as! [String]
                let dClass = drug["drugClass"] as! NSArray as! [String]
                
                let excludedDrug = ExcludedDrug(primaryName: drug["primaryName"] as! String, nameType: drugNameType!, alternateName: altName, criteria: drug["criteria"] as! String, status: status, drugClass: dClass)
                
                drugsFromFirebase.append(excludedDrug)
                print("Drug list count: ", drugsFromFirebase.count)
                break
            case Status.RESTRUCTED:
                //TODO
                break
            }
            
//            let name = drug["primaryName"]
//            print(name)
//            let altNames = drug["alternateName"] as! NSArray
//            for name in altNames{
//                print(name)
//            }
//            print(drug["alternateName"])
            })
        return drugsFromFirebase
    }
}

