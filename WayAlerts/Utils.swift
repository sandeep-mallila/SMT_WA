//
//  Utils.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 18/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import EZAlertController
import GoogleMaps

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class Utils {
    
    class func setNSDString(AsKey asKey: String, WithValue withValue: String){
        NSUserDefaults.standardUserDefaults().setObject(withValue, forKey: asKey);
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    class func setNSDBool(AsKey asKey: String, WithValue withValue: Bool){
        NSUserDefaults.standardUserDefaults().setBool(withValue, forKey: asKey);
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    class func getNSDString(WithKey withKey: String) -> String{
        return (NSUserDefaults.standardUserDefaults().stringForKey(withKey) ?? "");
    }
    
    class func getNSDBool(WithKey withKey: String) -> Bool{
        return NSUserDefaults.standardUserDefaults().boolForKey(withKey) ?? false;
    }
    
    class func getThisUserID()-> String{
        return self.getNSDString(WithKey: Constants.NSDKeys.thisUserIdKey) ?? "";
    }
    
    // Text Field is empty - show red border
    class func errorHighlightTextField(textField: UITextField){
        textField.layer.borderColor = UIColor.redColor().CGColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
    }
    
    // Text Field is NOT empty - show gray border with 0 border width
    class func removeErrorHighlightTextField(textField: UITextField){
        textField.layer.borderColor = UIColor.grayColor().CGColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
    }
    
    // Evaluate regex on a string
    class func evalRegexOnString(RegexToEval regexToEval: String, SourceValue sourceValue: String) -> Bool{
        //let PHONE_REGEX = Constants.Generic.mobileNumberRegex
        let nsPredicate = NSPredicate(format: "SELF MATCHES %@", regexToEval)
        let regexEval =  nsPredicate.evaluateWithObject(sourceValue)
        return regexEval;
    }
    
    /**
     * Check if internet connection is available
     */
    class func isConnectedToNetwork() -> Bool {
        var status:Bool = false
        let session = NSURLSession.sharedSession()
        
        let url = NSURL(string: Constants.Generic.networkTestURL)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response:NSURLResponse?
        
        do{
            _ = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response) as NSData?
        }
        catch let error as NSError {
            //print(error.localizedDescription)
        }
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                status = true
            }
        }
        return status
    }
    
    class func showAlertOK(Title title: String, Message message: String){
        return;
        dispatch_async(dispatch_get_main_queue(), {
            EZAlertController.alert(title, message: message)
            //            let alert = AlertBox.shareInstance()
            //            alert.show(title: title, message: message, parentViewController: self)
            //            let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
            //            alert.show()
        });
    }
    
    class func setDeviceToken(DeviceToken deviceToken: String){
        // Set the NSD key
        self.setNSDString(AsKey: Constants.NSDKeys.thisDeviceToken, WithValue: deviceToken)
        
        // If thisUserID NSD is not null, call server API to update the device token in server db for this user.
        let userID = self.getThisUserID()
        if (!(userID ?? "").isEmpty) {
            // Call the API to update device token for this user
            DataController.sharedInstance.callUpdateDeviceTokenAPI(DeviceToken: deviceToken, success: { (serverResponse) in
                
                //2. Check to see if server responded success
                //let responseCode =  serverResponse[Constants.ServerResponseKeys.code] as! String;
                })
            { (error) in
                //print("error : \(error)")
                //let alert = AlertBox.shareInstance()
                //alert.show(title: "Error", message: "\(error)", parentViewController: self)
            }
        }
        
    }
    
    class func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    class func getCurrentDateTimeAsString() -> String {
        var returnVal = ""
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year, .Hour, .Minute, .Second], fromDate: date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        var hour = String(components.hour)
        var minute = String(components.minute)
        var second = String(components.second)
        
        if (components.hour < 10){
            hour = "0\(hour)"
        }
        
        if (components.minute < 10){
            minute = "0\(minute)"
        }
        
        if (components.second < 10){
            second = "0\(second)"
        }
        
        returnVal = "\(day)/\(month)/\(year) \(hour):\(minute):\(second)"
        
        return returnVal
    }
    
    class func getDeviceBatteryLevel() -> String {
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        return String(UIDevice.currentDevice().batteryLevel*100)
    }
    
    class func getLocationAccuracyAsString(Location location: CLLocation) -> String{
        return String(location.horizontalAccuracy)
    }
    
    // Returns the most recently presented UIViewController (visible)
    class func getCurrentViewController() -> UIViewController? {
        
        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = Utils.getNavigationController() {
            
            return navigationController.visibleViewController
        }
        
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            
            var currentController: UIViewController! = rootController
            
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    // Returns the navigation controller if it exists
    class func getNavigationController() -> UINavigationController? {
        
        if let navigationController = UIApplication.sharedApplication().keyWindow?.rootViewController  {
            
            return navigationController as? UINavigationController
        }
        return nil
    }
    
}