//
//  LocationShareViewController.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 10/09/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import CoreData
import Toast_Swift
import ContactsUI
import EZAlertController

//var textToSearch:String = ""

class LocationShareViewControl: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate, CNContactPickerDelegate {
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    //var searchText:String = ""
    //@IBOutlet weak var editButton: UIBarButtonItem!
    
    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext = NSManagedObjectContext()
    
    var selectedFriendsToShareLocation: [String] = []
    var toBeSharedLocationID: String = ""
    var isActivatedFromCreateWayVC = false
    
    var selection: Friends?
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let friendsFetchRequest = NSFetchRequest(entityName: EntityTypes.Friends.rawValue)
        let primarySortDescriptor = NSSortDescriptor(key: Friends.Attributes.acceptStatus.rawValue, ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: Friends.Attributes.fullName.rawValue, ascending: true)
        
        friendsFetchRequest.sortDescriptors = [primarySortDescriptor,secondarySortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: friendsFetchRequest, managedObjectContext: self.moc, sectionNameKeyPath: Friends.Attributes.acceptStatus.rawValue, cacheName: nil)
        
        let predicate = NSPredicate(format: "\(Friends.Attributes.acceptStatus.rawValue) = %@","1")
        frc.fetchRequest.predicate = predicate
        
        frc.delegate = self
        return frc
        
    }()
    
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = friendsTableView.dequeueReusableCellWithIdentifier("SharableFriendCell", forIndexPath: indexPath)
        let friend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friends
        
        cell.textLabel?.text = friend.fullName
        cell.detailTextLabel?.text = friend.mobileNumber
        //cell.imageView?.image = friend.profileImage

        cell.accessoryType = .None
        return cell
       
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.friendsTableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        // Add this friend user id to the selected friends array
        let selectedFriend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friends
        self.selectedFriendsToShareLocation.append(selectedFriend.userID!)
    }
    
    
    @IBAction func btnShareTapped(sender: AnyObject) {
        // Now perform Accept action on this user
        self.shareLocationWithSelectedFriends({serverResponse in
            // Hide busy icon
            //self.view.stopBusySpinner()
            self.navigationController?.popViewControllerAnimated(true)
            
            })
        { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error",Message: "\(error)")
        }
    }
    
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.friendsTableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
        
        // Remove this friend user id from the selected friends array
        let selectedFriend = fetchedResultsController.objectAtIndexPath(indexPath) as! Friends
        let selectedFriendsArrayIndex = self.selectedFriendsToShareLocation.indexOf(selectedFriend.userID!)
        self.selectedFriendsToShareLocation.removeAtIndex(selectedFriendsArrayIndex!)
    }
    
    func shareLocationWithSelectedFriends(success : (responseData : String)->(), failure : (error : NSError)->()) {
        
        let selectedFriendsCSVString = self.getSelectedFriendsCSVString()
        if (selectedFriendsCSVString.isEmpty){
            return
        }
        
        // Show busy icon
        self.view.startBusySpinner()
        
        // Now perform delete action on this user
        DataController.sharedInstance.callShareLocationAPI(LocationId: self.toBeSharedLocationID, SelectedFriendsString: selectedFriendsCSVString, success: {serverResponse in success(responseData: "")
            
            self.view.stopBusySpinner()
            self.view.showToast("Location shared...")
            })
            
        { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error",Message: "\(error)")
        }
    }
    
    func getSelectedFriendsCSVString() -> String{
        var selectedFriendsCSVString = ""
        for aFrendUserID in self.selectedFriendsToShareLocation{
            if (selectedFriendsCSVString.isEmpty){
                selectedFriendsCSVString = aFrendUserID
            }else{
                selectedFriendsCSVString = "\(selectedFriendsCSVString),\(aFrendUserID)"
            }
        }
        return selectedFriendsCSVString
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Core Data properties
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDelegate.managedObjectContext
        
        // Create default friends data
        let friendsAPI = FriendsAPI(ApplicationDelegate: self.appDelegate)
        friendsAPI.addDefaultFriendsData()
        
        // Allow multi select
        self.friendsTableView.allowsMultipleSelection = true
        
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
    
    func performDataFetch(){
        do{
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occured")
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //print("Search text is \(searchText)")
        textToSearch = searchText
        if (searchText != ""){
            self.fetchedResultsController.fetchRequest.predicate = textToSearch.characters.count > 0 ?
                NSPredicate(format:"\(Friends.Attributes.acceptStatus.rawValue) = %@ AND (\(Friends.Attributes.fullName.rawValue) contains[cd] %@ OR \(Friends.Attributes.mobileNumber.rawValue) contains[cd] %@)", "1", searchText, searchText) : nil
            
            // Only get friends that have accepted status = 1
            //let predicate = NSPredicate(format: "\(Friends.Attributes.acceptStatus.rawValue) = %@","1")
            //self.fetchedResultsController.fetchRequest.predicate = predicate
            
            try! self.fetchedResultsController.performFetch()
            friendsTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        //self.fetchedResultsController.fetchRequest.predicate = nil
        let predicate = NSPredicate(format: "\(Friends.Attributes.acceptStatus.rawValue) = %@","1")
        self.fetchedResultsController.fetchRequest.predicate = predicate

        try! self.fetchedResultsController.performFetch()
        friendsTableView.reloadData()
    }
    
}