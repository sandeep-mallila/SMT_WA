//
//  RegistrationViewController.swift
//  WayAlerts
//
//  Created by venkata hari kishore lokam on 11/06/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import CoreData
//import SwiftyJSON

class RegistrationViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    //placeholder for event endpoint
    //private var userAPI: UserAPI!
    private var responseParser = ResponseParser.sharedInstance
    
    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext = NSManagedObjectContext()
    //var userAPI: UserAPI = UserAPI()
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var lblTandC: UILabel!
    @IBOutlet weak var termsAndCButton: UIButton!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    
    @IBOutlet weak var lblLoginNow: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Core Data properties
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDelegate.managedObjectContext
        //self.userAPI = UserAPI()
        
        // Set NSD values for appDelegate and moc
        //let adelgt = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        self.hideKeyboardWhenTappedAround() 

        // Do any additional setup after loading the view.
        // Check to see if user already logged in. If so. directly take him to the Tab bar control
        if (Utils.getNSDBool(WithKey: Constants.NSDKeys.isUserLoggedin)){
            dispatch_async(dispatch_get_main_queue(), {
                let myTabbarController = self.storyboard?.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = myTabbarController
                myTabbarController.transitioningDelegate = self.transitioningDelegate
            })
        };
        
        lblTandC.userInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(termsAndConditionsClickAction))
        lblTandC.addGestureRecognizer(tap)
        tap.delegate = self
        self.txtMobileNumber.delegate = self
        
        lblLoginNow.userInteractionEnabled = true
        let loginTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(launchLoginScreen))
        lblLoginNow.addGestureRecognizer(loginTap)
        loginTap.delegate = self
        
        txtFirstName.delegate = self
        txtLastName.delegate = self
        txtMobileNumber.delegate = self
        
        self.txtFirstName.nextField = self.txtLastName
        self.txtLastName.nextField = self.txtMobileNumber
        self.addDoneButtonTo(txtMobileNumber)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.nextField?.becomeFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewWillAppear(animated: Bool) {
//        self.setup()
//    }
//    
//    private func setup() {
//        self.userAPI = UserAPI.sharedInstance
//    }
    
    @IBAction func btnCancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tcButtonAction(sender: AnyObject) {
        if(self.termsAndCButton.selected == true) {
            self.termsAndCButton.selected = false
        } else {
            self.termsAndCButton.selected = true
            self.termsAndCButton.setImage(UIImage(named: "second.png"), forState: UIControlState.Selected)
        }
    }
    
    func termsAndConditionsClickAction(gr:UITapGestureRecognizer) {
        // user touch field
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("webView")
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= Constants.Generic.mobileNumberLimit
    }
    
    @IBAction func submitAction(sender: AnyObject) {
        
        // Validate fields data
        if (!self.validatePageFields()){
            return;
        }
        
        // Show busy icon
        self.view.startBusySpinner()
        
        //1. Call server API
        DataController.sharedInstance.callRegistrationAPI(FirstName: txtFirstName.text!, LastName: txtLastName.text!, Mobile: txtMobileNumber.text!, IMEI: "", GCMRegToken: "", success:  { (serverResponse) in
              
                //2. Check to see if server responded success
                let responseCode =  serverResponse[Constants.ServerResponseKeys.code] as! String
                var registrationSuccess = false;
                if(responseCode == Constants.Generic.goodResponseCode){
                    registrationSuccess = true;
//                    // Parse response and get the user data to be saved in te local db
//                    let userDetailsToInsert = self.responseParser.getUserDetailsToInsert(ServerResponse: serverResponse)
//                    
//                    // Save the data to local db
//                    self.userAPI.createNewUser(userDetailsToInsert);
                }
            
            // Hide busy icon
            self.view.stopBusySpinner()
            
                //3. Show alert with acknowledgement to the user.
                dispatch_sync(dispatch_get_main_queue(), {
                    let alert = AlertBox.shareInstance()
                    alert.show(title: (serverResponse[Constants.ServerResponseKeys.message]! as! String), message: (serverResponse[Constants.ServerResponseKeys.description]! as! String), parentViewController: self, okAction: {
                        // Now redirect user to the OTP View
                        if(registrationSuccess){
                            self.dismissViewControllerAnimated(true, completion: nil);
                            self.performSegueWithIdentifier("registrationToOTPSeg", sender: self)
                        }
                    });
                });
            })
        { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
            
            print("error : \(error)")
            let alert = AlertBox.shareInstance()
            alert.show(title: "Error", message: "\(error)", parentViewController: self)
        }
    }
    
    func launchLoginScreen(gr:UITapGestureRecognizer) {
        // user touch field
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("loginViewController")
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func validatePageFields() -> Bool{
        var isDataValid = true;
        var invalidTextFields = [UITextField]();
        var validTextFields = [UITextField]();
        
        // Check to see if data in First Name is not null
        let isValidFirstName = Utils.evalRegexOnString(RegexToEval: Constants.Generic.nameRegex,SourceValue:txtFirstName.text!)
        if((txtFirstName.text!.stringByTrimmingCharactersInSet(Constants.Generic.whitespace) == "") || (!isValidFirstName) ){
            invalidTextFields.append(txtFirstName);
            isDataValid = false;
        }else{
            validTextFields.append(txtFirstName);
        }
        
        // Check to see if data in Last Name is not null
        let isValidLastName = Utils.evalRegexOnString(RegexToEval: Constants.Generic.nameRegex,SourceValue:txtLastName.text!)
        if((txtLastName.text!.stringByTrimmingCharactersInSet(Constants.Generic.whitespace) == "") || (!isValidLastName) ){
            invalidTextFields.append(txtLastName);
            isDataValid = false;
        }else{
            validTextFields.append(txtLastName);
        }
        
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
