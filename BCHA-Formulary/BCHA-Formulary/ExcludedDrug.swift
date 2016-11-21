//
//  ExcludedDrug.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-07-11.
//  Copyright © 2016 BCHA. All rights reserved.
//

import Foundation
import SwiftyJSON

class ExcludedDrug:DrugBase{
    var primaryName:String
    var nameType:NameType
    var alternateName = [String]()
    var criteria:String
    
    init(primaryName:String, nameType:NameType, alternateName:[String], criteria:String, status:Status, drugClass:String){
        self.primaryName = primaryName
        self.nameType = nameType
        self.alternateName = alternateName
        self.criteria = criteria
        super.init(drugClass: drugClass, status: status)
    }
    
    init(primaryName:String, nameType:NameType, alternateName:String, criteria:String, status:Status, drugClass:String){
        self.primaryName = primaryName
        self.nameType = nameType
        self.alternateName.append(alternateName)
        self.criteria = criteria
        super.init(drugClass: drugClass, status: status)
    }
    
    init(primaryName:String, nameType:NameType, alternateName:[String], criteria:String, status:Status, drugClass:[String]){
        self.primaryName = primaryName
        self.nameType = nameType
        self.alternateName = alternateName
        self.criteria = criteria
        super.init(drugClass: drugClass, status: status)
    }
    
    init(json:JSON){
        self.primaryName = json["primaryName"].stringValue
        self.alternateName = json["alternateName"].arrayObject as! [String]
        self.criteria = json["criteria"].stringValue
        
        if(json["nameType"].stringValue=="GENERIC"){
            self.nameType = NameType.GENERIC
        }
        else{
            self.nameType = NameType.BRAND
        }
        
        var drugStatus:Status
        if(json["status"].stringValue == "FORMULARY"){
            drugStatus = Status.FORMULARY
        }
        else if(json["status"].stringValue == "EXCLUDED"){
            drugStatus = Status.EXCLUDED
        }
        else{
            drugStatus = Status.RESTRICTED
        }
        
        super.init(drugClass: json["drugClass"].arrayObject as! [String], status: drugStatus)
    }
}
