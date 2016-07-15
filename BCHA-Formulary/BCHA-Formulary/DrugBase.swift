//
//  DrugBase.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-07-11.
//  Copyright © 2016 BCHA. All rights reserved.
//

import Foundation

class DrugBase{
    var drugClass = [String]()
    var status:Status
    
    init(drugClass:String, status:Status){
        self.drugClass.append(drugClass)
        self.status = status
    }
    
    init(drugClass:[String], status:Status){
        self.drugClass = drugClass
        self.status = status
    }
}