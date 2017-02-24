//
//  DrugResultsViewController.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-07-22.
//  Copyright © 2016 BCHA. All rights reserved.
//

import Foundation
import UIKit

class DrugResultsViewController : UITableViewController {
    var drug:DrugBase!
    var strengthList:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(drug)
        self.navigationController?.navigationBarHidden = false
        
        //no drug error
        if(drug == nil){
            self.navigationController?.popViewControllerAnimated(true)
            //TODO prompt error message
            return
        }
        
        //order strength list if formulary
        if(drug.status == Status.FORMULARY){
            strengthList = (drug as! FormuarlyDrug).strengths.sort(){$0 < $1}
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(drug.status == Status.FORMULARY){
            self.title = (drug as! FormuarlyDrug).primaryName
        }
        else if(drug.status == Status.EXCLUDED){
            self.title = (drug as! ExcludedDrug).primaryName
        }
        else{
            self.title = (drug as! RestrictedDrug).primaryName
        }
        
        tableView.reloadData()
    }
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "DrugClassSearchSegue") {
            //going to drug search by class
            self.navigationController?.navigationBarHidden = false
            let drugSearchViewController = segue.destinationViewController as! DrugClassSearchTableViewController
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell){
                drugSearchViewController.drugClassName = drug.drugClass[indexPath.row]
            }
        }
        else{
            //going back to main search page
            self.navigationController?.navigationBarHidden = true
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4 //alt names, status, strength/criteria, drugclasses
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "Alternate Name(s)"
        }
        else if (section == 1){
            return "Drug Status"
        }
        else if (section == 2){
            if(drug.status == Status.FORMULARY){
                return "Strengths"
            }
            else{
                return "Reason for Exclusion"
            }
        }
        else{
            return "Drug Class(es)"
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            if (drug.status == Status.FORMULARY){
                return (drug as! FormuarlyDrug).alternateName.count
            }
            else if(drug.status == Status.EXCLUDED){
                return(drug as! ExcludedDrug).alternateName.count
            }
            else{
                return(drug as! RestrictedDrug).alternateName.count
            }
        }
        else if (section == 1){
            return 1
        }
        else if(section == 2){
            if (drug.status == Status.FORMULARY){
                return (drug as! FormuarlyDrug).strengths.count
            }
            else{
                return 1
            }
        }
        else{
            return drug.drugClass.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell
        if(indexPath.section == 3){
            cell = tableView.dequeueReusableCellWithIdentifier("DrugClass cell", forIndexPath: indexPath) as UITableViewCell
        }
        else{
            cell = tableView.dequeueReusableCellWithIdentifier("Data cell", forIndexPath: indexPath) as UITableViewCell
        }
        
        if(indexPath.section == 0){
            if (drug.status == Status.FORMULARY){
                let data = (drug as! FormuarlyDrug).alternateName[indexPath.row]
                cell.textLabel?.text = data
            }
            else if(drug.status == Status.EXCLUDED){
                let data = (drug as! ExcludedDrug).alternateName[indexPath.row]
                cell.textLabel?.text = data
            }
            else{
                let data = (drug as! RestrictedDrug).alternateName[indexPath.row]
                cell.textLabel?.text = data
            }
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        else if(indexPath.section == 1){
            cell.textLabel?.text = drug.status.rawValue
            if(drug.status == Status.FORMULARY){
                cell.textLabel?.textColor = UIColor.blackColor()
            }
            else{
                cell.textLabel?.textColor = UIColor.redColor()
            }
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        else if(indexPath.section == 2){
            if (drug.status == Status.FORMULARY){
                let data = strengthList[indexPath.row]
                cell.textLabel?.text = data
            }
            else if(drug.status == Status.EXCLUDED){
                let data = (drug as! ExcludedDrug).criteria
                cell.textLabel?.text = data
                tableView.estimatedRowHeight = 60
                tableView.rowHeight = UITableViewAutomaticDimension
            }
            else{
                let data = (drug as! RestrictedDrug).criteria
                cell.textLabel?.text = data
            }
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        else{
            let data = drug.drugClass[indexPath.row]
            cell.textLabel?.text = data
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    //TableView iteraction
    //Only the drug class section is clickable
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if(indexPath.section == 3){
            return indexPath
        }
        else{
            return nil
        }
    }
}
