//
//  HttpRequest.swift
//  BCHA-Formulary
//
//  Created by Kelvin Chan on 2016-02-19.
//  Copyright © 2016 BCHA. All rights reserved.
//

import Foundation
struct HttpRequest {
    
    func makeGetRequest(){
        let url : NSURL = NSURL(string: "https://www.dropbox.com/s/epwhiy54cnxm67i/update.txt?dl=1")!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            if (error != nil){
                print(error?.localizedDescription)
            }
            print(NSString(data:data!, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
}