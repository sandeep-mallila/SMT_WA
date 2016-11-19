////
////  FriendsAPI.swift
////  WayAlerts
////
////  Created by SMTIOSDEV01 on 22/07/16.
////  Copyright © 2016 Cognizant. All rights reserved.
////
//
//import UIKit
//import CoreData
//import SwiftyJSON
//
///**
// User API contains the endpoints to Create/Read/Update/Delete User.
// */
//class FriendsAPI_OLD: CoreDataHelper {
//   
//    //Utilize Singleton pattern by instanciating FriendAPI only once.
//    class var sharedInstance: FriendsAPI {
//        struct Singleton {
//            static let instance = FriendsAPI()
//        }
//        
//        return Singleton.instance
//    }
//    
//    // MARK: Create
//    
//    func createNewFriend(friendDetails: Dictionary<String,String>) {
//        //Create new Object of Friend entity
//        let friendItem = NSEntityDescription.insertNewObjectForEntityForName(EntityTypes.Friends.rawValue,
//                                                                           inManagedObjectContext: minionManagedObjectContextWorker) as! Friends;
//        
//        // Assign values to each attribute of User entity
//        friendItem.userID = friendDetails[Friends.Attributes.userID.rawValue]
//        friendItem.acceptStatus = friendDetails[Friends.Attributes.acceptStatus.rawValue]
//        friendItem.allowAlertsIn = friendDetails[Friends.Attributes.allowAlertsIn.rawValue]
//        friendItem.allowAlertsOut = friendDetails[Friends.Attributes.allowAlertsOut.rawValue]
//        friendItem.fullName = friendDetails[Friends.Attributes.fullName.rawValue]
//        friendItem.isRequestInitiator = friendDetails[Friends.Attributes.isRequestInitiator.rawValue]
//        friendItem.mobileNumber = friendDetails[Friends.Attributes.mobileNumber.rawValue]
//       
//        
//        //Save current work on Minion workers
//        self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
//        
//        //Save and merge changes from Minion workers with Main context
//        self.persistenceManager.mergeWithMainContext()
//    }
//    
//    // Get friends
//    func getFriendsWithAcceptStatus(AcceptStatus acceptStatus: String) -> Array<Friends> {
//        var fetchedResults:Array<Friends> = Array<Friends>()
//        
//        // Create request on Friends entity
//        let fetchRequest = NSFetchRequest(entityName: EntityTypes.Friends.rawValue)
//        
//        //Add a predicate to filter by userId
//        let findByAcceptStatusPredicate =
//            NSPredicate(format: "\(Friends.Attributes.acceptStatus) = %@", acceptStatus)
//        fetchRequest.predicate = findByAcceptStatusPredicate
//        
//        //Execute Fetch request
//        do {
//            fetchedResults = try self.mainContextInstance.executeFetchRequest(fetchRequest) as! [Friends]
//        } catch let fetchError as NSError {
//            print("retrieveById error: \(fetchError.localizedDescription)")
//            fetchedResults = Array<Friends>()
//        }
//        return fetchedResults
//    }
//    
//    // Get Friend By ID
//    func getFriendByID(FriendUserID friendUserID: String) -> Friends {
//        var fetchedResults: Friends;
//        
//        // Create request on Friends entity
//        let fetchRequest = NSFetchRequest(entityName: EntityTypes.Friends.rawValue)
//        
//        //Add a predicate to filter by userId
//        let findByUserIDPredicate =
//            NSPredicate(format: "\(Friends.Attributes.userID) = %@", friendUserID)
//        fetchRequest.predicate = findByUserIDPredicate
//        
//        //Execute Fetch request
//        do {
//            let result = try self.mainContextInstance.executeFetchRequest(fetchRequest) as! [Friends]
//            fetchedResults = result[0] 
//        } catch let fetchError as NSError {
//            print("retrieveById error: \(fetchError.localizedDescription)")
//            fetchedResults = Friends()
//        }
//        return fetchedResults
//    }
//    
//    // 
//    func saveRecord(){
//        //Save current work on Minion workers
//        self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
//        
//        //Save and merge changes from Minion workers with Main context
//        self.persistenceManager.mergeWithMainContext()
//    }
//    
//    // Accept Friend Request
//    func acceptFriendRequest(FriendUserID friendUserID: String) {
//        let appDeligate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDeligate.managedObjectContext
//        
//        //Minion Context worker with Private Concurrency type.
//        //let minionManagedObjectContextWorker =
//         //   NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
//        //minionManagedObjectContextWorker.parentContext = self.mainContextInstance
//        
//        // Get friend record with this id
//        let fetchedFriend = self.getFriendByID(FriendUserID: friendUserID)
//        // Update acceptStatus to 1
//        //fetchedFriend.setValue("1", forKey: Friends.Attributes.acceptStatus.rawValue)
//        fetchedFriend.acceptStatus = "1"
//        
//        do{
//            try managedContext.save()
//        } catch let error as NSError {
//            print ("Could not save \(error),\(error.userInfo)")
//        }
//        
//        //Save current work on Minion workers
//        //self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
//        
//        //Save and merge changes from Minion workers with Main context
//        //self.persistenceManager.mergeWithMainContext()
//        //self.saveRecord()
//    }
//    
//    // Reject Friend Request
//    func rejectFriendRequest(FriendUserID friendUserID: String) {
//        // Get friend record with this id
//        let fetchedFriend = self.getFriendByID(FriendUserID: friendUserID)
//        // Now delete this friend
//        deleteFriend(fetchedFriend)
//    }
//    
//    // Delete friend
//    func deleteFriend(friendItem: Friends) {
//        //Delete friend item from persistance layer
//        self.mainContextInstance.deleteObject(friendItem)
//        self.persistenceManager.mergeWithMainContext()
//    }
//}