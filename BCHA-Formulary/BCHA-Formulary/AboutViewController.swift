//
//  AboutViewController.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-08-07.
//  Copyright © 2016 BCHA. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class AboutViewController : UIViewController, MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var emailSupportLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About This App"
        
        scrollView.contentSize = contentView.frame.size
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AboutViewController.tapResponse(_:)))
        tapGesture.numberOfTapsRequired = 1
        emailSupportLabel.userInteractionEnabled =  true
        emailSupportLabel.addGestureRecognizer(tapGesture)
    }
    
    func tapResponse(recognizer: UITapGestureRecognizer) {
        let emailVC = configureEmailViewController()
        if(MFMailComposeViewController.canSendMail()){
            self.presentViewController(emailVC, animated: true, completion: nil)
        }
        else{
            emailFailAlert()
        }
    }
    
    func configureEmailViewController()->MFMailComposeViewController{
        let emailVC = MFMailComposeViewController()
        emailVC.mailComposeDelegate = self
        
        emailVC.setToRecipients(["anthony.tung@fraserhealth.ca"])
        emailVC.setSubject("Formulary-iOS App Feedback")
        
        return emailVC
    }
    
    func emailFailAlert(){
//        let emailAlert = UIAlertView(title: "Email could not send", message: "Could not send email from device. Please check settings and try again", delegate: self, cancelButtonTitle: "OK")
        let emailAlert = UIAlertController(title:"Email could not send", message: "Could not send email from device. Please check settings and try again", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        emailAlert.addAction(action
        )
        presentViewController(emailAlert, animated: true, completion: nil)
//        emailAlert.show()
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        //incase we want to add function later
        switch result.rawValue {
        
        case MFMailComposeResult.Cancelled.rawValue:
            print("Email cancelled")
            break
        case MFMailComposeResult.Sent.rawValue:
            print("Email sent")
            break
        default:
            break
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
