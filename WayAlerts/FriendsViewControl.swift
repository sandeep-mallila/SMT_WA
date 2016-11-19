//
//  FriendsViewControl.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 22/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import CoreData
import Toast_Swift
import ContactsUI
import EZAlertController

var textToSearch:String = ""

class FriendsViewControl: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate, CNContactPickerDelegate {

    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    //var searchText:String = ""
    @IBOutlet weak var editButton: UIBarButtonItem!
   
    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext = NSManagedObjectContext()
    
    var selection: Friends?
    
    //var delegate: CNContactPickerViewController!
   
    //var busyIcon = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

    
    
    //-->
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let friendsFetchRequest = NSFetchRequest(entityName: EntityTypes.Friends.rawValue)
        let primarySortDescriptor = NSSortDescriptor(key: Friends.Attributes.acceptStatus.rawValue, ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: Friends.Attributes.fullName.rawValue, ascending: true)
        
        friendsFetchRequest.sortDescriptors = [primarySortDescriptor,secondarySortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: friendsFetchRequest, managedObjectContext: self.moc, sectionNameKeyPath: Friends.Attributes.acceptStatus.rawValue, cacheName: nil)
        
        frc.delegate = self
        return frc

    }()
    //--<
    
    var tableContentsArray = [TableSectionData]()
    
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
                return Constants.TableSectionHeaders.FriendRequests
            } else {
                return Constants.TableSectionHeaders.FriendsList
            }
            return currentSection.name
        }
        return nil
    }
    
    // contactPicker delegate method
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        var selectedContact = Dictionary<String,AnyObject>()
        
        
        let fullName = "\(contact.givenName) \(contact.familyName)"
        selectedContact["name"] = fullName
        var phoneNumbersArray = [String]()
        for aPhoneNumber in contact.phoneNumbers{
//            let pLabel = aPhoneNumber.label //_$!<Mobile>!$_
//            let pLabel2 = pLabel.characters.split("<").map(String.init) //[_$!<, Mobile>!$_]
//            let pLabel3 = pLabel2[1].characters.split(">").map(String.init) //[Mobile, >!$_]
//            let phoneLabel = pLabel3[0] //Mobile
            
            let phoneNumber = (aPhoneNumber.value as! CNPhoneNumber).valueForKey("digits") as! String
            phoneNumbersArray.append(phoneNumber)
        }
        selectedContact["phoneNumbers"] = phoneNumbersArray
        
        self.prepareFriendRequest(selectedContact)
    }
    
    // Check to see if a friend already exists in core data with a given phone number
    func isAlreadyFriend(PhoneNumber phoneNumber: String) -> Friends?{
        // Check to see if any of these phone numbers are already saved in core data against a friend.
        let friendsAPI = FriendsAPI(ApplicationDelegate: self.appDelegate)
        let friendAlreadySaved: Friends? = friendsAPI.getFriendByMobileNo(FriendMobileNo: phoneNumber)
        
        return friendAlreadySaved
    }
    
    // Display mobile number selection action sheet, if multiple phone numbers found for a user.
    func prepareFriendRequest(contactDetails: Dictionary<String,AnyObject>){
        let contactName = contactDetails["name"] as! String
        let phoneNumbers = contactDetails["phoneNumbers"] as! [String]
        var selectedPhoneNumber: String = ""
        
        if (phoneNumbers.count > 1){
            let alertTitle = "Select Phone Number"
            let alertMessage = "\(contactName) has got more than one saved contact numbers. Please select the one you wish to use for WayAlerts"
            let optionMenu = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .ActionSheet)
            
            // Add all phone numbers one by one to the action sheet as actions
            for aPhoneNumber in phoneNumbers{
                // Check to see if any of these phone numbers are already saved in core data against a friend.
                let friendAlreadySaved = self.isAlreadyFriend(PhoneNumber: aPhoneNumber)

                if(friendAlreadySaved != nil){
                    //self.sendFriendRequest(MobileNumber: selectedPhoneNumber)
                    let anAction = UIAlertAction(title: "\(aPhoneNumber) (Existing Friend)", style: .Default, handler: nil)
                    anAction.enabled = false
                    optionMenu.addAction(anAction)
                }
                else{
                    let anAction = UIAlertAction(title: aPhoneNumber, style: .Default, handler:
                        {
                            (alert: UIAlertAction!) -> Void in
                            selectedPhoneNumber = aPhoneNumber
                            self.sendFriendRequest(MobileNumber: selectedPhoneNumber)
                    })
                    optionMenu.addAction(anAction)
                }
            }
            
            // Now add cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler:
                {
                    (alert: UIAlertAction!) -> Void in
            })
            optionMenu.addAction(cancelAction)
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }else{
            selectedPhoneNumber = phoneNumbers[0]
            self.sendFriendRequest(MobileNumber: selectedPhoneNumber)
            
//            // Check to see if any of these phone numbers are already saved in core data against a friend.
//            let friendAlreadySaved = self.isAlreadyFriend(PhoneNumber: selectedPhoneNumber)
//            
//            if(friendAlreadySaved != nil){
//                self.sendFriendRequest(MobileNumber: selectedPhoneNumber)
//            }
//            else{
//                let alertTitle = "Friend Already Exists"
//                let alertMessage = "Selected contact \(friendAlreadySaved?.fullName) (\(friendAlreadySaved?.mobileNumber)) already exists in your friends list"
//                let optionMenu = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .ActionSheet)
//        
//                let anAction = UIAlertAction(title: "\(selectedPhoneNumber) (Existing Friend)", style: .Default, handler: nil)
//                anAction.enabled = true
//                optionMenu.addAction(anAction)
//                
//                // Now add cancel action
//                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler:
//                    {
//                        (alert: UIAlertAction!) -> Void in
//                })
//                cancelAction.enabled = true
//                optionMenu.addAction(cancelAction)
//                self.presentViewController(optionMenu, animated: true, completion: nil)
//            }
        }
    }
    
    func sendFriendRequest(MobileNumber mobileNumber: String){
        // Show busy icon
        self.view.startBusySpinner()
        // Now perform Accept action on this user
        DataController.sharedInstance.callAddMemberAPI(MobileNumber: mobileNumber, success: {serverResponse in
            // Hide busy icon
            self.view.stopBusySpinner()
            
            })
        { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error",Message: "\(error)")
        }
    }
    
    @IBAction func inviteFriendAction(sender: AnyObject) {
        // Create CNContactPicker View controller
        let contactPickerViewController = CNContactPickerViewController()
        
        // Set predicates to fetch contacts
        contactPickerViewController.predicateForEnablingContact = NSPredicate(format:"phoneNumbers.@count > 0",argumentArray: nil)
        contactPickerViewController.predicateForSelectionOfContact =  NSPredicate(format:  "phoneNumbers.@count > 0", argumentArray: nil)
        //contactPickerViewController.predicateForSelectionOfProperty = NSPredicate(format: "key == 'phoneNumbers'", argumentArray: nil)
        
        contactPickerViewController.delegate = self
        navigationController?.presentViewController(contactPickerViewController, animated: true, completion: nil)
    }
   
    @IBAction func doEdit(sender: AnyObject) {
        if (self.friendsTableView.editing) {
            editButton.title = "Edit"
            //sender.title = "Edit"
            self.friendsTableView.setEditing(false, animated: true)
        } else {
            //sender.title = "Done"
            editButton.title = "Done"
            self.friendsTableView.setEditing(true, animated: true)
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.getCustomCell(AtIndex: indexPath) as! FriendCustomCell
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
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friends
        var noOfObjectsInSection = 1
        if let sections = fetchedResultsController.sections{
            let currentSection = sections[indexPath.section]
            noOfObjectsInSection = currentSection.numberOfObjects
        }
        if((friend.userID == "") && (noOfObjectsInSection > 1)){
            return 0.0
        } else {
            return 56.0
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let selectedFriend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friends
        if(selectedFriend.acceptStatus == "1"){
            return indexPath
        }
        return nil
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController ) {
        friendsTableView.beginUpdates()
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
                self.friendsTableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case NSFetchedResultsChangeType.Delete:
            // Note that for Delete, we delete the row at __indexPath__
            if let deleteIndexPath = indexPath {
                self.friendsTableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case NSFetchedResultsChangeType.Update:
            if let updateIndexPath = indexPath {
//                // Note that for Update, we update the row at __indexPath__
                let cell = self.friendsTableView.cellForRowAtIndexPath(updateIndexPath)
                let friend = self.fetchedResultsController.objectAtIndexPath(updateIndexPath) as? Friends
                
//                //cell?.textLabel?.text = animal?.commonName
//                //cell?.detailTextLabel?.text = animal?.habitat
            }
        case NSFetchedResultsChangeType.Move:
            // Note that for Move, we delete the row at __indexPath__
            self.friendsTableView.beginUpdates()
            if let deleteIndexPath = indexPath {
                self.friendsTableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
            // Note that for Move, we insert a row at the __newIndexPath__
            if let insertIndexPath = newIndexPath {
                self.friendsTableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
            self.friendsTableView.endUpdates()
        }
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        friendsTableView.endUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Core Data properties
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDelegate.managedObjectContext
        
        // Create default friends data
        let friendsAPI = FriendsAPI(ApplicationDelegate: self.appDelegate)
        friendsAPI.addDefaultFriendsData()
        
        //self.friendsAPI = FriendsAPI(appDelegate: self.appDelegate,ManagedObjectContext: self.moc)
        
        //-->
        do{
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occured")
        }
        
        //friendsTableView.tableFooterView = UIView(frame: .zero)
        //--<
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.performDataFetch()
        friendsTableView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.friendsTableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
//    }
//    
//    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        self.friendsTableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
//    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friends
        if (friend.acceptStatus == "1"){
            return true
        }
        else{
            return false
        }
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
            let friendForRow = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Friends
            
            // Now perform Accept action on this user
            self.deleteFriend(DeletedFriendID: friendForRow.userID!, success: { (serverResponse) in
                //self.view.makeToast("Friend Request Accepted...")
                })
            { (error) in
                print("error : \(error)")
                let alert = AlertBox.shareInstance()
                alert.show(title: "Error", message: "\(error)", parentViewController: self)
            }
        }
    }
    
    func performDataFetch(){
        do{
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occured")
        }
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        // Fetch Friend
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friends
        
        selection = friend
        
        // Perform Seque
        performSegueWithIdentifier("FriendDetailsViewController", sender: self)
        //let controller = storyboard?.instantiateViewControllerWithIdentifier("FriendDetailsViewController")
        //self.navigationController!.pushViewController(controller!, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "FriendDetailsViewController") {
//            if let friendDetailsViewController = segue.destinationViewController as? FriendDetailsViewController, let item = selection {
//                //friendDetailsViewController.delegate = self
//                friendDetailsViewController.item = item
//            }
//        }
        if (segue.identifier == "FriendDetailsViewController") {
            if let friendDetailsViewController = segue.destinationViewController as? FriendDetailsViewController{
                let selectedFriend: Friends
                if(selection == nil){
                    let selectedIndexPath = friendsTableView.indexPathForSelectedRow
                    selectedFriend = fetchedResultsController.objectAtIndexPath(selectedIndexPath!) as! Friends
                }else{
                    selectedFriend = selection!
                }
                
                friendDetailsViewController.item = selectedFriend
            }
        }
    }
    
    func getCustomCell(AtIndex indexPath: NSIndexPath) -> UITableViewCell{
        
        //-->
        let cell = friendsTableView.dequeueReusableCellWithIdentifier("ActiveFriend", forIndexPath: indexPath) as! FriendCustomCell
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friends
        
        cell.lblUserName?.text = friend.fullName
        cell.blUserMobile?.text = friend.mobileNumber
        cell.imgUserPic?.image = UIImage(named:"Avatar-Small")
        cell.imgUserPic?.hidden = false
        cell.blUserMobile?.hidden = false
        cell.lblPending?.hidden = true
        cell.accessoryType = .None
        cell.accessoryView?.hidden = true
        
        //cell.btnDetailDisclosure?.hidden = true
        
        // Set hidden status of Confirm/Reject buttons
        //if((indexPath.section != 0) || (friend.userID == "")) { // Hide Accept/Reject buttons if this is not requests section or if there are no friend requests to be displayed here.
        if(friend.acceptStatus == "1") {
            cell.btnAccept.hidden = true
            cell.btnReject.hidden = true
            cell.accessoryView?.hidden = false
            cell.accessoryType = .DetailButton
            
            //cell.btnDetailDisclosure?.hidden = false
        }else{
            // Set cell tag and target
            if (friend.isRequestInitiator == "0"){
                // If friend is not the request initiator, display pending lable
                cell.lblPending.hidden = false
                cell.btnAccept.hidden = true
                cell.btnReject.hidden = true
                //cell.accessoryView?.hidden = true
                //cell.accessoryType = .None
            } else {
                // If friend is the request initiator, display Accept/Reject buttons
                cell.accessoryView?.hidden = false
                cell.btnAccept.hidden = false
                cell.btnReject.hidden = false
                cell.btnAccept.tag = indexPath.row
                cell.btnAccept.addTarget(self,action:#selector(FriendsViewControl.acceptRequestAction(_:)), forControlEvents: .TouchUpInside)
                cell.btnReject.tag = indexPath.row
                cell.btnReject.addTarget(self,action:#selector(FriendsViewControl.rejectRequestAction(_:)), forControlEvents: .TouchUpInside)
            }
        }
        
        // Hide Accept/Reject buttons, User Profile image, Mobile number, if this is not requests section or if there are no friend requests to be displayed here.
        if(friend.userID == ""){
            cell.btnAccept.hidden = true
            cell.btnReject.hidden = true
            cell.imgUserPic.hidden = true
            cell.blUserMobile.hidden = true
            cell.lblPending?.hidden = true
            cell.accessoryView?.hidden = true
        }
        
        // Do not display this cell if this is the only cell in this section
        var noOfObjectsInSection = 1
        if let sections = fetchedResultsController.sections{
            let currentSection = sections[indexPath.section]
            noOfObjectsInSection = currentSection.numberOfObjects
        }
        if((friend.userID == "") && (noOfObjectsInSection > 1)){
            cell.hidden = true
        }
        
//        if cell.selected
//        {
//            cell.selected = false
//            if cell.accessoryType == UITableViewCellAccessoryType.None
//            {
//                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
//            }
//            else
//            {
//                cell.accessoryType = UITableViewCellAccessoryType.None
//            }
//        }
    
        return cell
        //--<
    }
    
    @IBAction func acceptRequestAction(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let selectedFriend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friends
        
        //let selectedRow = tableContentsArray[0].DisplayItemsBundle[sender.tag]
        let selectedUserID = selectedFriend.userID!
        
        // Now perform Accept action on this user
        self.performRequestAction(selectedUserID, ActionVal: "1", success: { (serverResponse) in
            })
        { (error) in
            print("error : \(error)")
            let alert = AlertBox.shareInstance()
            alert.show(title: "Error", message: "\(error)", parentViewController: self)
        }
        
    }
    
    func performRequestAction(selectedUserID: String, ActionVal actionVal: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        // Show busy icon
        self.view.startBusySpinner()
        
        // Now perform Accept action on this user
        DataController.sharedInstance.callFnfRequestActionAPI(FnfID: selectedUserID, ActionVal: actionVal, success: {serverResponse in
            success(responseData: serverResponse)
            
            // Hide busy icon
            self.view.stopBusySpinner()
            
            })
        { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error",Message: "\(error)")
        }

    }

    @IBAction func rejectRequestAction(sender: UIButton) {
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        let selectedFriend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friends
        
        //let selectedRow = tableContentsArray[0].DisplayItemsBundle[sender.tag]
        let selectedUserID = selectedFriend.userID!
        
        // Now perform Accept action on this user
        self.performRequestAction(selectedUserID, ActionVal: "0", success: { (serverResponse) in
            })
        { (error) in
            print("error : \(error)")
            let alert = AlertBox.shareInstance()
            alert.show(title: "Error", message: "\(error)", parentViewController: self)
        }

    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //print("Search text is \(searchText)")
        textToSearch = searchText
        if (searchText != ""){
            self.fetchedResultsController.fetchRequest.predicate = textToSearch.characters.count > 0 ?
                NSPredicate(format:"\(Friends.Attributes.fullName.rawValue) contains[cd] %@ OR \(Friends.Attributes.mobileNumber.rawValue) contains[cd] %@", searchText, searchText) : nil
            try! self.fetchedResultsController.performFetch()
            friendsTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.fetchedResultsController.fetchRequest.predicate = nil
        try! self.fetchedResultsController.performFetch()
        friendsTableView.reloadData()
    }
    
    func deleteFriend(DeletedFriendID deletedFriendID: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        // Show busy icon
        self.view.startBusySpinner()
        
        // Now perform delete action on this user
        DataController.sharedInstance.callDeleteFNFAPI(DeletedFriendID: deletedFriendID, success: {serverResponse in
                success(responseData: serverResponse)
            
            self.view.stopBusySpinner()
            //self.view.showToast("Friend Deleted...")
                })
            { (error) in
                // Hide busy icon
                self.view.stopBusySpinner()
                print("error : \(error)")
                Utils.showAlertOK(Title: "Error",Message: "\(error)")
            }
        }
    
}