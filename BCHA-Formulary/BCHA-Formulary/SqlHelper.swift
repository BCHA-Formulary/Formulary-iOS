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

class SqlHelper{
    init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .DocumentDirectory, .UserDomainMask, true
                ).first!
            
            let db = try Connection("\(path)/db.sqlite3")
            
            try createDrugTable(db)
            try createFormularyTable(db)
        }
        catch {
            print("Could not connect to db")
        }
    }
    
    /**
     * CREATE TABLE DrugTable IF NOT EXISTS (
     * "Name" TEXT PRIMARY KEY NOT NULL,
     * "NameType" TEXT,
     * "Status" TEXT,
     * "Class" TEXT)
     */
    private func createDrugTable(db:Connection) throws{
        let drugTable = Table("DrugTable")
        let name = Expression<String>("Name")
        let nameType = Expression<String>("NameType")
        let status = Expression<String>("Status")
        let drugClass = Expression<String>("Class")
        
        try db.run(drugTable.create(ifNotExists:true){ t in
            t.column(name, primaryKey:true)
            t.column(nameType)
            t.column(status)
            t.column(drugClass)
            })
    }
    
    private func createFormuarlyTable(db:Connection) throws{
        let formularyTable = Table("FormularyTable")
        let id = Expression<Int64>("id")
        let genericName = Expression<String>("GenericName")
        let brandName = Expression<String>("BrandName")
        let strength = Expression<String>("Strength")
        
        try db.run(formularyTable.create(ifNotExists:true){t in
            t.column(id, primaryKey:.Autoincrement)
            t.column(genericName)
            t.column(brandName)
            t.column(strength)
            })
    }
    
    private func createExcludedTable(db:Connection) throws{
        let excludedTable = Table("ExcludedTable")
        let id = Expression<Int64>("id")
        let genericName = Expression<String>("GenericName")
        let brandName = Expression<String>("BrandName")
        let reason = Expression<String>("Reason")
        
        
        try db.run(excludedTable.create(ifNotExists:true){t in
            t.column(id, primaryKey:.Autoincrement)
            t.column(genericName)
            t.column(brandName)
            t.column(reason)
            })
    }
    
    private func createRestrictedTable(db:Connection) throws{
        let excludedTable = Table("RestrictedTable")
        let id = Expression<Int64>("id")
        let genericName = Expression<String>("GenericName")
        let brandName = Expression<String>("BrandName")
        let reason = Expression<String>("Reason")
        
        
        try db.run(excludedTable.create(ifNotExists:true){t in
            t.column(id, primaryKey:.Autoincrement)
            t.column(genericName)
            t.column(brandName)
            t.column(reason)
            })
    }
}
