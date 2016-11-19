//
//  FriendsAPI.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 22/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

/**
 User API contains the endpoints to Create/Read/Update/Delete User.
 */
class FriendsAPI {
    
    let appDelegate: AppDelegate
    let managedObjectContext: NSManagedObjectContext
    
    //Utilize Singleton pattern by instanciating FriendAPI only once.
    //    class var sharedInstance: FriendsAPI {
    //        struct Singleton {
    //            static let instance = FriendsAPI()
    //        }
    //
    //        return Singleton.instance
    //    }
    
    init(ApplicationDelegate appDelegate: AppDelegate){
        self.appDelegate = appDelegate
        self.managedObjectContext = self.appDelegate.managedObjectContext
    }
    
    func saveMOC(){
        do{
        try self.managedObjectContext.save()
        }
        catch let nserror as NSError {
            //fatalError("Eor saving MOC:")
        print("Error saving MOC: \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: Create
    
    func createNewFriend(friendDetails: Dictionary<String,String>) {
        //Create new Object of Friend entity
        let friendItem = NSEntityDescription.insertNewObjectForEntityForName(EntityTypes.Friends.rawValue,
                                                                             inManagedObjectContext: self.managedObjectContext) as! Friends;
        
        // Assign values to each attribute of User entity
        friendItem.userID = friendDetails[Friends.Attributes.userID.rawValue]
        friendItem.acceptStatus = friendDetails[Friends.Attributes.acceptStatus.rawValue]
        friendItem.allowAlertsIn = friendDetails[Friends.Attributes.allowAlertsIn.rawValue]
        friendItem.allowAlertsOut = friendDetails[Friends.Attributes.allowAlertsOut.rawValue]
        friendItem.fullName = friendDetails[Friends.Attributes.fullName.rawValue]
        friendItem.isRequestInitiator = friendDetails[Friends.Attributes.isRequestInitiator.rawValue]
        friendItem.mobileNumber = friendDetails[Friends.Attributes.mobileNumber.rawValue]
        
        
        //Save current work on Minion workers
        //self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
        
        //Save and merge changes from Minion workers with Main context
        //self.persistenceManager.mergeWithMainContext()
        self.saveMOC()
    }
    
    // Get friends
    func getFriendsWithAcceptStatus(AcceptStatus acceptStatus: String) -> Array<Friends> {
        var fetchedResults:Array<Friends> = Array<Friends>()
        
        // Create request on Friends entity
        let fetchRequest = NSFetchRequest(entityName: EntityTypes.Friends.rawValue)
        
        //Add a predicate to filter by userId
        let findByAcceptStatusPredicate =
            NSPredicate(format: "\(Friends.Attributes.acceptStatus) = %@", acceptStatus)
        fetchRequest.predicate = findByAcceptStatusPredicate
        
        //Execute Fetch request
        do {
            fetchedResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Friends]
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<Friends>()
        }
        return fetchedResults
    }
    
    // Get Friend By ID
    func getFriendByID(FriendUserID friendUserID: String) -> Friends {
        var fetchedResults: Friends;
        
        // Create request on Friends entity
        let fetchRequest = NSFetchRequest(entityName: EntityTypes.Friends.rawValue)
        
        //Add a predicate to filter by userId
        let findByUserIDPredicate =
            NSPredicate(format: "\(Friends.Attributes.userID) = %@", friendUserID)
        fetchRequest.predicate = findByUserIDPredicate
        
        //Execute Fetch request
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Friends]
            if(result.count > 0){
                fetchedResults = result[0]
            }else{
                fetchedResults = Friends()
            }
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Friends()
        }
        return fetchedResults
    }
    
    // Get Friend By ID
    func getFriendByMobileNo(FriendMobileNo friendMobileNo: String) -> Friends? {
        var fetchedResults: Friends;
        
        // Create request on Friends entity
        let fetchRequest = NSFetchRequest(entityName: EntityTypes.Friends.rawValue)
        
        //Add a predicate to filter by userId
        let findByUserIDPredicate =
            NSPredicate(format: "\(Friends.Attributes.mobileNumber) = %@", friendMobileNo)
        fetchRequest.predicate = findByUserIDPredicate
        
        //Execute Fetch request
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Friends]
            if(result.count > 0){
             fetchedResults = result[0]
                return fetchedResults
            }else{
                return nil;
            }
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            return nil;
        }
    }
    
    // Accept Friend Request: Called when a user (secondary user) accepts friend request sent to him by his friend (primary user).
    func acceptFriendRequest(FriendUserID friendUserID: String) {
        
        // Get friend record with this id
        let fetchedFriend = self.getFriendByID(FriendUserID: friendUserID)
        // Update acceptStatus to 1
        //fetchedFriend.setValue("1", forKey: Friends.Attributes.acceptStatus.rawValue)
        fetchedFriend.acceptStatus = "1"
        
        self.saveMOC()
    }
    
    // Mark Friend Request as Accepted: Called when an invite sent by this user (primary user) has been accepted by his friend (secondary user)
    func markInviteAsFriendAccepted(AcceptedFriendUserID acceptedFriendUserID: String) {
        
        // Get friend record with this id
        let fetchedFriend = self.getFriendByID(FriendUserID: acceptedFriendUserID)
        // Update acceptStatus to 1
        //fetchedFriend.setValue("1", forKey: Friends.Attributes.acceptStatus.rawValue)
        fetchedFriend.acceptStatus = "1"
        
        self.saveMOC()
    }
    
    // Add default data to the friend to be displayed when there ino data to be displayed
    func addDefaultFriendsData(){
        
        // Check to see default data already exists in the core data
        var fetchedResults: [Friends];
        let friendUserID = "" // User ID will be "" for default data
        
        // Create request on Friends entity
        let fetchRequest = NSFetchRequest(entityName: EntityTypes.Friends.rawValue)
        
        //Add a predicate to filter by userId
        let findByUserIDPredicate =
            NSPredicate(format: "\(Friends.Attributes.userID) = %@", friendUserID)
        fetchRequest.predicate = findByUserIDPredicate
        
        //Execute Fetch request
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Friends]
            fetchedResults = result
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = [Friends]()
        }

        if (fetchedResults.count != 2){
            // Delete all the friend records and recreate from scratch
            for aFriend in fetchedResults{
                self.deleteFriend(aFriend)
            }
        
            // Add Friend Requests section header
            var friendDetails = Dictionary<String,String>()
            
            friendDetails[Friends.Attributes.userID.rawValue] = ""
            friendDetails[Friends.Attributes.acceptStatus.rawValue] = "0"
            friendDetails[Friends.Attributes.allowAlertsIn.rawValue] = "0"
            friendDetails[Friends.Attributes.allowAlertsOut.rawValue] = "0"
            friendDetails[Friends.Attributes.fullName.rawValue] = StringConstants.noFriendRequestsMsg
            friendDetails[Friends.Attributes.isRequestInitiator.rawValue] = "0"
            friendDetails[Friends.Attributes.mobileNumber.rawValue] = "1111111111"
            
            // Create the friend
            self.createNewFriend(friendDetails)
            
            // Now create saved friends default data
            friendDetails[Friends.Attributes.acceptStatus.rawValue] = "1"
            friendDetails[Friends.Attributes.fullName.rawValue] = StringConstants.noSavedFriendsMsg
            
            // Create the friend
            self.createNewFriend(friendDetails)
           
        }
        
    }
    
    // Reject Friend Request
    func rejectFriendRequest(FriendUserID friendUserID: String) {
        // Get friend record with this id
        let fetchedFriend = self.getFriendByID(FriendUserID: friendUserID)
        // Now delete this friend
        deleteFriend(fetchedFriend)
    }
    
    // Delete friend using UserID
    func deleteFriendWithID(friendUserID: String){
        // Get the friend object with ID
        let fetchedFriend = self.getFriendByID(FriendUserID: friendUserID)
        self.deleteFriend(fetchedFriend)
    }
    
    // Delete friend
    func deleteFriend(friendItem: Friends) {
        //Delete friend item from persistance layer
        self.managedObjectContext.deleteObject(friendItem)
        self.saveMOC()
    }
    
    // Get Incoming Alerts Flag For User
    func getIncomingAlertsFlag(FriendUserID friendUserID: String) -> Bool {
        
        // Get friend record with this id
        let fetchedFriend = self.getFriendByID(FriendUserID: friendUserID)        
        let flagValue = fetchedFriend.allowAlertsIn!
        
        if(flagValue == "1"){
            return true
        }
        else{
            return false
        }
    }
    
    // Get Outgoing Alerts Flag For User
    func getOutgoingAlertsFlag(FriendUserID friendUserID: String) -> Bool {
        
        // Get friend record with this id
        let fetchedFriend = self.getFriendByID(FriendUserID: friendUserID)
        let flagValue = fetchedFriend.allowAlertsOut!
        
        if(flagValue == "1"){
            return true
        }
        else{
            return false
        }
    }
    
    // Set Incoming Alerts flag
    func setIncomingAlertsFlag(OldFlagValue oldFlagValue: String, FriendUserID friendUserID: String) {
        
        if(oldFlagValue == "1"){
            self.muteIncomingAlerts(FriendUserID: friendUserID)
        }else{
            self.unmuteIncomingAlerts(FriendUserID: friendUserID)
        }
    }
    
    // Mute Incomming Alerts
    func muteIncomingAlerts(FriendUserID friendUserID: String) {
        
        // Get friend record with this id
        let fetchedFriend = self.getFriendByID(FriendUserID: friendUserID)
        // Update allowAlertsIn to 0
        fetchedFriend.allowAlertsIn = "0"
        
        self.saveMOC()
    }
    
    // UnMute Incomming Alerts
    func unmuteIncomingAlerts(FriendUserID friendUserID: String) {
        
        // Get friend record with this id
        let fetchedFriend = self.getFriendByID(FriendUserID: friendUserID)
        // Update allowAlertsIn to 1
        fetchedFriend.allowAlertsIn = "1"
        
        self.saveMOC()
    }
    
    // Set Outgoing Alerts flag
    func setOutgoingAlertsFlag(OldFlagValue oldFlagValue: String, FriendUserID friendUserID: String) {
        
        if(oldFlagValue == "1"){
            self.muteOutgoingAlerts(FriendUserID: friendUserID)
        }else{
            self.unmuteOutgoingAlerts(FriendUserID: friendUserID)
        }
    }
    
    // Mute Outgoing Alerts
    func muteOutgoingAlerts(FriendUserID friendUserID: String) {
        
        // Get friend record with this id
        let fetchedFriend = self.getFriendByID(FriendUserID: friendUserID)
        // Update allowAlertsOut to 0
        fetchedFriend.allowAlertsOut = "0"
        
        self.saveMOC()
    }
    
    // UnMute Outgoing Alerts
    func unmuteOutgoingAlerts(FriendUserID friendUserID: String) {
        
        // Get friend record with this id
        let fetchedFriend = self.getFriendByID(FriendUserID: friendUserID)
        // Update allowAlertsOut to 1
        fetchedFriend.allowAlertsOut = "1"
        
        self.saveMOC()
    }
}