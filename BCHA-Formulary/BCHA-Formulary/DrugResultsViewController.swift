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
        
        if(drug.status == Status.FORMULARY){
            let formDrug = drug as! FormuarlyDrug
            self.title = formDrug.primaryName
        }
        else if(drug.status == Status.EXCLUDED){
            self.title = (drug as! ExcludedDrug).primaryName
        }
        else{
            self.title = (drug as! RestrictedDrug).primaryName
        }
        
        
    }
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
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
                return "Criteria"
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Data cell", forIndexPath: indexPath) as UITableViewCell
        
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
        }
        else if(indexPath.section == 1){
            cell.textLabel?.text = drug.status.rawValue
        }
        else if(indexPath.section == 2){
            if (drug.status == Status.FORMULARY){
                let data = (drug as! FormuarlyDrug).strengths[indexPath.row]
                cell.textLabel?.text = data
            }
            else if(drug.status == Status.EXCLUDED){
                let data = (drug as! ExcludedDrug).criteria
                cell.textLabel?.text = data
            }
            else{
                let data = (drug as! RestrictedDrug).criteria
                cell.textLabel?.text = data
            }
        }
        else{
            let data = drug.drugClass[indexPath.row]
            cell.textLabel?.text = data
        }
        return cell
    }
    
}
