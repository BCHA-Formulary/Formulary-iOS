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
import SwiftyJSON

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
//            print(snapshot.value)
            let lastFirebaseUpdateDate = snapshot.value as! String
            if(lastUpdated == lastFirebaseUpdateDate){
                spinner.stopAnimating()
                view.hidden = true
                return
            }
            else{
                sql.dropAndRemakeTables() //TODO needed?
                FirebaseHelper.updateFirebaseDrugsFromJSONString(Status.FORMULARY)
                FirebaseHelper.updateFirebaseDrugsFromJSONString(Status.EXCLUDED)
                FirebaseHelper.updateFirebaseDrugsFromJSONString(Status.RESTRICTED)
                self.defaults.setObject(lastFirebaseUpdateDate, forKey: "lastUpdated")
                self.completedUpdate(view, spinner: spinner)
            }
        }
        getFirebaseLastUpdate(closure)
    }
    
    // In Firebase, child event listeners (async) are known to complete before single event
    // value listeners are triggers. Calling the single event ensures that its callback method
    // occures after all the updates (child event listeners) are returned first
    func completedUpdate(view:UIView, spinner:UIActivityIndicatorView){
        let ref = FIRDatabase.database().reference()
        ref.child("Update").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            spinner.stopAnimating()
            view.hidden = true
        })
    }
    
    static func updateFirebaseDrugsFromJSONString(drugList:Status){
        let sql:SqlHelper = SqlHelper.init()
        
        let ref = FIRDatabase.database().reference()
        var childString:String
        if(drugList == Status.FORMULARY){
            childString = "FormularyString"
        }
        else if(drugList == Status.EXCLUDED){
            childString = "ExcludedString"
        }
        else{
            childString = "RestrictedString"
        }
        
        ref.child(childString).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let value = snapshot.value as! String
            do{
                if let dataFromString = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                    let arrayLength = json.arrayValue.count
                    
                    for index in 0...arrayLength-1 {
                        let drugJSON = json[index]
                        if(drugList == Status.FORMULARY){
                            let drug = FormuarlyDrug.init(json: drugJSON)
                            if(drug.nameType == NameType.GENERIC){
                                sql.insertFormularyGenericDrug(drug)
                            }
                            else{
                                sql.insertFormularyBrandDrug(drug)
                            }
                        }
                        else if(drugList == Status.EXCLUDED){
                            let drug = ExcludedDrug.init(json: drugJSON)
                            if(drug.nameType == NameType.GENERIC){
                                sql.insertExcludedGenericDrug(drug)
                            }
                        }
                        else{
                            let drug = RestrictedDrug.init(json: drugJSON)
                            if(drug.nameType == NameType.GENERIC){
                                sql.insertRestrictedGenericDrug(drug)
                            }
                        }
                    }
                }
            }
        })
    }
    
    
    
    private func getFirebaseLastUpdate(closure:(snapshot:FIRDataSnapshot)-> Void){
        let ref = FIRDatabase.database().reference()
        ref.child("Update").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            closure(snapshot: snapshot)
        })
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
