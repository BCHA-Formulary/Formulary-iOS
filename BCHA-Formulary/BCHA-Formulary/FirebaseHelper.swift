//
//  FirebaseHelper.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-07-12.
//  Copyright © 2016 BCHA. All rights reserved.
//

import Foundation
import SystemConfiguration
import Firebase
/**
 * Based on the enum of status, there are 3 possible nodes from firebase that the drugs could be
 * retrieved. Firebase listener FIRDataEventTypeChildAdded will retrieve the drug objects
 * which we can parse and add to a drug list to be returned
 */

struct FirebaseHelper {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    init(){
    }
    
    func isUpToDate(view:UIView, spinner:UIActivityIndicatorView, sql:SqlHelper) {
        
        let lastUpdated = defaults.stringForKey("lastUpdated")
        //HACK should not be doing view things here...
        view.hidden = false
        spinner.hidden = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        //create a callback as a continue with for when firebase update returns
        let closure:(snapshot:FIRDataSnapshot)-> Void = {(snapshot) in
            print(snapshot.value)
            let dateNum = snapshot.value as! NSNumber as Double
            let lastFirebaseUpdateDate = String(format: "%f", dateNum)
            if(lastUpdated == lastFirebaseUpdateDate){
                spinner.stopAnimating()
                view.hidden = true
                return
            }
            else{
                sql.dropAndRemakeTables() //TODO needed?
                FirebaseHelper.updateFirebaseDrugList(Status.FORMULARY, view:view, spinner: spinner) //controls spinner
                FirebaseHelper.updateFirebaseDrugList(Status.EXCLUDED, view:view, spinner: spinner)
                FirebaseHelper.updateFirebaseDrugList(Status.RESTRICTED, view:view, spinner: spinner)
                self.defaults.setObject(lastFirebaseUpdateDate, forKey: "lastUpdated")
            }
        }
        getFirebaseLastUpdate(closure)
    }
    
    
    
    private func getFirebaseLastUpdate(closure:(snapshot:FIRDataSnapshot)-> Void){
        let ref = FIRDatabase.database().reference()
        ref.child("Update").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            closure(snapshot: snapshot)
        })
    }
    
    static func updateFirebaseDrugList(drugList:Status, view:UIView, spinner:UIActivityIndicatorView){
        let sql:SqlHelper = SqlHelper.init()
        
        let ref = FIRDatabase.database().reference()
//        
//        print("Before firebase update")
//        sql.rowCount()
        
        //HACK we are assuming formulary takes the longest
        ref.child(drugList.rawValue).observeEventType(.Value, withBlock: {(snapshot) in
            print("Done retrieving " + drugList.rawValue)
            if(drugList == Status.FORMULARY){
                sql.rowCount()
                spinner.stopAnimating()
                view.hidden = true
            }
        })
        
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
    
    static func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .Reachable
        let needsConnection = flags == .ConnectionRequired
        
        return isReachable && !needsConnection
        
    }
}
