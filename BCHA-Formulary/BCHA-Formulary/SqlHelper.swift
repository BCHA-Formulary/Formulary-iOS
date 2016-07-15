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
            try db?.run(excludedTable.drop(ifExists: true))
            try db?.run(restrictedTable.drop(ifExists: true))
            
            try createDrugTable(db!)
            try createFormularyTable(db!)
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
                try insertDrugIntoTable(brandTrimName, nameType: NameType.BRAND.rawValue,
                                        status: Status.FORMULARY.rawValue, drugClasses: formulary.drugClass)
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
            let drugCount = db?.scalar(drugTable.count)
            let formularyCount = db?.scalar(formularyTable.count)
            let excludedCount = db?.scalar(excludedTable.count)
            let restrictedCount = db?.scalar(restrictedTable.count)
            print("Drug count: ", drugCount)
            print("Formulary count: ", formularyCount)
            print("Excluded count: ", excludedCount)
            print("Restricted count: ", restrictedCount)
        
    }
    
    /**
     * CREATE TABLE DrugTable IF NOT EXISTS (
     * "Name" TEXT PRIMARY KEY NOT NULL,
     * "NameType" TEXT,
     * "Status" TEXT,
     * "Class" TEXT)
     */
    private func createDrugTable(db:Connection) throws{
        try db.run(drugTable.create(ifNotExists:true){ t in
            t.column(name)
            t.column(nameType)
            t.column(status)
            t.column(drugClass)
            t.primaryKey(name, nameType)
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
