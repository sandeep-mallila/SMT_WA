//
//  FriendDetailsViewController.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 04/08/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import EZAlertController

class FriendDetailsViewController: UITableViewController {
    var item: Friends!
 
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    //@IBOutlet var switchAlertsOut: UISwitch!
    //@IBOutlet var switchAlertsIn: UISwitch!
    
    @IBOutlet var switchAlertsOut: UISwitch!
    @IBOutlet var switchAlertsIn: UISwitch!
    
    
    
    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext = NSManagedObjectContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Friend Details"
        
        // Set Core Data properties
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDelegate.managedObjectContext
       
        // Populate data
        self.loadData()
        
        // Hide empty rows
        tableView.tableFooterView = UIView()
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cellIdentifier = tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
        
        
        if(cellIdentifier == "MobileNumberCell"){
            // This is Call Number action
            let phoneNumber = tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.text
            Utils.callNumber(phoneNumber!)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        else if(cellIdentifier == "DeleteUserCell"){
            // This is delete action
            print("Delete friend tapped.")
            let deletedFriendID = item.userID
            
            // Confirm Delete Action
            EZAlertController.alert("Confirm Delete", message: "Are you sure you want to delete this friend contact?", buttons: ["Delete","Cancel"], tapBlock: {(alertAction, position) in
                if position == 0 {
                    // Now perform Accept action on this user
                    self.deleteFriend(DeletedFriendID: deletedFriendID!, success: { (serverResponse) in
                        })
                    { (error) in
                        print("error : \(error)")
                        let alert = AlertBox.shareInstance()
                        alert.show(title: "Error", message: "\(error)", parentViewController: self)
                    }
                }
            
            })
            
            //
//            EZAlertController.alert("Please Confirm", message: "Are you sure you want to delete this friend?", acceptMessage: "Yes", acceptBlock: {
//            
//                // Now perform Accept action on this user
//                self.deleteFriend(DeletedFriendID: deletedFriendID!, success: { (serverResponse) in
//                    })
//                { (error) in
//                    print("error : \(error)")
//                    let alert = AlertBox.shareInstance()
//                    alert.show(title: "Error", message: "\(error)", parentViewController: self)
//                }
//
//                
//            })
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        let cellIdentifier = tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
        
        if(cellIdentifier == "DeleteUserCell" || cellIdentifier == "MobileNumberCell"){
            return indexPath
        }else{
            return nil
        }
    }
    
    @IBAction func switchSendAlertsTapped(sender: AnyObject) {
        // Show busy icon
        self.view.startBusySpinner()
        
        // Now perform delete action on this user
        DataController.sharedInstance.callToggleTrackStatusrAPI(FriendUserID: item.userID!, CurrentStatus: item.allowAlertsOut!, success: {serverResponse in
            self.view.stopBusySpinner()
            })
        { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error",Message: "\(error)")
        }
    }
    
    @IBAction func switchReceiveAlertsTapped(sender: AnyObject) {
        // Show busy icon
        self.view.startBusySpinner()
        
        // Now perform delete action on this user
        DataController.sharedInstance.callBlockUserAPI(FriendUserID: item.userID!, CurrentStatus: item.allowAlertsIn!, success: {serverResponse in
            self.view.stopBusySpinner()
            })
        { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error",Message: "\(error)")
        }
    }
    
    
    func loadData(){
        self.lblUserName.text = self.item.fullName
        self.lblMobileNumber.text = self.item.mobileNumber
        
        let friendsAPI = FriendsAPI(ApplicationDelegate: self.appDelegate)
        
        // Get friend user id by mobile number
        let friend = friendsAPI.getFriendByMobileNo(FriendMobileNo: self.item.mobileNumber!)
        
        // Set the Alerts In switch status
        let alertsInFlag = friendsAPI.getIncomingAlertsFlag(FriendUserID: (friend?.userID)!)
        self.switchAlertsIn.setOn(alertsInFlag, animated: true)
        
        // Set the Alerts Out switch status
        let alertsOutFlag = friendsAPI.getOutgoingAlertsFlag(FriendUserID: (friend?.userID)!)
        self.switchAlertsOut.setOn(alertsOutFlag, animated: true)
    }
    
    func deleteFriend(DeletedFriendID deletedFriendID: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        // Show busy icon
        self.view.startBusySpinner()
        
        // Now perform delete action on this user
        DataController.sharedInstance.callDeleteFNFAPI(DeletedFriendID: deletedFriendID, success: {serverResponse in            success(responseData: serverResponse)
            
            self.view.stopBusySpinner()
            })
        { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error",Message: "\(error)")
        }
    }
}
