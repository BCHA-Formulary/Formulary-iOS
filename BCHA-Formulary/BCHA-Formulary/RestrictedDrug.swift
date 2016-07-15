//
//  RestrictedDrug.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-07-11.
//  Copyright © 2016 BCHA. All rights reserved.
//

import Foundation

class RestrictedDrug: DrugBase {
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

}