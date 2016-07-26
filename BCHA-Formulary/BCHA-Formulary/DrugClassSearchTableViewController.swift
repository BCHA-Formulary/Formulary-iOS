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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(drugClassName != nil){
            self.title = drugClassName
        }
        else{
            self.title = "Drug Class not found"
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DrugNameCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = "Test"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Tapped")
        let control = self.navigationController?.viewControllers[(navigationController?.viewControllers.count)!-2] as! DrugResultsViewController
        control.drug = FormuarlyDrug.init(primaryName: "Test", nameType: NameType.GENERIC, alternateName: ["1","2"], strengths: ["3","4"], status: Status.FORMULARY, drugClass: ["class1", "class2"])
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    
}