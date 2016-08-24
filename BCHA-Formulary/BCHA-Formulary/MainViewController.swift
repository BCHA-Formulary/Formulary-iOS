//
//  ViewController.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-02-18.
//  Copyright © 2016 BCHA. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController, MPGTextFieldDelegate {

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var searchField: MPGTextField_Swift!
    @IBOutlet weak var searchBttn: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    var firebase:FirebaseHelper!
    var sql:SqlHelper!
    var drugSearched:DrugBase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view, typically from a nib.
        if(FirebaseHelper.isConnectedToNetwork()){
            sql = SqlHelper.init()
            firebase = FirebaseHelper.init()
            firebase.isUpToDate(loadingView, spinner: loadingSpinner, sql: sql)
        }
        else{
            //TODO no internet error
        }
        
        
        searchField.mDelegate = self
        searchField.layer.borderWidth = 1;
        searchField.layer.cornerRadius = 8.0
        searchField.layer.borderColor = UIColor.orangeColor().CGColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        print("Prep segue")
        if (segue.identifier == "DrugResultSegue") {
            let svc = segue.destinationViewController as! DrugResultsViewController;
            
            if (drugSearched != nil){
                svc.drug = drugSearched!
            }
        }
        else if (segue.identifier == "NoDrugResultSegue"){
            let svc = segue.destinationViewController as! NoDrugResultViewController
            
            if(drugSearched == nil){
                svc.drugName = searchField.text
            }
        }
    }

    @IBAction func searchDrug(sender: UIButton) {
        if(searchField.text! == ""){
            //TODO tell user field is empty
            return
        }
        drugSearched = sql.queryForDrugByName(searchField.text!)
        if(drugSearched != nil){
            performSegueWithIdentifier("DrugResultSegue", sender: self)
        }
        else{
            performSegueWithIdentifier("NoDrugResultSegue", sender: self)
        }
    }

    @IBAction func helpScreen(sender: AnyObject) {
//        FirebaseHelper.init().isUpToDate()
        SqlHelper.init().rowCount()
    }
    
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>]
    {
        var sampleData = [Dictionary<String, AnyObject>]()
        let drugNames = Array(Set(sql.getAllDrugNames())).sort(){ $0 < $1 }
        for name in drugNames{
            let dictionary = ["DisplayText":name, "DisplaySubText":"", "CustomObject":""]
            sampleData.append(dictionary)
        }
        return sampleData
    }
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool{
        return true
    }
    
    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String,AnyObject>){
        print("Dictionary received = \(data)")
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        searchField.endEditing(true)
    }
}

