//
//  LoginViewController.swift
//  WayAlerts
//
//  Created by Hari Kishore on 6/8/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext = NSManagedObjectContext()
    //var userAPI: UserAPI = UserAPI()
    
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var lblRegistration: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        
        // Set Core Data properties
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDelegate.managedObjectContext
        //self.userAPI = UserAPI()
        
        lblRegistration.userInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(launchRegistrationScreen))
        lblRegistration.addGestureRecognizer(tap)
        tap.delegate = self
        self.txtMobileNumber.delegate = self
        
        // Set delegates for text fields
        txtMobileNumber.delegate = self
        
        self.addDoneButtonTo(txtMobileNumber)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.nextField?.becomeFirstResponder()
        return true
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        
        // Validate fields data
        if (!self.validatePageFields()){
            return;
        }
        
        // Show busy icon
        self.view.startBusySpinner()
        
        DataController.sharedInstance.callLoginRequestAPI(mobile:txtMobileNumber.text!, success: { (serverResponse) in
            
            //2. Check to see if server responded success
            let responseCode =  serverResponse[Constants.ServerResponseKeys.code] as! String
            if(responseCode == Constants.Generic.goodResponseCode){
                
                // Hide busy icon
                self.view.stopBusySpinner()
                
                //2.1 Business Logic: Redirect to OTP Page
                Utils.setNSDString(AsKey: Constants.NSDKeys.thisMobileNumberKey, WithValue: self.txtMobileNumber.text!)
                self.launchOTPScreen()
                //self.dismissViewControllerAnimated(true, completion: nil);
                //self.performSegueWithIdentifier("loginOTPSeg", sender: self)
                //self.topMostController().performSegueWithIdentifier("registrationToOTPSeg", sender: self.topMostController())
                
            }else{
                // Hide busy icon
                self.view.stopBusySpinner()
                
                //3. Show alert with acknowledgement to the user.
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = AlertBox.shareInstance()
                    alert.show(title: (serverResponse[Constants.ServerResponseKeys.message]! as! String), message: (serverResponse[Constants.ServerResponseKeys.description]! as! String), parentViewController: self)
                });
            }
        }) { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
                print("error : \(error)")
                let alert = AlertBox.shareInstance()
                alert.show(title: "Error", message: "\(error)", parentViewController: self)
        }
    }
    
    func launchRegistrationScreen(gr:UITapGestureRecognizer) {
        // user touch field
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("RegistrationViewController") 
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= Constants.Generic.mobileNumberLimit
    }
    
    func launchOTPScreen() {
        // user touch field
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("VerifyOTPViewController")
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func topMostController() -> UIViewController {
        let topController: UIViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
//        while (topController.presentedViewController != nil) {
//            topController = topController.presentedViewController!
//        }
        return topController
    }
    
    func validatePageFields() -> Bool{
        var isDataValid = true;
        var invalidTextFields = [UITextField]();
        var validTextFields = [UITextField]();
        
        // Check to see if data in Mobile Number is not null and is valid
        let validMobileNo =  Utils.evalRegexOnString(RegexToEval: Constants.Generic.mobileNumberRegex,SourceValue:txtMobileNumber.text!)
        
        if((txtMobileNumber.text!.stringByTrimmingCharactersInSet(Constants.Generic.whitespace) == "") || (!validMobileNo)){
            invalidTextFields.append(txtMobileNumber);
            isDataValid = false;
        }else{
            validTextFields.append(txtMobileNumber);
        }
        
        // Now highlight all text fields that have invalid data
        for textField in invalidTextFields{
            Utils.errorHighlightTextField(textField);
        }
        // Remove error highlight all text fields that have valid data
        for textField in validTextFields{
            Utils.removeErrorHighlightTextField(textField);
        }
        return isDataValid;
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
        txtMobileNumber.endEditing(true)
    }
}
