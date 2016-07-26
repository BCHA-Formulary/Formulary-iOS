//
//  FirebaseHelper.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-07-12.
//  Copyright © 2016 BCHA. All rights reserved.
//

import Foundation
import Firebase
/**
 * Based on the enum of status, there are 3 possible nodes from firebase that the drugs could be
 * retrieved. Firebase listener FIRDataEventTypeChildAdded will retrieve the drug objects
 * which we can parse and add to a drug list to be returned
 */

struct FirebaseHelper {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    init(){
        getFirebaseLastUpdate()
    }
    
    func isUpToDate()-> Bool {
//        defaults.setObject(123, forKey: "lastUpdated")
        if let lastUpdated = defaults.stringForKey("lastUpdated"){
            print("Last phone updated: ", lastUpdated)
            return false //TODO for now set to false until figure out how to grab firebase
        }
        return false
    }
    
    private func getFirebaseLastUpdate(){
        let ref = FIRDatabase.database().reference()
        ref.child("Update").observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            print(snapshot.value)
            // Get user value
            //            let username = snapshot.value!["username"] as! String
            //            let user = User.init(username: username)
            let dateNum = snapshot.value as! NSNumber as Double
            print("Firebase last updated: ", dateNum)
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
//    static func retrieveFirebaseDrugList(drugList:Status)->[DrugBase]{
    static func updateFirebaseDrugList(drugList:Status){
//        var drugsFromFirebase = [DrugBase]()
        let sql:SqlHelper = SqlHelper.init()
        
        let ref = FIRDatabase.database().reference()
        ref.child(drugList.rawValue).observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let drug = snapshot.value as! [String : AnyObject]
            
            let drugNameType = NameType(rawValue: drug["nameType"] as! String)
            let altName = drug["alternateName"] as! NSArray as! [String]
            let drugClass = drug["drugClass"] as! NSArray as! [String]
            switch drugList {
            case Status.FORMULARY:
                let strengths = drug["strengths"] as! NSArray as! [String]
                
                let formularyDrug = FormuarlyDrug(primaryName: drug["primaryName"] as! String, nameType: drugNameType!, alternateName: altName, strengths: strengths, status: Status.FORMULARY, drugClass: drugClass)
                
//                drugsFromFirebase.append(formularyDrug)

                if(formularyDrug.nameType == NameType.GENERIC){
                    sql.insertFormularyGenericDrug(formularyDrug)
                }
//                print("Drug list count: ", drugsFromFirebase.count)
                break
            case Status.EXCLUDED:
                let excludedDrug = ExcludedDrug(primaryName: drug["primaryName"] as! String, nameType: drugNameType!, alternateName: altName, criteria: drug["criteria"] as! String, status: Status.EXCLUDED, drugClass: drugClass)
                
                if(excludedDrug.nameType == NameType.GENERIC){
                    sql.insertExcludedGenericDrug(excludedDrug)
                }
                
//                drugsFromFirebase.append(excludedDrug)
//                print("Drug list count: ", drugsFromFirebase.count)
                break
            case Status.RESTRICTED:
                let restrictedDrug = RestrictedDrug(primaryName: drug["primaryName"] as! String, nameType: drugNameType!, alternateName: altName, criteria: drug["criteria"] as! String, status: Status.RESTRICTED, drugClass: drugClass)
                
//                drugsFromFirebase.append(restrictedDrug)
                
                if(restrictedDrug.nameType == NameType.GENERIC){
                    sql.insertRestrictedGenericDrug(restrictedDrug)
                }
//                print("Drug list count: ", drugsFromFirebase.count)
                break
            }
        })
//        return drugsFromFirebase
    }
}