//
//  AlertBox.swift
//  WayAlerts
//
//  Created by Hari Kishore on 6/8/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit

class AlertBox: NSObject {

    static let singleTon = AlertBox()
    
    //var title : String
    //var message : String
    
    override private init() {
        //title = "Error"
        //message = "Error Message"
        super.init()
    }
    
    static func shareInstance() -> AlertBox {
    return singleTon
    }
    
//    init () {
//        self.title = titleString
//        self.message = messageString
//    }
    
    func show(title title : String, message msg : String, parentViewController parent : UIViewController) {
        // Create alert controller
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add OK Action (with out handler)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        // Present Alert
        parent.presentViewController(alert, animated: true, completion: nil)
    }
    
    func show(title title : String, message msg : String, okAction:()->Void, cancelAction:()->Void, parentViewController parent : UIViewController) {
        // Create alert controller
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add OK action
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(testOk: UIAlertAction!) in okAction()}))
        
        // Add Cancel Action
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {(testCancel: UIAlertAction!) in cancelAction()}))
        
        // Present Action
        parent.presentViewController(alert, animated: true, completion: nil)
    }
    
    func show(title title : String, message msg : String, parentViewController parent : UIViewController, okAction:()->Void) {
        // Create alert controller
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add OK Action (with handler)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(testOk: UIAlertAction!) in okAction()}))
        
        // Present alert
        parent.presentViewController(alert, animated: true, completion: nil)
    }
}
