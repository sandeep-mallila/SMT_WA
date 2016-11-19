//
//  LocationDetailsViewController.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 10/09/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import EZAlertController

class LocationDetailsViewController: UITableViewController, UITextFieldDelegate {
    var item: Locations!
    var selectedLocationID: String = ""
    
    @IBOutlet weak var lblLocationName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblLatLong: UILabel!
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var lblName: UILabel!
    
    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext = NSManagedObjectContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Location Details"
        
        // Set Core Data properties
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDelegate.managedObjectContext
        
        // Populate data
        self.loadData()
        
        // Hide empty rows
        tableView.tableFooterView = UIView()
        
        // Set delegate for the txtName field
        self.txtName.delegate = self
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cellIdentifier = tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
        let selectedLocationID = item.id!
        
        
        if(cellIdentifier == Constants.LocationCellIdentifiers.CreateWayCell){
            // This is Create Way action
            self.createWayToThisDestination(selectedLocationID)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        else if(cellIdentifier == Constants.LocationCellIdentifiers.LocationNameCell){
            // This is update Location action
            self.prepareForUpdate()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        else if(cellIdentifier == Constants.LocationCellIdentifiers.ShareWithFriendsCell){
            // This is Create Way action
            self.shareLocationWithFriends(selectedLocationID)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        else if(cellIdentifier == Constants.LocationCellIdentifiers.WaysHistoryCell){
            // This is Create Way action
            self.viewWayHistoryForLocation(selectedLocationID)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        else if(cellIdentifier == Constants.LocationCellIdentifiers.ViewOnMapCell){
            // This is Create Way action
            self.viewLocationOnMap(selectedLocationID)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        else if(cellIdentifier == Constants.LocationCellIdentifiers.DeleteCell){
            // This is delete action
            
            // Confirm Delete Action
            // Now perform Accept action on this user
            self.deleteLocation(LocationID: selectedLocationID, success: { (serverResponse) in
                })
            { (error) in
                print("error : \(error)")
                let alert = AlertBox.shareInstance()
                alert.show(title: "Error", message: "\(error)", parentViewController: self)
            }
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        let cellIdentifier = tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
        
        if(cellIdentifier == Constants.LocationCellIdentifiers.CreateWayCell ||
            cellIdentifier == Constants.LocationCellIdentifiers.DeleteCell ||
            cellIdentifier == Constants.LocationCellIdentifiers.ShareWithFriendsCell ||
            cellIdentifier == Constants.LocationCellIdentifiers.ViewOnMapCell ||
            cellIdentifier == Constants.LocationCellIdentifiers.WaysHistoryCell
            ){
            return indexPath
        }else{
            return nil
        }
    }
    
    func loadData(){
        //self.lblLocationName.text = self.item.name
        self.lblName.text = self.item.name
        self.lblAddress.text = self.item.address
        self.lblLatLong.text = "\(self.item.latitude!), \(self.item.longitude!)"
    }
    
    @IBAction func btnEditNameTapped(sender: AnyObject) {
        print("Edit Name button tapped")
        self.prepareForUpdate()
    }
    
    func prepareForUpdate(){
        self.txtName.hidden = false
        self.lblName.hidden = true
        self.txtName.text = self.lblName.text
        self.txtName.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Now perform Update action on this user
        self.updateLocation({ (serverResponse) in
            self.txtName.hidden = true
            self.lblName.hidden = false
            self.lblName.text = self.txtName.text
            self.item.name = self.txtName.text
        
            })
        { (error) in
            print("error : \(error)")
            let alert = AlertBox.shareInstance()
            alert.show(title: "Error", message: "\(error)", parentViewController: self)
        }
        
        self.txtName.resignFirstResponder()
        return true
    }
    
    func createWayToThisDestination(locationID: String){
        print("Create way to location with ID: \(locationID)")
    }
    
    func viewLocationOnMap(locationID: String){
        print("View on map location with ID: \(locationID)")
        
        //var mapViewTab = self.tabBarController?.viewControllers![3] as! MapsViewController
        
        let nav = self.tabBarController?.viewControllers![3] as! UINavigationController
        let mapViewTab = nav.topViewController as! MapsViewController
        
        mapViewTab.zoomedLocationId = locationID
        
        tabBarController?.selectedIndex = 3
    }
    
    func viewWayHistoryForLocation(locationID: String){
        print("View way history for location with ID: \(locationID)")
    }
    
    func shareLocationWithFriends(locationID: String){
        print("Share with friends location with ID: \(locationID)")
        // Activate segue
        self.selectedLocationID = locationID
        let locationShareVC = SelectFriendsToShareViewController()
        locationShareVC.toBeSharedLocationID = locationID
        
        self.performSegueWithIdentifier("SelectFriendsSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "SelectFriendsSegue") {
            if let locationShareVC = segue.destinationViewController as? SelectFriendsToShareViewController{
                //let locationShareVC = LocationShareViewControl()
                locationShareVC.toBeSharedLocationID = self.selectedLocationID
            }
        }
    }
    
    
    func deleteLocation(LocationID deletedLocationID: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        
        // Confirm Delete Action
        EZAlertController.alert(StringConstants.ForLocations.confirmLocationDeleteTitle, message: StringConstants.ForLocations.confirmLocationDeleteMsg, buttons: ["Delete","Cancel"], tapBlock: {(alertAction, position) in
            if position == 0 {
                // Show busy icon
                self.view.startBusySpinner()
                
                // Now perform delete action on this user
                DataController.sharedInstance.callDeleteLocationAPI(LocationId: deletedLocationID, success: {serverResponse in            success(responseData: serverResponse)
                    
                    self.view.stopBusySpinner()
                    //self.navigationController?.popViewControllerAnimated(true)
                    })
                { (error) in
                    // Hide busy icon
                    self.view.stopBusySpinner()
                    print("error : \(error)")
                    Utils.showAlertOK(Title: "Error",Message: "\(error)")
                }
            }
            
        })
        
    }
    
    func updateLocation(success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        
        
                // Show busy icon
                self.view.startBusySpinner()
                
                // Now perform delete action on this user
                DataController.sharedInstance.callUpdateLocationAPI(LocationId: self.item.id!,
                    LocationName: self.txtName.text!,
                    LocationAddress: self.item.address!,
                    success: {serverResponse in
                        success(responseData: serverResponse)
                    
                    self.view.stopBusySpinner()
                        self.view.showToast("Location name updated...")
                    //self.navigationController?.popViewControllerAnimated(true)
                    })
                { (error) in
                    // Hide busy icon
                    self.view.stopBusySpinner()
                    print("error : \(error)")
                    Utils.showAlertOK(Title: "Error",Message: "\(error)")
                }
            }
    
    
}
