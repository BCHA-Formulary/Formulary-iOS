//
//  DrugClassSearchTableViewController.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-07-26.
//  Copyright © 2016 BCHA. All rights reserved.
//

import Foundation
import UIKit


class DrugClassSearchTableViewController: UITableViewController {
    var drugClassName:String?
    var sql:SqlHelper!
    var drugClassSearchNameList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sql = SqlHelper.init()
        
        if(drugClassName != nil){
            self.title = drugClassName
            do{
                drugClassSearchNameList = try sql.queryDrugNamesByDrugClass(drugClassName!).sort(){ $0 < $1 }
            }
            catch{
                print("Error info: \(error)")
            }
        }
        else{
            self.title = "Drug Class not found"
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO if drugClassSearchNameList is zero
       return drugClassSearchNameList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DrugNameCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = drugClassSearchNameList[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let drugSearched = sql.queryForDrugByName(drugClassSearchNameList[indexPath.row])
        let control = self.navigationController?.viewControllers[(navigationController?.viewControllers.count)!-2] as! DrugResultsViewController
        control.drug = drugSearched
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    
}