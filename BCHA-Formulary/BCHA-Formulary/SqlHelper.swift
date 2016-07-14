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
            print("Could not connect to db")
        }
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
            try insertDrugIntoTable(formulary.primaryName,
                                        nameType: NameType.GENERIC.rawValue,
                                        status: Status.FORMULARY.rawValue,
                                        drugClasses: formulary.drugClass)
            
            //insert into formulary table
            for brand in formulary.alternateName{
                //for each brand name, add the name to the drug table
                try insertDrugIntoTable(brand, nameType: NameType.BRAND.rawValue,
                                        status: Status.FORMULARY.rawValue, drugClasses: formulary.drugClass)
                for strength in formulary.strengths{
                    //for each strength, and each brand name, add to the formulary table
                    try db?.run(formularyTable.insert(genericName<-formulary.primaryName, brandName<-brand, self.strength<-strength))
                }
            }
        }
        catch{
            print("Could not add formulary into drug table: ", formulary.primaryName)
        }
    }
    
    func insertExcludedGenericDrug(excluded:ExcludedDrug){
        if(db == nil) {
            print("ERROR: Database not initalized")
            return
        }
        do{
            //insert generic name into drug table
            try insertDrugIntoTable(excluded.primaryName,
                                    nameType: NameType.GENERIC.rawValue,
                                    status: Status.EXCLUDED.rawValue,
                                    drugClasses: excluded.drugClass)
            
            //insert into excluded table
            for brand in excluded.alternateName{
                //for each brand name, add the name to the drug table
                try insertDrugIntoTable(brand, nameType: NameType.BRAND.rawValue,
                                        status: Status.EXCLUDED.rawValue, drugClasses: excluded.drugClass)
                //for each brand name, add to the excluded table
                try db?.run(excludedTable.insert(genericName<-excluded.primaryName, brandName<-brand, self.criteria<-excluded.criteria))
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
            //insert generic name into drug table
            try insertDrugIntoTable(restricted.primaryName,
                                    nameType: NameType.GENERIC.rawValue,
                                    status: Status.RESTRICTED.rawValue,
                                    drugClasses: restricted.drugClass)
            
            //insert into Restricted table
            for brand in restricted.alternateName{
                //for each brand name, add the name to the drug table
                try insertDrugIntoTable(
                    brand, nameType: NameType.BRAND.rawValue,
                                        status: Status.RESTRICTED.rawValue, drugClasses: restricted.drugClass)
                //for each brand name, add to the restricted table
                try db?.run(restrictedTable.insert(genericName<-restricted.primaryName, brandName<-brand, self.criteria<-restricted.criteria))
            }
        }
        catch{
            print("Could not add restricted into drug table: ", restricted.primaryName)
        }
    }

    private func insertDrugIntoTable(name:String, nameType:String, status:String, drugClasses:[String])throws ->Int64{
        var rowsAdded:Int64 = 0
        do{
            for drugClass in drugClasses{
                rowsAdded = try db!.run(drugTable.insert(self.name<-name, self.nameType<-nameType, self.status<-status, self.drugClass<-drugClass))
            }
        }
        catch{
            print("Unable to add drug into DrugTable :", name)
        }
        return rowsAdded
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
            t.column(name, primaryKey:true)
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
