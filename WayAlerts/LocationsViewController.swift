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

var locationToSearch:String = ""

class LocationsViewControl: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
 
    /*****************************************************
     UI Outlets from the Storyboard
     *****************************************************/
    // MARK: - UI Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var locationsTableView: UITableView!
    
    /*****************************************************
     AppDelegate and core data definitions
     *****************************************************/
    // MARK: - AppDelegate and Core data definitions
    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext = NSManagedObjectContext()
    
    /*****************************************************
     Other Local variables
     *****************************************************/
    // MARK: - Local static variables
    var selectedLocation: Locations?
    var tableContentsArray = [TableSectionData]()
    
    /*****************************************************
     Fetched Results Controller Definition
     *****************************************************/
    // MARK: - Fetched results controller definition
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let locationsFetchRequest = NSFetchRequest(entityName: EntityTypes.Locations.rawValue)
        let primarySortDescriptor = NSSortDescriptor(key: Locations.Attributes.acceptStatus.rawValue, ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: Locations.Attributes.name.rawValue, ascending: true)
        
        locationsFetchRequest.sortDescriptors = [primarySortDescriptor,secondarySortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: locationsFetchRequest, managedObjectContext: self.moc, sectionNameKeyPath: Locations.Attributes.acceptStatus.rawValue, cacheName: nil)
        
        frc.delegate = self
        return frc
        
    }()
    
    /*****************************************************
     UI View base functions
     *****************************************************/
    // MARK: - UIView base functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Core Data properties
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDelegate.managedObjectContext
        
        // Create default locations data
        let locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
        locationsAPI.addDefaultLocationsData()
        
        // Fetch data into fetchedResultsCOntroller
        do{
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occured")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.performDataFetch()
        locationsTableView?.reloadData()
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
        //return tableContentsArray.count
        if let sections = fetchedResultsController.sections{
            return sections.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //return tableContentsArray[section].Title
        if let sections = fetchedResultsController.sections{
            let currentSection = sections[section]
            if(currentSection.name == "0"){
                return Constants.TableSectionHeaders.LocationRequests
            } else {
                return Constants.TableSectionHeaders.LocationsList
            }
            return currentSection.name
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.getCustomCell(AtIndex: indexPath) as! LocationCustomCell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return tableContentsArray[section].DisplayItemsBundle.count
        if let sections = fetchedResultsController.sections{
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Locations
        var noOfObjectsInSection = 1
        if let sections = fetchedResultsController.sections{
            let currentSection = sections[indexPath.section]
            noOfObjectsInSection = currentSection.numberOfObjects
        }
        if((location.id == "") && (noOfObjectsInSection > 1)){
            return 0.0
        } else {
            return 56.0
        }
    }
    
    
    /*****************************************************
     UITableViewDelegate functions
     *****************************************************/
    // MARK: - UITableViewDelegate functions
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let selectedLocation = fetchedResultsController.objectAtIndexPath(indexPath) as! Locations
        if(selectedLocation.acceptStatus == "1"){
            return indexPath
        }
        return nil
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        //        if (self.friendsTableView.editing) {
        //            return UITableViewCellEditingStyle.Delete;
        //        }
        //
        //        return UITableViewCellEditingStyle.None;
        return UITableViewCellEditingStyle.Delete;
    }
    
    func tableView(tableView: UITableView, commitEditingStyle  editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:   NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //delete row at selected index
            let locationForRow = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Locations
            
            // Now perform Accept action on this user
            self.deleteLocation(DeletedLocationID: locationForRow.id!, success: { (serverResponse) in
                //self.view.makeToast("Friend Request Accepted...")
                })
            { (error) in
                print("error : \(error)")
                let alert = AlertBox.shareInstance()
                alert.show(title: "Error", message: "\(error)", parentViewController: self)
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Locations
        if (location.acceptStatus == "1"){
            return true
        }
        else{
            return false
        }
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        // Fetch selected location
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Locations
        
        selectedLocation = location
        
        // Perform Seque
        performSegueWithIdentifier(Constants.SegueIdentifiers.LocationDetailsViewController, sender: self)
    }
    
    /*****************************************************
     Fetched Results Controller functions
     *****************************************************/
    // MARK: - FetchedReusltsController delegate functions
    
    func controllerWillChangeContent(controller: NSFetchedResultsController ) {
        locationsTableView.beginUpdates()
    }
    
    public func controller(
        controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
                        atIndexPath indexPath: NSIndexPath?,
                                    forChangeType type: NSFetchedResultsChangeType,
                                                  newIndexPath: NSIndexPath?) {
        
        switch type {
        case NSFetchedResultsChangeType.Insert:
            // Note that for Insert, we insert a row at the __newIndexPath__
            if let insertIndexPath = newIndexPath {
                self.locationsTableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case NSFetchedResultsChangeType.Delete:
            // Note that for Delete, we delete the row at __indexPath__
            if let deleteIndexPath = indexPath {
                self.locationsTableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case NSFetchedResultsChangeType.Update:
            if let updateIndexPath = indexPath {
                //                // Note that for Update, we update the row at __indexPath__
                let cell = self.locationsTableView.cellForRowAtIndexPath(updateIndexPath)
                let location = self.fetchedResultsController.objectAtIndexPath(updateIndexPath) as? Locations
                
                //                //cell?.textLabel?.text = animal?.commonName
                //                //cell?.detailTextLabel?.text = animal?.habitat
            }
        case NSFetchedResultsChangeType.Move:
            // Note that for Move, we delete the row at __indexPath__
            self.locationsTableView.beginUpdates()
            if let deleteIndexPath = indexPath {
                self.locationsTableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
            // Note that for Move, we insert a row at the __newIndexPath__
            if let insertIndexPath = newIndexPath {
                self.locationsTableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            self.locationsTableView.endUpdates()
        }
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        locationsTableView.endUpdates()
    }
    
    /*****************************************************
     Custom IBAction functions
     *****************************************************/
    // MARK: - Custom IBActions functions
    
    @IBAction func acceptRequestAction(sender: AnyObject) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let selectedLocation = fetchedResultsController.objectAtIndexPath(indexPath) as! Locations
        let selectedLocID = selectedLocation.id!
        
        // Now perform Accept action on this user
        let locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
        locationsAPI.acceptLocationRequest(LocationID: selectedLocID)
    }
    
    
    @IBAction func rejectRequestAction(sender: AnyObject) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let selectedLocation = fetchedResultsController.objectAtIndexPath(indexPath) as! Locations
        let selectedLocID = selectedLocation.id!
        
        
        // Now perform reject action on this user
        let locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
        locationsAPI.rejectLocationRequest(LocationID: selectedLocID)
        
    }
    
    @IBAction func doEdit(sender: AnyObject) {
        if (self.locationsTableView.editing) {
            editButton.title = "Edit"
            //sender.title = "Edit"
            self.locationsTableView.setEditing(false, animated: true)
        } else {
            //sender.title = "Done"
            editButton.title = "Done"
            self.locationsTableView.setEditing(true, animated: true)
        }
    }
    
    /*****************************************************
     UISearchBarDelegate functions
     *****************************************************/
    // MARK: - UISearchBarDelegate Functions
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //print("Search text is \(searchText)")
        locationToSearch = searchText
        if (searchText != ""){
            self.fetchedResultsController.fetchRequest.predicate = locationToSearch.characters.count > 0 ?
                NSPredicate(format:"\(Locations.Attributes.name.rawValue) contains[cd] %@ OR \(Locations.Attributes.address.rawValue) contains[cd] %@", searchText, searchText) : nil
            try! self.fetchedResultsController.performFetch()
            locationsTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.fetchedResultsController.fetchRequest.predicate = nil
        try! self.fetchedResultsController.performFetch()
        locationsTableView.reloadData()
    }
    
    /*****************************************************
     Custom Functions functions
     *****************************************************/
    // MARK: - Custom Functions
    
    func fetchLocationRequestsSectionData(){
        // Get all location requests from local db
        let locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
        let locRequestsArray = locationsAPI.getLocationsWithAcceptStatus(AcceptStatus: "0")
        var locReqsSectionContents = [TableRowItem]()
        
        // Check to see if no requests avalable, then create an empty one to display a user message
        let locReqsCount = locRequestsArray.count
        if ( locReqsCount == 0){
            let rowItem = TableRowItem()
            rowItem.LabelText = StringConstants.noLocationRequestsMsg
            rowItem.DetailLabelText = ""
            locReqsSectionContents.append(rowItem)
        }else {
            // Loop through each of the location and add it to the display tree
            for aLocRequest in locRequestsArray{
                let rowItem = TableRowItem()
                rowItem.LabelText = aLocRequest.name!
                rowItem.DetailLabelText = aLocRequest.address!
                locReqsSectionContents.append(rowItem)
            }
        }
        
        let locReqsSectionData = TableSectionData(Title: Constants.TableSectionHeaders.LocationRequests+" (\(locReqsCount))",ContentsArray: locReqsSectionContents)
        tableContentsArray.append(locReqsSectionData)
    }
    
    func performDataFetch(){
        do{
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occured")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == Constants.SegueIdentifiers.LocationDetailsViewController) {
            if let locationDetailsViewController = segue.destinationViewController as? LocationDetailsViewController{
                let selectedLocationItem: Locations
                if(selectedLocation == nil){
                    let selectedIndexPath = locationsTableView.indexPathForSelectedRow
                    selectedLocationItem = fetchedResultsController.objectAtIndexPath(selectedIndexPath!) as! Locations
                }else{
                    selectedLocationItem = selectedLocation!
                }
                
                locationDetailsViewController.item = selectedLocationItem
            }
        }
    }
    
    func fetchLocationsListSectionData(){
        // Get all saved locations from local db
        let locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
        let locListsArray = locationsAPI.getLocationsWithAcceptStatus(AcceptStatus: "1")
        var locListsSectionContents = [TableRowItem]()
        
        let locListsCount = locListsArray.count
        if ( locListsCount == 0){
            let rowItem = TableRowItem()
            rowItem.LabelText = StringConstants.noSavedLocationsMsg
            rowItem.DetailLabelText = ""
            locListsSectionContents.append(rowItem)
        }else {
            // Loop through each of the location and add it to the display tree
            for aLocRequest in locListsArray{
                let rowItem = TableRowItem()
                rowItem.LabelText = aLocRequest.name!
                rowItem.DetailLabelText = aLocRequest.address!
                locListsSectionContents.append(rowItem)
            }
        }
        let locListsSectionData = TableSectionData(Title: Constants.TableSectionHeaders.LocationsList+" (\(locListsCount))",ContentsArray: locListsSectionContents)
        tableContentsArray.append(locListsSectionData)
    }
    
    func fetchLocationsViewData(){
        self.fetchLocationRequestsSectionData()
        self.fetchLocationsListSectionData()
    }
    
    func deleteLocation(DeletedLocationID deletedLocationID: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        
        //-->
        // Confirm Delete Action
        EZAlertController.alert(StringConstants.ForLocations.confirmLocationDeleteTitle, message: StringConstants.ForLocations.confirmLocationDeleteMsg, buttons: ["Delete","Cancel"], tapBlock: {(alertAction, position) in
            if position == 0 {
                // Now perform Accept action on this user
                // Show busy icon
                self.view.startBusySpinner()
                
                // Now perform delete action on this user
                DataController.sharedInstance.callDeleteLocationAPI(LocationId: deletedLocationID,  success: {serverResponse in
                    success(responseData: serverResponse)
                    
                    self.view.stopBusySpinner()
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
    
    
    func getCustomCell(AtIndex indexPath: NSIndexPath) -> UITableViewCell{
        let cell = locationsTableView.dequeueReusableCellWithIdentifier("LocationsCell", forIndexPath: indexPath) as! LocationCustomCell
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Locations
        
        cell.lblLocName?.text = location.name
        cell.lblLocAddress?.text = location.address
        
        cell.lblLocName?.hidden = false
        cell.lblLocAddress?.hidden = false
        cell.lblPending?.hidden = true
        cell.accessoryType = .None
        cell.accessoryView?.hidden = true
        
        //cell.btnDetailDisclosure?.hidden = true
        
        // Set hidden status of Confirm/Reject buttons
        //if((indexPath.section != 0) || (friend.userID == "")) { // Hide Accept/Reject buttons if this is not requests section or if there are no friend requests to be displayed here.
        if(location.acceptStatus == "1") {
            cell.btnAccept.hidden = true
            cell.btnReject.hidden = true
            cell.accessoryView?.hidden = false
            cell.accessoryType = .DetailButton
            
            //cell.btnDetailDisclosure?.hidden = false
        }else{
            
            // If friend is the request initiator, display Accept/Reject buttons
            cell.accessoryView?.hidden = false
            cell.btnAccept.hidden = false
            cell.btnReject.hidden = false
            cell.btnAccept.tag = indexPath.row
            cell.btnAccept.addTarget(self,action:#selector(LocationsViewControl.acceptRequestAction(_:)), forControlEvents: .TouchUpInside)
            cell.btnReject.tag = indexPath.row
            cell.btnReject.addTarget(self,action:#selector(LocationsViewControl.rejectRequestAction(_:)), forControlEvents: .TouchUpInside)
        }
        
        // Hide Accept/Reject buttons, User Profile image, Mobile number, if this is not requests section or if theßre are no friend requests to be displayed here.
        if(location.id == ""){
            cell.btnAccept.hidden = true
            cell.btnReject.hidden = true
            cell.lblPending?.hidden = true
            cell.accessoryView?.hidden = true
        }
        
        // Do not display this cell if this is the only cell in this section
        var noOfObjectsInSection = 1
        if let sections = fetchedResultsController.sections{
            let currentSection = sections[indexPath.section]
            noOfObjectsInSection = currentSection.numberOfObjects
        }
        if((location.id == "") && (noOfObjectsInSection > 1)){
            cell.hidden = true
        }
        
        return cell
    }
}
