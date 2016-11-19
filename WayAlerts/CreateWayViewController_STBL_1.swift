//
//  CreateWayViewController.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 16/09/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

//
//  LocationsViewControl.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 22/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import CoreData
import EZAlertController
import DropDown

//var locationToSearch:String = ""

class CreateWayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
    // MARK: - IB Actions and Outlets
    //@IBOutlet weak var txtWayName: UITextField!
    //@IBOutlet weak var txtWayName: UITextField!
    //@IBOutlet weak var btnWaySource: UIButton!
    //@IBOutlet weak var btnWayDestination: UIButton!
    //@IBOutlet weak var lblWaySource: UILabel!
    //@IBOutlet weak var txtWayDestination: UITextField!
    //@IBOutlet weak var txtWayDestination: UITextField!
    

    @IBOutlet weak var createWayTableView: UITableView!
    
//    @IBAction func btnWayDestinationTapped(sender: AnyObject) {
//        self.chooseDestinationsDropDown.show()
//    }
    
    @IBAction func btnCancelTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    @IBAction func btnDoneTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Local Variables
    let chooseDestinationsDropDown = DropDown()
    
    
    // MARK: - Basic UIView FUnctions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
//        // Get handle on the text field of the destination cell
//        let destinationRowIndexPath = NSIndexPath(forRow: 2, inSection: 0)
//        let cell = createWayTableView.cellForRowAtIndexPath(destinationRowIndexPath) as! CreateWayCustomCell
//
//        cell.txtCellTextField.delegate = self
        //self.txtWayDestination.delegate = self
      
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        createWayTableView?.reloadData()
           }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*****************************************************
     UITableViewDatSource functions
     *****************************************************/
    // MARK: - UITableViewDatSource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //return tableContentsArray[section].Title
//        if let sections = fetchedResultsController.sections{
//            let currentSection = sections[section]
//            if(currentSection.name == "0"){
//                return Constants.TableSectionHeaders.LocationRequests
//            } else {
//                return Constants.TableSectionHeaders.LocationsList
//            }
//            return currentSection.name
//        }
        var returnVal = "Way Details"
        if (section == 1){
            returnVal = "Way Details"
        }
        
        return returnVal
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.getCustomCell(AtIndex: indexPath) as! CreateWayCustomCell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return tableContentsArray[section].DisplayItemsBundle.count
//        if let sections = fetchedResultsController.sections{
//            let currentSection = sections[section]
//            return currentSection.numberOfObjects
//        }
        var returnVal = 3
        if (section == 1){
            returnVal = 3
        }
        
        return returnVal
    }

    
    // MARK: - UITableViewDelegate functions
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CreateWayCustomCell
        
        if (indexPath.section == 0){
            // This is the Way Details section
            if (indexPath.row == 2){
                // This is the Way destination row
                self.setupChooseDestinationsDropDown(DestinationTextField: cell.txtCellTextField)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
//        let cellIdentifier = tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
//        let selectedLocationID = item.id!
//        
//        
//        if(cellIdentifier == Constants.LocationCellIdentifiers.CreateWayCell){
//            // This is Create Way action
//            self.createWayToThisDestination(selectedLocationID)
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
//        else if(cellIdentifier == Constants.LocationCellIdentifiers.LocationNameCell){
//            // This is update Location action
//            self.prepareForUpdate()
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
//        else if(cellIdentifier == Constants.LocationCellIdentifiers.ShareWithFriendsCell){
//            // This is Create Way action
//            self.shareLocationWithFriends(selectedLocationID)
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
//        else if(cellIdentifier == Constants.LocationCellIdentifiers.WaysHistoryCell){
//            // This is Create Way action
//            self.viewWayHistoryForLocation(selectedLocationID)
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
//        else if(cellIdentifier == Constants.LocationCellIdentifiers.ViewOnMapCell){
//            // This is Create Way action
//            self.viewLocationOnMap(selectedLocationID)
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
//        else if(cellIdentifier == Constants.LocationCellIdentifiers.DeleteCell){
//            // This is delete action
//            
//            // Confirm Delete Action
//            // Now perform Accept action on this user
//            self.deleteLocation(LocationID: selectedLocationID, success: { (serverResponse) in
//                })
//            { (error) in
//                print("error : \(error)")
//                let alert = AlertBox.shareInstance()
//                alert.show(title: "Error", message: "\(error)", parentViewController: self)
//            }
//            
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if (indexPath.section == 0){
            // This is the Way Details section
            if (indexPath.row == 2){
                // This is the Way destination row
                return indexPath
            }
        }
        
        return nil
        
//        let cellIdentifier = tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
//        
//        if(cellIdentifier == Constants.LocationCellIdentifiers.CreateWayCell ||
//            cellIdentifier == Constants.LocationCellIdentifiers.DeleteCell ||
//            cellIdentifier == Constants.LocationCellIdentifiers.ShareWithFriendsCell ||
//            cellIdentifier == Constants.LocationCellIdentifiers.ViewOnMapCell ||
//            cellIdentifier == Constants.LocationCellIdentifiers.WaysHistoryCell
//            ){
//            return indexPath
//        }else{
//            return nil
//        }
    }

    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
//        // Fetch selected location
//        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Locations
//        
//        selectedLocation = location
        
        // Perform Seque
        performSegueWithIdentifier("ViewDestinationOnMapSegue", sender: self)
    }
    
    // MARK: - UITextFieldDelegate Functions
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.placeholder == "Destination") {
            self.chooseDestinationsDropDown.show()
            textField.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.placeholder == "Name") {
            self.view.endEditing(true)
        }
        return false
    }

    
    // MARK: - Custom Functions
    func getAllSavedLocations() -> [String]{
        return ["Select On Map","Home", "Office","Mall"]
    }
    
    func getCustomCell(AtIndex indexPath: NSIndexPath) -> UITableViewCell{
        // Create an instance of the custom cell
        let cell = createWayTableView.dequeueReusableCellWithIdentifier("WayDetailsCell", forIndexPath: indexPath) as! CreateWayCustomCell
        
        // By default accessory type is hidden and is enabled only for destination cell
        cell.accessoryView?.hidden = true
        cell.accessoryType = .None
        
        var txtCellTextFieldTitle = ""
        var txtCellTextFieldPlaceHolder = ""
        switch indexPath.section {
        case 0:
            // This is the first section: Way Details
            switch indexPath.row {
            case 0:
                //txtCellTextFieldTitle = "Name"
                txtCellTextFieldPlaceHolder = "Name"
                txtCellTextFieldTitle = self.getDefaultWayName()
                cell.txtCellTextField.delegate = self
                cell.txtCellTextField.returnKeyType = .Done
                break
            case 1:
                txtCellTextFieldTitle = "Current Location"
                txtCellTextFieldPlaceHolder = "Source"
                cell.txtCellTextField.enabled = false
                break
            case 2:
                //txtCellTextFieldTitle = "Destination"
                txtCellTextFieldPlaceHolder = "Destination"
                // Get handle on the text field of the destination cell
                cell.txtCellTextField.delegate = self
                cell.txtCellTextField.enabled = true
                cell.accessoryView?.hidden = false
                cell.accessoryType = .DetailButton
                
                self.setupChooseDestinationsDropDown(DestinationTextField: cell.txtCellTextField)
                
                break
            default:
                break
            }
            cell.txtCellTextField.text = txtCellTextFieldTitle
            cell.txtCellTextField.placeholder = txtCellTextFieldPlaceHolder
            break
        default:
            break
        }
        
        return cell
    }
    
    func setupChooseDestinationsDropDown(DestinationTextField destinationTextField: FloatLabelTextField) {
        chooseDestinationsDropDown.anchorView = destinationTextField
        
        // Will set a custom with instead of anchor view width
        //		dropDown.width = 100
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseDestinationsDropDown.bottomOffset = CGPoint(x: 0, y: chooseDestinationsDropDown.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseDestinationsDropDown.dataSource = self.getAllSavedLocations()
        
        // Action triggered on selection
        chooseDestinationsDropDown.selectionAction = { [unowned self] (index, item) in
            destinationTextField.text = item
            
            if (index == 0){
                // Redirect to map if the first option is selected
                self.performSegueWithIdentifier("ViewDestinationOnMapSegue", sender: self)
            }
        }
        
        // Action triggered on dropdown cancelation (hide)
        //		dropDown.cancelAction = { [unowned self] in
        //			// You could for example deselect the selected item
        //			self.dropDown.deselectRowAtIndexPath(self.dropDown.indexForSelectedRow)
        //			self.actionButton.setTitle("Canceled", forState: .Normal)
        //		}
        
        // You can manually select a row if needed
        		chooseDestinationsDropDown.selectRowAtIndex(0)
    }
//
//  
    func getDefaultWayName() -> String {
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
        
        returnVal = "Way@\(hour):\(minute):\(second)_\(day)/\(month)/\(year)"
        
        return returnVal
    }
    
      }
