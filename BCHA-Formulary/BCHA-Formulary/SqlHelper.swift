//
//  SqlHelper.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-07-12.
//  Copyright © 2016 BCHA. All rights reserved.
//
//https://github.com/stephencelis/SQLite.swift sql library
//https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#getting-started
//

import Foundation
import SQLite

struct SqlHelper{
    
    //database
    var db:Connection?
    
    //Table names
    let drugTable = Table("DrugTable")
    let formularyTable = Table("FormularyTable")
    let formularyBrandTable = Table("FormularyBrandTable")
    let excludedTable = Table("ExcludedTable")
    let restrictedTable = Table("RestrictedTable")
    
    //Drug base table fields
    let name = Expression<String>("Name")
    let nameType = Expression<String>("NameType")
    let status = Expression<String>("Status")
    let drugClass = Expression<String>("Class")
    
    //Formulary, Exc, Rest table fields
    let id = Expression<Int64>("id")
    let genericName = Expression<String>("GenericName")
    let brandName = Expression<String>("BrandName")
    let strength = Expression<String>("Strength")
    let criteria = Expression<String>("Criteria")
    
    
    init() {
        db = nil

        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .DocumentDirectory, .UserDomainMask, true
                ).first!
            
            db = try Connection("\(path)/db.sqlite3")
            
            try createDrugTable(db!)
            try createFormularyTable(db!)
            try createFormularyBrandTable(db!)
            try createExcludedTable(db!)
            try createRestrictedTable(db!)
        }
        catch {
            print("Error info: \(error)")
            
        }
    }
    
    /**
        Drops drug,formulary,excluded and restricted table if they exist 
        and then creates them again if needed
     */
    func dropAndRemakeTables(){
        do{
            try db?.run(drugTable.drop(ifExists: true))
            try db?.run(formularyTable.drop(ifExists: true))
            try db?.run(formularyBrandTable.drop(ifExists: true))
            try db?.run(excludedTable.drop(ifExists: true))
            try db?.run(restrictedTable.drop(ifExists: true))
            
            try createDrugTable(db!)
            try createFormularyTable(db!)
            try createFormularyBrandTable(db!)
            try createExcludedTable(db!)
            try createRestrictedTable(db!)
        }
        catch{
            print("Could not drop tables")
        }
    }
    
    //TEST METHOD here as an example
//    func getGeneric(){
//        do{
//            let query = drugTable.filter(name == "SYMBICORT")
//            for drug in try db!.prepare(query){
//                print("Drug: ", drug[name])
//            }
//        }
//        catch{
//            print("Query did not work")
//        }
//    }
    
    func getAllDrugNames()->[String]{
        var drugNames = [String]()
        do{
            for drugName in try db!.prepare(drugTable.select(name)){
                drugNames.append(drugName[name])
            }
        }
        catch{
            print("Error info: \(error)")
        }
        return drugNames
    }
    
    /**
        This method is only called on status:Generic type drugs to avoid duplicates
     */
    func insertFormularyGenericDrug(formulary:FormuarlyDrug){
        if(db == nil) {
            print("ERROR: Database not initalized")
            return
        }
        do{
            let genericTrimName = formulary.primaryName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            try insertDrugIntoTable(genericTrimName,
                                        nameType: NameType.GENERIC.rawValue,
                                        status: Status.FORMULARY.rawValue,
                                        drugClasses: formulary.drugClass)
            
            //insert into formulary table
            for brand in formulary.alternateName{
                let brandTrimName = brand.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                //for each brand name, add the name to the drug table
//                try insertDrugIntoTable(brandTrimName, nameType: NameType.BRAND.rawValue,
//                                        status: Status.FORMULARY.rawValue, drugClasses: formulary.drugClass)
                for strength in formulary.strengths{
                    //for each strength, and each brand name, add to the formulary table
                    try db?.run(formularyTable.insert(genericName<-genericTrimName, brandName<-brandTrimName, self.strength<-strength))
                }
            }
        }
        catch{
//            print("Could not add formulary into drug table: ", formulary.primaryName)
            print("Error info: \(error)")
        }
    }
    
    func insertFormularyBrandDrug(formularyBrand:FormuarlyDrug){
        if(db == nil) {
            print("ERROR: Database not initalized")
            return
        }
        do{
            let brandTrimName = formularyBrand.primaryName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            try insertDrugIntoTable(brandTrimName,
                                    nameType: NameType.BRAND.rawValue,
                                    status: Status.FORMULARY.rawValue,
                                    drugClasses: formularyBrand.drugClass)
            for generic in formularyBrand.alternateName {
                let genericTrimName = generic.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                for strength in formularyBrand.strengths {
                    try db?.run(formularyBrandTable.insert(genericName<-genericTrimName, brandName<-brandTrimName, self.strength<-strength))
                }
            }
        }
        catch{
            print("Error info: \(error)")
        }
    }
    
    func insertExcludedGenericDrug(excluded:ExcludedDrug){
        if(db == nil) {
            print("ERROR: Database not initalized")
            return
        }
        do{
            let genericTrimName = excluded.primaryName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            //insert generic name into drug table
            try insertDrugIntoTable(genericTrimName,
                                    nameType: NameType.GENERIC.rawValue,
                                    status: Status.EXCLUDED.rawValue,
                                    drugClasses: excluded.drugClass)
            
            //insert into excluded table
            for brand in excluded.alternateName{
                let brandTrimName = brand.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                //for each brand name, add the name to the drug table
                try insertDrugIntoTable(brandTrimName, nameType: NameType.BRAND.rawValue,
                                        status: Status.EXCLUDED.rawValue, drugClasses: excluded.drugClass)
                //for each brand name, add to the excluded table
                try db?.run(excludedTable.insert(genericName<-genericTrimName, brandName<-brandTrimName, self.criteria<-excluded.criteria))
            }
        }
        catch{
            print("Could not add excluded into drug table: ", excluded.primaryName)
        }
    }
    
    func insertRestrictedGenericDrug(restricted:RestrictedDrug){
        if(db == nil) {
            print("ERROR: Database not initalized")
            return
        }
        do{
            let genericTrimName = restricted.primaryName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            //insert generic name into drug table
            try insertDrugIntoTable(genericTrimName,
                                    nameType: NameType.GENERIC.rawValue,
                                    status: Status.RESTRICTED.rawValue,
                                    drugClasses: restricted.drugClass)
            
            //insert into Restricted table
            for brand in restricted.alternateName{
                let brandTrimName = brand.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                //for each brand name, add the name to the drug table
                try insertDrugIntoTable(
                    brandTrimName, nameType: NameType.BRAND.rawValue,
                                        status: Status.RESTRICTED.rawValue, drugClasses: restricted.drugClass)
                //for each brand name, add to the restricted table
                try db?.run(restrictedTable.insert(genericName<-genericTrimName, brandName<-brandTrimName, self.criteria<-restricted.criteria))
            }
        }
        catch{
            print("Could not add restricted into drug table: ", restricted.primaryName)
        }
    }
    
    func queryForDrugByName(drugName:String) ->DrugBase?{
        let drugQuery = drugTable.filter(name == drugName.uppercaseString)
        
        do{
            var drugClasses = Set<String>()
            var drugStatus:String = ""
            var drugNameType:String = "" //TODO for now, assume only 1 name type
            for drug in try db!.prepare(drugQuery){
                drugClasses.insert(drug[drugClass])
                if(drugStatus == ""){
                    drugStatus = drug[status]
                }
                if(drugNameType == ""){
                    drugNameType = drug[nameType]
                }
            }
//            let drugStatus = drug[status]
            if(drugStatus == Status.FORMULARY.rawValue){
                let drugReturn = try queryFormularyDrugByName(drugName, formularyNametype: drugNameType, formularyStatus: drugStatus, formularyClass: Array(drugClasses))
                print(drugReturn)
                return drugReturn
            }
            else if(drugStatus == Status.EXCLUDED.rawValue){
                let drugReturn = try queryExcludedDrugByName(drugName, excludedNametype: drugNameType, excludedStatus: drugStatus, excludedClass: Array(drugClasses))
                print(drugReturn)
                return drugReturn
            }
            else if(drugStatus == Status.RESTRICTED.rawValue){
                let drugReturn = try queryRestrictedDrugByName(drugName, restrictedNametype: drugNameType, restrictedStatus: drugStatus, restrictedClass: Array(drugClasses))
                print(drugReturn)
                return drugReturn
            }
        }
        catch{
            print("Error info: \(error)")
        }
        return nil
    }
//
    func queryFormularyDrugByName(formularyDrugName:String, formularyNametype:String, formularyStatus:String, formularyClass:[String]) throws -> FormuarlyDrug{
        
        //query the formulary generic table to see if drug exists
        var drugQuery = formularyTable.filter(genericName == formularyDrugName)

        var altNames = Set<String>()
        var strengths = Set<String>()
//        let isGeneric = (formularyNametype == NameType.GENERIC.rawValue)
        
        var drugSearch = try db!.prepare(drugQuery)
        var drugCount = 0 //HACK - tracks if query drug name is in generic table
        for drug in drugSearch{
            drugCount += 1
            altNames.insert(drug[brandName])
            strengths.insert(drug[strength])
        }
        
        //HACK - if no drugs were found, the drug query must be in the brand name table
        if(drugCount == 0){
            drugQuery = formularyBrandTable.filter(brandName == formularyDrugName)
            drugSearch = try db!.prepare(drugQuery)
            for drug in drugSearch{
                altNames.insert(drug[genericName])
                strengths.insert(drug[strength])
            }
        }
        return FormuarlyDrug.init(primaryName: formularyDrugName, nameType: NameType(rawValue: formularyNametype)!, alternateName:Array(altNames), strengths: Array(strengths),
                                  status: Status(rawValue:formularyStatus)!, drugClass:formularyClass)
    }
    
    func queryExcludedDrugByName(excludedDrugName:String, excludedNametype:String, excludedStatus:String, excludedClass:[String]) throws -> ExcludedDrug {
        let drugQuery = excludedTable.filter(genericName == excludedDrugName || brandName == excludedDrugName)
        var altNames = Set<String>()
        var excludedCriteria:String = ""
        let isGeneric = (excludedNametype == NameType.GENERIC.rawValue)
        for drug in try db!.prepare(drugQuery){
            if (isGeneric){
                altNames.insert(drug[brandName])
            }
            else{
                altNames.insert(drug[genericName])
            }
            if(excludedCriteria == ""){
                excludedCriteria = drug[criteria]
            }
        }
        return ExcludedDrug.init(primaryName: excludedDrugName, nameType: NameType(rawValue: excludedNametype)!,
                                  alternateName:Array(altNames), criteria: excludedCriteria,
                                  status: Status(rawValue:excludedStatus)!, drugClass:excludedClass)
    }
    
    func queryRestrictedDrugByName(restrictedDrugName:String, restrictedNametype:String, restrictedStatus:String, restrictedClass:[String]) throws -> RestrictedDrug {
        let drugQuery = restrictedTable.filter(genericName == restrictedDrugName || brandName == restrictedDrugName)
        var altNames = Set<String>()
        var restrictedCriteria:String = ""
        let isGeneric = (restrictedNametype == NameType.GENERIC.rawValue)
        for drug in try db!.prepare(drugQuery){
            if (isGeneric){
                altNames.insert(drug[brandName])
            }
            else{
                altNames.insert(drug[genericName])
            }
            if(restrictedCriteria == ""){
                restrictedCriteria = drug[criteria]
            }
        }
        return RestrictedDrug.init(primaryName: restrictedDrugName,
                                   nameType: NameType(rawValue: restrictedNametype)!,
                                   alternateName:Array(altNames),
                                   criteria: restrictedCriteria,
                                 status: Status(rawValue:restrictedStatus)!,
                                 drugClass:restrictedClass)
    }
    
    func queryDrugNamesByDrugClass(drugClassName:String) throws -> [String]{
        var drugQueryResult = Set<String>()
        let drugQuery = drugTable.filter(drugClass == drugClassName)
        for drug in try db!.prepare(drugQuery){
            drugQueryResult.insert(drug[name])
        }
        return Array(drugQueryResult)
    }

    private func insertDrugIntoTable(name:String, nameType:String, status:String, drugClasses:[String])throws ->Int64{
        var rowsAdded:Int64 = 0
        
        do{
            let drugName = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            for drugClass in drugClasses{
                rowsAdded = try db!.run(drugTable.insert(self.name<-drugName, self.nameType<-nameType, self.status<-status, self.drugClass<-drugClass))
            }
        }
        catch{
            print("Error info: \(error)")
            print("Unable to add drug into DrugTable :", name)
        }
        return rowsAdded
    }
    
    func rowCount(){
        do{
            let drugCount = try db?.scalar(drugTable.count)
            let formularyCount = try  db?.scalar(formularyTable.count)
            let formularyBrandCount = try  db?.scalar(formularyBrandTable.count)
            let excludedCount = try db?.scalar(excludedTable.count)
            let restrictedCount = try db?.scalar(restrictedTable.count)
            print("Drug count: ", drugCount)
            print("Formulary count: ", formularyCount)
            print("Formulary Brand count: ", formularyBrandCount)
            print("Excluded count: ", excludedCount)
            print("Restricted count: ", restrictedCount)
        }
        catch{
            print("Error info: \(error)")
            print("Unable to get drug count")
        }
        
    }
    
    /**
     * CREATE TABLE DrugTable IF NOT EXISTS (
     * "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
     * "Name" TEXT,
     * "NameType" TEXT,
     * "Status" TEXT,
     * "Class" TEXT )
     */
    private func createDrugTable(db:Connection) throws{
        try db.run(drugTable.create(ifNotExists:true){ t in
            t.column(id, primaryKey:.Autoincrement)
            t.column(name)
            t.column(nameType)
            t.column(status)
            t.column(drugClass)
            })
    }

    /**
     *   CREATE TABLE FormularyTable IF NOT EXISTS(
     *       "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
     *       "Generic" TEXT,
     *       "BrandName" TEXT,
     *       "Strength" TEXT )
     */
    private func createFormularyTable(db:Connection) throws{
        try db.run(formularyTable.create(ifNotExists:true){t in
            t.column(id, primaryKey:.Autoincrement)
            t.column(genericName)
            t.column(brandName)
            t.column(strength)
            })
    }
    
    /**
     *   CREATE TABLE FormularyBrandTable IF NOT EXISTS(
     *       "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
     *       "Generic" TEXT,
     *       "BrandName" TEXT,
     *       "Strength" TEXT )
     */
    private func createFormularyBrandTable(db:Connection) throws{
        try db.run(formularyBrandTable.create(ifNotExists:true){t in
            t.column(id, primaryKey:.Autoincrement)
            t.column(genericName)
            t.column(brandName)
            t.column(strength)
            })
    }
    
    /**
     *   CREATE TABLE ExcludedTable IF NOT EXISTS(
     *       "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
     *       "Generic" TEXT,
     *       "BrandName" TEXT,
     *       "criteria" TEXT )
     */
    
    private func createExcludedTable(db:Connection) throws{
        try db.run(excludedTable.create(ifNotExists:true){t in
            t.column(id, primaryKey:.Autoincrement)
            t.column(genericName)
            t.column(brandName)
            t.column(criteria)
            })
    }
    
    /**
     *   CREATE TABLE ExcludedTable IF NOT EXISTS(
     *       "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
     *       "Generic" TEXT,
     *       "BrandName" TEXT,
     *       "criteria" TEXT )
     */
    
    private func createRestrictedTable(db:Connection) throws{
        try db.run(restrictedTable.create(ifNotExists:true){t in
            t.column(id, primaryKey:.Autoincrement)
            t.column(genericName)
            t.column(brandName)
            t.column(criteria)
            })
    }
}
