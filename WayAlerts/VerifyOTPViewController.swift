//
//  VerifyOTPViewController.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 20/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import CoreData

class VerifyOTPViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext = NSManagedObjectContext()
    //var userAPI: UserAPI = UserAPI()
    
    @IBOutlet weak var txtOTP: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var lblResendOTP: UILabel!
    
    var thisMobileNumber: String = "";
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        <#code#>
//    }
//    
//     convenience init(){
//        self.init()
//        // Set Core Data properties
//        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        self.moc = appDelegate.managedObjectContext
//        self.userAPI = UserAPI(appDelegate: self.appDelegate,ManagedObjectContext: self.moc)
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Set Core Data properties
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDelegate.managedObjectContext
        //self.userAPI = UserAPI()
        
        // Get the users mobile number from NSDefaults
        thisMobileNumber = Utils.getNSDString(WithKey: Constants.NSDKeys.thisMobileNumberKey)
        
        // Set it to the mobile number text field and make it readonly.
        txtMobileNumber.text = thisMobileNumber;
        txtMobileNumber.enabled = false;
        
        // Set onTap gesture for lblResendOTP
        lblResendOTP.userInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(resendOTP))
        lblResendOTP.addGestureRecognizer(tap)
        tap.delegate = self
        
        // Set delegate for text fields
        txtOTP.delegate = self
        
        self.addDoneButtonTo(txtOTP)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.nextField?.becomeFirstResponder()
        return true
    }
    
    @IBAction func onTapVerifyBtn(sender: AnyObject) {
        // Show busy icon
        self.view.startBusySpinner()
        
        // Send control to DataController to take care of calling the server API
        let otp = txtOTP.text! as String
        let deviceToken = Utils.getNSDString(WithKey: Constants.NSDKeys.thisDeviceToken)
        DataController.sharedInstance.callLoginAPI(Mobile: thisMobileNumber, OTP: otp, GCMRegToken: (deviceToken ?? "iPhone"), success: { (serverResponse) in
            
            //2. Check to see if server responded success
            let responseCode =  serverResponse[Constants.ServerResponseKeys.code] as! String;
            if(responseCode == Constants.Generic.goodResponseCode){
                
                // Set the NSDefaukts key for UserLoggedin to true
                Utils.setNSDBool(AsKey: Constants.NSDKeys.isUserLoggedin, WithValue: true);
                
                // Hide busy icon
                self.view.stopBusySpinner()
                
                // Now redirect user to the main tabbed view control *** TODO ***
                //self.dismissViewControllerAnimated(true, completion: nil);
                //self.performSegueWithIdentifier("regLoginSegue", sender: self)
                dispatch_async(dispatch_get_main_queue(), {
                    let myTabbarController = self.storyboard?.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.window?.rootViewController = myTabbarController
                    myTabbarController.transitioningDelegate = self.transitioningDelegate
                })
                
            }else{
                // Hide busy icon
                self.view.stopBusySpinner()
                
                // Show alert with login failed message.
                dispatch_sync(dispatch_get_main_queue(), {
                    let alert = AlertBox.shareInstance()
                    alert.show(title: (serverResponse[Constants.ServerResponseKeys.message]! as! String), message: (serverResponse[Constants.ServerResponseKeys.description]! as! String), parentViewController: self);
                });
            }
            })
        { (error) in
            print("error : \(error)")
            // Hide busy icon
            self.view.stopBusySpinner()
            let alert = AlertBox.shareInstance()
            alert.show(title: "Error", message: "\(error)", parentViewController: self)
        }

    }
    
    // MARK: postLogin API Call
    func getUserStoredDataFromServer(){
        // This function calls the postLogin api call from dataController.
    }
    
    func resendOTP(){
        // Function call to resend OTP (LoginRequest API) to this user.
        DataController.sharedInstance.callLoginRequestAPI(mobile:thisMobileNumber, success: { (serverResponse) in
            
            // Check to see if server responded success
            let responseCode =  serverResponse[Constants.ServerResponseKeys.code] as! String
            if(responseCode == Constants.Generic.goodResponseCode){
                
                // Display alert saying a new OTP has been sent as an SMS to the user.
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = AlertBox.shareInstance()
                    alert.show(title: (StringConstants.resentOTPAlertTitle), message: (StringConstants.resentOTPAlertDesc), parentViewController: self)
                });
                
            }else{
                //3. Show alert with acknowledgement to the user.
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = AlertBox.shareInstance()
                    alert.show(title: (serverResponse[Constants.ServerResponseKeys.message]! as! String), message: (serverResponse[Constants.ServerResponseKeys.description]! as! String), parentViewController: self)
                });
            }
           
        }) { (error) in
            print("error : \(error)")
            let alert = AlertBox.shareInstance()
            alert.show(title: "Error", message: "\(error)", parentViewController: self)
        }

    }
    
    // MARK: Done for numberTextField    
    private func addDoneButtonTo(textField: UITextField) {
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "didTapDone:")
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        textField.inputAccessoryView = keyboardToolbar
    }
    
    func didTapDone(sender: AnyObject?) {
        txtOTP.endEditing(true)
    }    
    
}
