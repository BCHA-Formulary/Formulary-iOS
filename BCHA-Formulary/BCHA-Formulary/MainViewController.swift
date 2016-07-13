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
        retrieveFirebaseDrugList(Status.FORMULARY)
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
        
        let ref = FIRDatabase.database().reference()
        ref.child(drugList.rawValue).observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let drug = snapshot.value as! [String : AnyObject]
//            
            switch drugList {
            case Status.FORMULARY:
                let drugNameType = NameType(rawValue: drug["nameType"] as! String)
                let altName = drug["alternateName"] as! NSArray as! [String]
                let drugClass = drug["drugClass"] as! NSArray as! [String]
                let strengths = drug["strengths"] as! NSArray as! [String]
                
                let formularyDrug = FormuarlyDrug(primaryName: drug["primaryName"] as! String, nameType: drugNameType!, alternateName: altName, strengths: strengths, status: Status.FORMULARY, drugClass: drugClass)
                
                drugsFromFirebase.append(formularyDrug)
                print("Drug list count: ", drugsFromFirebase.count)
                break
            case Status.EXCLUDED:
                let drugNameType = NameType(rawValue: drug["nameType"] as! String)
                let status = Status.EXCLUDED
                let altName = drug["alternateName"] as! NSArray as! [String]
                let drugClass = drug["drugClass"] as! NSArray as! [String]
                
                let excludedDrug = ExcludedDrug(primaryName: drug["primaryName"] as! String, nameType: drugNameType!, alternateName: altName, criteria: drug["criteria"] as! String, status: status, drugClass: drugClass)
                
                drugsFromFirebase.append(excludedDrug)
                print("Drug list count: ", drugsFromFirebase.count)
                break
            case Status.RESTRICTED:
                let drugNameType = NameType(rawValue: drug["nameType"] as! String)
                let status = Status.RESTRICTED
                let altName = drug["alternateName"] as! NSArray as! [String]
                let drugClass = drug["drugClass"] as! NSArray as! [String]
                
                let restrictedDrug = RestrictedDrug(primaryName: drug["primaryName"] as! String, nameType: drugNameType!, alternateName: altName, criteria: drug["criteria"] as! String, status: status, drugClass: drugClass)
                
                drugsFromFirebase.append(restrictedDrug)
                print("Drug list count: ", drugsFromFirebase.count)
                break
            }
        })
        return drugsFromFirebase
    }
}

