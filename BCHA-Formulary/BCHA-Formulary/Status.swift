//
//  Status.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-07-11.
//  Copyright © 2016 BCHA. All rights reserved.
//

import Foundation

//WARNING these strings are formatted to be the same as the nodes for firebase retrieval of the drug list
//Do not change without refactoring firebase child
enum Status : String{
    case FORMULARY = "Formulary"
    case EXCLUDED = "Excluded"
    case RESTRICTED = "Restricted"
}