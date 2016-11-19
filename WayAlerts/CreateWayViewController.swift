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
import CoreLocation

//var locationToSearch:String = ""

class CreateWayViewController: UITableViewController, UITextFieldDelegate, CLLocationManagerDelegate, SelectedFriendsForWayDelegate {
    
    // MARK: - IB Actions and Outlets
    
    // @IBAction func btnWayDestinationTapped(sender: AnyObject) {
    // self.chooseDestinationsDropDown.show()
    // }
    
    @IBAction func btnSelectWayFriendsTapped(sender: AnyObject) {
        let button = sender as! UIButton
        button.titleLabel?.text = "Some Text"
        self.activateSelectFriendsVC()
    }
    @IBOutlet weak var btnSelectWayFriendsTapped: UIButton!
    @IBOutlet weak var txtWayName: FloatLabelTextField!
    @IBOutlet weak var txtWayDestination: FloatLabelTextField!
    @IBOutlet weak var txtVehicleNumber: FloatLabelTextField!
    @IBOutlet weak var cellVehicleNumber: UITableViewCell!
    
    @IBOutlet weak var cellCamera: UITableViewCell!
    
    @IBOutlet weak var cellQRCode: UITableViewCell!
    
    @IBAction func vehicleTypeChanged(sender: AnyObject) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            self.shouldHideVehicleDetailsCells = false
            break
        case 1:
            self.shouldHideVehicleDetailsCells = true
            break
        default:
            break
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func btnCancelTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnDoneTapped(sender: AnyObject) {
        self.createWay()
    }
    
    // MARK: - Local Variables
    let chooseDestinationsDropDown = DropDown()
    var vehicleDetailsCells = [UITableViewCell]()
    var shouldHideVehicleDetailsCells = false
    
    var sectionTitles = Dictionary<Int, String>()
    var rowForSection = Dictionary<Int, Int>()
    var selectedFriendsForWay = [String]()
    // AppDelegate and Core data definitions
    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext = NSManagedObjectContext()
    
    // Variable to hold saved locations: Location name as key and the locations object as the value
    var savedLocations = Dictionary<String, Locations>()
    
    // Location Manager
    let locationManager = CLLocationManager()
    var waLocationManager = WALocationManager.sharedInstance
    
    // MARK: - Basic UIView FUnctions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.txtWayDestination.delegate = self
        self.setupChooseDestinationsDropDown()
        self.txtWayName.delegate = self
        self.txtWayName.returnKeyType = .Done
        self.txtVehicleNumber.delegate = self
        self.txtVehicleNumber.returnKeyType = .Done
        self.txtWayName.text = self.getDefaultWayName()
        
        // Set Core Data properties
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDelegate.managedObjectContext
        
        // Populate default selected friends data
        self.populateDefaultSelectedFriendsData()
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        waLocationManager.startLocationMonitor()
        //waLocationManager = WALocationManager(CallingVC: self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        waLocationManager.stopLocationMonitor()
    }
    override func viewDidAppear(animated: Bool) {
        // Get vehicle details cells
        // self.vehicleDetailsCells = self.getVehicleDetailsCells()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate FUnctions
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        
        if (self.shouldHideVehicleDetailsCells &&
            (section == 1) &&
            (row == 1 || row == 2 || row == 3)) {
            return 0.0
        } else {
            return 50.0
        }
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
    
    // MARK: - Segue functions
    func activateSelectFriendsVC() {
        // Activate segue
        let friendsToShareVC = SelectFriendsToShareViewController()
        friendsToShareVC.isActivatedFromCreateWayVC = true
        
        self.performSegueWithIdentifier("SelectFriendsForWaySegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "SelectFriendsForWaySegue") {
            if let friendsToShareVC = segue.destinationViewController as? SelectFriendsToShareViewController {
                friendsToShareVC.isActivatedFromCreateWayVC = true
                friendsToShareVC.selectedFriendsArray = self.selectedFriendsForWay
                friendsToShareVC.createWayDelegate = self
            }
        }
    }
    
    // MARK: - LocationManager Delegate Functions
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    // MARK: - Custom Functions
    func getAllSavedLocations() -> [String] {
        // Get all saved locationss
        let locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
        let savedLocationArray = locationsAPI.getLocationsWithAcceptStatus(AcceptStatus: "1")
        var savedLocationNames = [String]()
        
        // Append "Select on Map" as the first option
        savedLocationNames.append(StringConstants.ForWays.selectOnMapDropDownOption)
        
        // Populate the saved locations dictionary for future reference
        for aLocation in savedLocationArray {
            if (aLocation.id! != "") {
                self.savedLocations[aLocation.name!] = aLocation
                savedLocationNames.append(aLocation.name!)
            }
        }
        
        return savedLocationNames
    }
    
    func setupChooseDestinationsDropDown() {
        chooseDestinationsDropDown.anchorView = txtWayDestination
        
        // Will set a custom with instead of anchor view width
        // dropDown.width = 100
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseDestinationsDropDown.bottomOffset = CGPoint(x: 0, y: chooseDestinationsDropDown.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseDestinationsDropDown.dataSource = self.getAllSavedLocations()
        
        // Action triggered on selection
        chooseDestinationsDropDown.selectionAction = { [unowned self](index, item) in
            self.txtWayDestination.text = item
            
            if (index == 0) {
                // Redirect to map if the first option is selected
                self.performSegueWithIdentifier("ViewDestinationOnMapSegue", sender: self)
            }
        }
        
        // Action triggered on dropdown cancelation (hide)
        // dropDown.cancelAction = { [unowned self] in
        // // You could for example deselect the selected item
        // self.dropDown.deselectRowAtIndexPath(self.dropDown.indexForSelectedRow)
        // self.actionButton.setTitle("Canceled", forState: .Normal)
        // }
        
        // You can manually select a row if needed
        chooseDestinationsDropDown.selectRowAtIndex(0)
    }
    //
    //
    func initiateTableViewData() {
        sectionTitles[0] = "Way Details"
        sectionTitles[1] = "Vehicle Types"
        
        rowForSection[0] = 3
        rowForSection[1] = 4
    }
    
    func getVehicleDetailsCells() -> [UITableViewCell] {
        let vehicleNumberCell = tableView.dequeueReusableCellWithIdentifier("VehicleNumberCell") as UITableViewCell!
        let cameraCell = tableView.dequeueReusableCellWithIdentifier("CameraCell") as UITableViewCell!
        let qrcodeCell = tableView.dequeueReusableCellWithIdentifier("QRCodeCell") as UITableViewCell!
        return [vehicleNumberCell, cameraCell, qrcodeCell]
    }
    
    func getDefaultWayName() -> String {
        var returnVal = ""
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day, .Month, .Year, .Hour, .Minute, .Second], fromDate: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        var hour = String(components.hour)
        var minute = String(components.minute)
        var second = String(components.second)
        
        if (components.hour < 10) {
            hour = "0\(hour)"
        }
        
        if (components.minute < 10) {
            minute = "0\(minute)"
        }
        
        if (components.second < 10) {
            second = "0\(second)"
        }
        
        returnVal = "Way:\(day)/\(month)/\(year)@\(hour):\(minute):\(second)"
        
        return returnVal
    }
    
    func selectedFriendsForWay(selectedFriends: [String]) {
        print("Hurry..!! Received selected friends data from SelectFriendsVC)")
        self.selectedFriendsForWay = selectedFriends
    }
    
    func createWay() {
        // Show busy icon
        self.view.startBusySpinner()
        
        // Validate form data
        if (!self.validateFormData()) {
            return
        }
        
        // Get form data
        let formData = self.getFormData()
        
        // Now perform create wau action on this user
        DataController.sharedInstance.callCreateWayAPI(WayName: formData["wayName"]!, WaySource: formData["waySource"]!, WayDestination: formData["wayDestination"]!, WayType: formData["wayType"]!, VehicleNumber: formData["vehicleNumber"]!, QrcodeData: formData["qrCodeData"]!, Photo: formData["photo"]!, FnfUserIds: formData["fnfUserIds"]!, success: { serverResponse in
            // Hide busy icon
            self.view.stopBusySpinner()
            self.navigationController?.popViewControllerAnimated(true)
            // self.redirectToMapView()
            })
        { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        }
    }
    
    func getFormData() -> Dictionary<String, String> {
        let wayName = txtWayName.text
        let currentLocation = self.waLocationManager.getLastKnownLocation()
        let waySource = "\(String(currentLocation!.coordinate.latitude)),\(currentLocation!.coordinate.longitude)"
        
        var wayDestination = ""
        
        if (!(txtWayDestination.text!.isEmpty) && (txtWayDestination.text! != StringConstants.ForWays.selectOnMapDropDownOption)) {
            let wayDestinationAsLoc = self.savedLocations[txtWayDestination.text!]
            wayDestination = "\(wayDestinationAsLoc!.latitude!),\(wayDestinationAsLoc!.longitude!)"
        }
        
        let vehicleNumber = txtVehicleNumber.text
        let qrCodeData = "TBD: QRCODE"
        let photo = "TBD: PHOTO"
        let fnfUserIds = self.getSelectedFriendsCSV()
        
        var returnData = Dictionary<String, String>()
        returnData["wayName"] = wayName
        returnData["waySource"] = waySource
        returnData["wayDestination"] = wayDestination
        returnData["vehicleNumber"] = vehicleNumber
        returnData["qrCodeData"] = qrCodeData
        returnData["photo"] = photo
        returnData["fnfUserIds"] = fnfUserIds
        
        if (self.shouldHideVehicleDetailsCells) {
            returnData["wayType"] = "0" // Personal vehicle
        } else {
            returnData["wayType"] = "1" // Hired vehicle
        }
        
        return returnData
    }
    
    func validateFormData() -> Bool {
        let formData = self.getFormData()
        var returnVal = true
        
        if (formData["wayName"]!.isEmpty) {
            self.txtWayName.text = self.getDefaultWayName()
        }
        
        if (formData["wayDestination"]!.isEmpty) {
            EZAlertController.alert("Please select a destination for this way.")
            // Hide busy icon
            self.view.stopBusySpinner()
            returnVal = false
        }
        
        if (formData["fnfUserIds"]!.isEmpty) {
            EZAlertController.alert(StringConstants.ForWays.confirmCreateWayWithNoFriendsTitle, message: StringConstants.ForWays.confirmCreateWayWithNoFriendsMsg, buttons: ["Yes", "No"], tapBlock: { (alertAction, position) in
                if (position != 0) {
                    // Hide busy icon
                    self.view.stopBusySpinner()
                    returnVal = false
                }
            })
        }
        return returnVal
    }
    
    func getSelectedFriendsCSV() -> String {
        var friendsCSV = ""
        for aFriend in self.selectedFriendsForWay {
            if (friendsCSV.isEmpty) {
                friendsCSV = aFriend
            } else {
                friendsCSV = "\(friendsCSV),\(aFriend)"
            }
        }
        return friendsCSV
    }
    
    func populateDefaultSelectedFriendsData() {
        // Get all saved locationss
        let friendsAPI = FriendsAPI(ApplicationDelegate: self.appDelegate)
        let savedFriendsArray = friendsAPI.getFriendsWithAcceptStatus(AcceptStatus: "1")
        
        for aFriend in savedFriendsArray {
            self.selectedFriendsForWay.append(aFriend.userID!)
        }
    }
    
    func redirectToMapView() {
        let nav = self.tabBarController?.viewControllers![3] as! UINavigationController
        let mapViewTab = nav.topViewController as! MapsViewController
        
        // mapViewTab.zoomedLocationId = locationID
        
        tabBarController?.selectedIndex = 3
        // Singleton.sharedInstance.wayID = self.
        // self.tabBarController!.selectedIndex = 3
    }
}
