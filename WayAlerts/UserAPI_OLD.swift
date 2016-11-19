//import UIKit
//import CoreData
//import SwiftyJSON
//
///**
// User API contains the endpoints to Create/Read/Update/Delete User.
// */
//class UserAPI_OLD {
//    
//    let appDelegate: AppDelegate
//    let managedObjectContext: NSManagedObjectContext
//    
//    private let userIDNamespace = User.Attributes.userID.rawValue;
//    private let firstNameNamespace = User.Attributes.firstName.rawValue;
//    private let lastNameNamespace = User.Attributes.lastName.rawValue;
//    private let mobileNumberNamespace = User.Attributes.mobileNumber.rawValue;
//    private let profileImageNamespace = User.Attributes.profileImage.rawValue;
//    private let masterAlertsInToggleNamespace = User.Attributes.masterAlertsInToggle.rawValue;
//    private let masterAlertsOutToggleNamespace = User.Attributes.masterAlertsOutToggle.rawValue;
//    private let friendsNamespace = User.Attributes.friends.rawValue;
//
//    //Utilize Singleton pattern by instanciating UserAPI only once.
////    class var sharedInstance: UserAPI {
////        struct Singleton {
////            static let instance = UserAPI()
////        }
////        
////        return Singleton.instance
////    }
//    
//    init(appDelegate: AppDelegate?, ManagedObjectContext managedObjectContext: NSManagedObjectContext?){
//        self.appDelegate = appDelegate!
//        self.managedObjectContext = managedObjectContext!        
//    }
//    
////    init() {
////        self.persistenceManager = PersistenceManager.sharedInstance
////        self.mainContextInstance = persistenceManager.getMainContextInstance()
////        
////        //Minion Context worker with Private Concurrency type.
////        minionManagedObjectContextWorker =
////            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
////        minionManagedObjectContextWorker.parentContext = self.mainContextInstance
////        
////        //Create new Object of User entity
////        //userItem = NSEntityDescription.insertNewObjectForEntityForName(EntityTypes.User.rawValue,
////        //                                                                   inManagedObjectContext: minionManagedObjectContextWorker) as! User;
////    }
//    
//    // MARK: Create
//    
//    /**
//     Create a single User item, and persist it to Datastore via Worker(minion),
//     that synchronizes with Main context.
//     
//     - Parameter userDetails: <Dictionary<String, AnyObject> A single User item to be persisted to the Datastore.
//     - Returns: Void
//     */
//    
//    func createNewUser(userDetails: Dictionary<String,String>) {
//        //Create new Object of User entity
//        let userItem = NSEntityDescription.insertNewObjectForEntityForName(EntityTypes.User.rawValue,
//                                                                           inManagedObjectContext: minionManagedObjectContextWorker) as! User;
//        
//        // Assign values to each attribute of User entity
//        userItem.firstName = userDetails[User.Attributes.firstName.rawValue]
//        userItem.lastName = userDetails[User.Attributes.lastName.rawValue]
//        userItem.mobileNumber = userDetails[User.Attributes.mobileNumber.rawValue]
//        userItem.userID = userDetails[User.Attributes.userID.rawValue]
//        
//        //Save current work on Minion workers
//        self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
//        
//        //Save and merge changes from Minion workers with Main context
//        self.persistenceManager.mergeWithMainContext()
//        
//        //Post notification to update datasource of a given Viewcontroller/UITableView
//        self.postUpdateNotification()
//        
//        // Save thisUserId in memory
//        Utils.setNSDString(AsKey: Constants.NSDKeys.thisUserIdKey, WithValue: userDetails[User.Attributes.userID.rawValue]!)
//        
//        // Save thisMobileNumber in memory
//        Utils.setNSDString(AsKey: Constants.NSDKeys.thisMobileNumberKey, WithValue: userDetails[User.Attributes.mobileNumber.rawValue]!)
//
//        //NSUserDefaults.standardUserDefaults().setObject(userDetails[User.Attributes.userID.rawValue], forKey: Constants.Generic.thisUserIdKey);
//        //NSUserDefaults.standardUserDefaults().synchronize();
//    }
//
//    
//    /**
//     Create new Users from a given list, and persist it to Datastore via Worker(minion),
//     that synchronizes with Main context.
//     
//     - Parameter usersList: Array<AnyObject> Contains users to be persisted to the Datastore.
//     - Returns: Void
//     */
//    func saveUsersList(usersList:Array<AnyObject>){
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
//            
//            //Minion Context worker with Private Concurrency type.
//            let minionManagedObjectContextWorker:NSManagedObjectContext =
//                NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
//            minionManagedObjectContextWorker.parentContext = self.mainContextInstance
//            
//            //Create userEntity, process member field values
//            for index in 0..<usersList.count {
//                var userItem:Dictionary<String, NSObject> = usersList[index] as! Dictionary<String, NSObject>
//                
//                //Check that a User to be stored has a userID, firstName, lastName, profileImage and mobileNumber.
//                if userItem[self.userIDNamespace] != "" && userItem[self.firstNameNamespace] != ""  && userItem[self.lastNameNamespace] != ""  && userItem[self.mobileNumberNamespace] != "" && userItem[self.profileImageNamespace] != ""  {
//                    
//                    //Create new Object of User entity
//                    let item = NSEntityDescription.insertNewObjectForEntityForName(EntityTypes.User.rawValue,
//                        inManagedObjectContext: minionManagedObjectContextWorker) as! User
//                    
//                    //Add member field values
//                    item.setValue(userItem[self.userIDNamespace], forKey: self.userIDNamespace);
//                    item.setValue(userItem[self.firstNameNamespace], forKey: self.firstNameNamespace);
//                    item.setValue(userItem[self.lastNameNamespace], forKey: self.lastNameNamespace);
//                    item.setValue(userItem[self.mobileNumberNamespace], forKey: self.mobileNumberNamespace);
//                    item.setValue(userItem[self.masterAlertsInToggleNamespace], forKey: self.masterAlertsInToggleNamespace);
//                    item.setValue(userItem[self.masterAlertsOutToggleNamespace], forKey: self.masterAlertsOutToggleNamespace);
//                    item.setValue(userItem[self.profileImageNamespace], forKey: self.profileImageNamespace);
//                    
//                    //Save current work on Minion workers
//                    self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
//                }
//            }
//            
//            //Save and merge changes from Minion workers with Main context
//            self.persistenceManager.mergeWithMainContext()
//            
//            //Post notification to update datasource of a given Viewcontroller/UITableView
//            dispatch_async(dispatch_get_main_queue()) {
//                self.postUpdateNotification()
//            }
//        })
//    }
//    
//    // MARK: Read
//    
//    /**
//     Retrieves all user items stored in the persistence layer, default (overridable)
//     parameters:
//     
//     - Parameter sortedByDate: Bool flag to add sort rule: by Date
//     - Parameter sortAscending: Bool flag to set rule on sorting: Ascending / Descending date.
//     
//     - Returns: Array<User> with found users in datastore
//     */
//    func getAllUsers(sortedByDate:Bool = true, sortAscending:Bool = true) -> Array<User> {
//        var fetchedResults:Array<User> = Array<User>()
//        
//        // Create request on User entity
//        let fetchRequest = NSFetchRequest(entityName: EntityTypes.User.rawValue)
//        
//        //Create sort descriptor to sort retrieved Users by Date, ascending
////        if sortedByDate {
////            let sortDescriptor = NSSortDescriptor(key: dateNamespace,
////                                                  ascending: sortAscending)
////            let sortDescriptors = [sortDescriptor]
////            fetchRequest.sortDescriptors = sortDescriptors
////        }
//        
//        //Execute Fetch request
//        do {
//            fetchedResults = try  self.mainContextInstance.executeFetchRequest(fetchRequest) as! [User]
//        } catch let fetchError as NSError {
//            print("retrieveById error: \(fetchError.localizedDescription)")
//            fetchedResults = Array<User>()
//        }
//        
//        return fetchedResults
//    }
//    
//    
//    /**
//     Retrieve an User, found by it's stored UUID.
//     
//     - Parameter userId: UUID of User item to retrieve
//     - Returns: Array of Found User items, or empty Array
//     */
//    func getUserById(userID: NSString) -> Array<User> {
//        var fetchedResults:Array<User> = Array<User>()
//        
//        // Create request on User entity
//        let fetchRequest = NSFetchRequest(entityName: EntityTypes.User.rawValue)
//        
//        //Add a predicate to filter by userId
//        let findByIdPredicate =
//            NSPredicate(format: "\(userIDNamespace) = %@", userID)
//        fetchRequest.predicate = findByIdPredicate
//        
//        //Execute Fetch request
//        do {
//            fetchedResults = try self.mainContextInstance.executeFetchRequest(fetchRequest) as! [User]
//        } catch let fetchError as NSError {
//            print("retrieveById error: \(fetchError.localizedDescription)")
//            fetchedResults = Array<User>()
//        }
//        
//        return fetchedResults
//    }
//    
//    
//    /**
//     Retrieves all user items stored in the persistence layer
//     and sort it by Date within a given range of (default) current date and
//     (default)7 days from current date (is overridable, parameters are optional).
//     
//     - Parameter sortByDate: Bool default and overridable is set to True
//     - Parameter sortAscending: Bool default and overridable is set to True
//     - Parameter startDate: NSDate default and overridable is set to previous year
//     - Parameter endDate: NSDate default and overridable is set to 1 week from current date
//     - Returns: Array<User> with found users in datastore based on
//     sort descriptor, in this case Date an dgiven date range.
//     */
//    
////    func getUsersInDateRange(sortByDate:Bool = true, sortAscending:Bool = true,
////                              startDate: NSDate = NSDate(timeInterval:-189216000, sinceDate:NSDate()),
////                              endDate: NSDate = NSCalendar.currentCalendar()
////        .dateByAddingUnit(
////            .Day,value: 7,
////            toDate: NSDate(),
////            options: NSCalendarOptions(rawValue: 0))!) -> Array<User> {
////        
////        // Create request on User entity
////        let fetchRequest = NSFetchRequest(entityName: EntityTypes.User.rawValue)
////        
////        //Create sort descriptor to sort retrieved Users by Date, ascending
////        let sortDescriptor = NSSortDescriptor(key: User.Attributes.date.rawValue,
////                                              ascending: sortAscending)
////        let sortDescriptors = [sortDescriptor]
////        fetchRequest.sortDescriptors = sortDescriptors
////        
////        //Create predicate to filter by start- / end date
////        let findByDateRangePredicate = NSPredicate(format: "(\(dateNamespace) >= %@) AND (\(dateNamespace) <= %@)", startDate, endDate)
////        fetchRequest.predicate = findByDateRangePredicate
////        
////        //Execute Fetch request
////        var fetchedResults = Array<User>()
////        do {
////            fetchedResults = try self.mainContextInstance.executeFetchRequest(fetchRequest) as! [User]
////        } catch let fetchError as NSError {
////            print("retrieveItemsSortedByDateInDateRange error: \(fetchError.localizedDescription)")
////        }
////        
////        return fetchedResults
////    }
//    
//    // MARK: Update
//    
//    /**
//     Update all users (batch update) attendees list.
//     
//     Since privacy is always a concern to take into account,
//     anonymise the attendees list for every user.
//     
//     - Returns: Void
//     */
////    func anonimizeAttendeesList()  {
////        // Create a fetch request for the entity Person
////        let fetchRequest = NSFetchRequest(entityName: EntityTypes.User.rawValue)
////        
////        // Execute the fetch request
////        var fetchedResults = Array<User>()
////        do {
////            fetchedResults = try self.mainContextInstance.executeFetchRequest(fetchRequest) as! [User]
////            
////            for user in fetchedResults {
////                //get count of current attendees list
////                let currCount = (user as User).attendees.count
////                
////                //Create an anonymised list of attendees
////                //with count of current attendees list
////                let anonymisedList = [String](count: currCount, repeatedValue: "Anonymous")
////                
////                //Update current attendees list with anonymised list, shallow copy.
////                (user as User).attendees = anonymisedList
////            }
////        } catch let updateError as NSError {
////            print("updateAllUserAttendees error: \(updateError.localizedDescription)")
////        }
////    }
//    
//    /**
//     Update user item for specific keys.
//     
//     - Parameter userItemToUpdate: User the passed user to update it's member fields
//     - Parameter newUserItemDetails: Dictionary<String,AnyObject> the details to be updated
//     - Returns: Void
//     */
//    func updateUser(userItemToUpdate: User, newUserItemDetails: Dictionary<String, AnyObject>){
//        
//        let minionManagedObjectContextWorker:NSManagedObjectContext =
//            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
//        minionManagedObjectContextWorker.parentContext = self.mainContextInstance
//        
////        //Assign field values
////        for (key, value) in newUserItemDetails {
////            for attribute in User.Attributes.getAll {
////                if (key == attribute.rawValue) {
////                    userItemToUpdate.setValue(value, forKey: key)
////                }
////            }
////        }
//        
//        //Persist new User to datastore (via Managed Object Context Layer).
//        self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
//        self.persistenceManager.mergeWithMainContext()
//        
//        self.postUpdateNotification()
//    }
//    
//    // MARK: Delete
//    
//    /**
//     Delete all User items from persistence layer.
//     
//     - Returns: Void
//     */
//    func deleteAllUsers() {
//        let retrievedItems = getAllUsers()
//        
//        //Delete all user items from persistance layer
//        for item in retrievedItems {
//            self.mainContextInstance.deleteObject(item)
//        }
//        self.persistenceManager.mergeWithMainContext()
//        
//        self.postUpdateNotification()
//    }
//    
//    /**
//     Delete a single User item from persistence layer.
//     
//     - Parameter userItem: User to be deleted
//     - Returns: Void
//     */
//    func deleteUser(userItem: User) {
//        //Delete user item from persistance layer
//        self.mainContextInstance.deleteObject(userItem)
//        self.postUpdateNotification()
//    }
//    
//    /**
//     Post update notification to let the registered listeners refresh it's datasource.
//     
//     - Returns: Void
//     */
//    private func postUpdateNotification(){
//        NSNotificationCenter.defaultCenter().postNotificationName("updateUserTableData", object: nil)
//    }
//    
//}