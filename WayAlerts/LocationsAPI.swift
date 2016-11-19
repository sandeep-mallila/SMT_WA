//
//  LocationsAPI.swift
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
class LocationsAPI {
    
    let appDelegate: AppDelegate
    let managedObjectContext: NSManagedObjectContext
    
    //Utilize Singleton pattern by instanciating LocationsAPI only once.
    
    init(ApplicationDelegate appDelegate: AppDelegate){
        self.appDelegate = appDelegate
        self.managedObjectContext = self.appDelegate.managedObjectContext
    }
    
    func saveMOC(){
        do{
            try self.managedObjectContext.save()
        }
        catch{
            print("Error saving MOC in UserAPI")
        }
    }
    
    // MARK: Create
    
    func createNewLocation(locationDetails: Dictionary<String,String>, acceptStatus: String) {
        //Create new Object of Friend entity
        let locationItem = NSEntityDescription.insertNewObjectForEntityForName(EntityTypes.Locations.rawValue,
                                                                             inManagedObjectContext: self.managedObjectContext) as! Locations;
        
        // Assign values to each attribute of User entity
        locationItem.id = locationDetails[Locations.Attributes.id.rawValue]
        locationItem.name = locationDetails[Locations.Attributes.name.rawValue]
        locationItem.address = locationDetails[Locations.Attributes.address.rawValue]
        locationItem.latitude = locationDetails[Locations.Attributes.latitude.rawValue]
        locationItem.longitude = locationDetails[Locations.Attributes.longitude.rawValue]
        locationItem.zoomLevel = locationDetails[Locations.Attributes.zoomLevel.rawValue]
        locationItem.acceptStatus = acceptStatus
        
        self.saveMOC()
        
        //Save current work on Minion workers
        //self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
        
        //Save and merge changes from Minion workers with Main context
        //self.persistenceManager.mergeWithMainContext()
    }
    
    func getLocationsWithAcceptStatus(AcceptStatus acceptStatus: String) -> Array<Locations> {
        var fetchedResults:Array<Locations> = Array<Locations>()
        
        // Create request on User entity
        let fetchRequest = NSFetchRequest(entityName: EntityTypes.Locations.rawValue)
        
        //Add a predicate to filter by userId
        let findByAcceptStatusPredicate =
            NSPredicate(format: "\(Locations.Attributes.acceptStatus) = %@", acceptStatus)
        fetchRequest.predicate = findByAcceptStatusPredicate
        
        //Execute Fetch request
        do {
            fetchedResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Locations]
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<Locations>()
        }
        
        return fetchedResults
    }
    
    // Get Location By ID
    func getLocationByID(LocationID locationID: String) -> Locations {
        var fetchedResults: Locations;
        
        // Create request on Locations entity
        let fetchRequest = NSFetchRequest(entityName: EntityTypes.Locations.rawValue)
        
        //Add a predicate to filter by ID
        let findLocationByIDPredicate =
            NSPredicate(format: "\(Locations.Attributes.id) = %@", locationID)
        fetchRequest.predicate = findLocationByIDPredicate
        
        //Execute Fetch request
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Locations]
            if(result.count > 0){
                fetchedResults = result[0]
            }else{
                fetchedResults = Locations()
            }
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Locations()
        }
        return fetchedResults
    }
    
    // Accept Location share Request
    func acceptLocationRequest(LocationID locationID: String) {
       // Get location record with this id
        let fetchedLocation = self.getLocationByID(LocationID: locationID)
        // Update acceptStatus to 1
        fetchedLocation.acceptStatus = "1"
        
        self.saveMOC()
    }
    
    // Reject Location share Request
    func rejectLocationRequest(LocationID locationID: String) {
        // Delete this location
        self.deleteLocationWithID(locationID)
    }
    
    // Delete location using ID
    func deleteLocationWithID(locationID: String){
        // Get the location object with ID
        let fetchedLocation = self.getLocationByID(LocationID: locationID)
        // Delete this location
        self.deleteLocation(fetchedLocation)
    }
    
    // Delete location
    func deleteLocation(locationItem: Locations) {
        //Delete location item from persistance layer
        self.managedObjectContext.deleteObject(locationItem)
        self.saveMOC()
    }
    
    // Update location
    func updateLocation(LocID locationID: String, LocName locationName: String, LocAddress locationAddress: String) {
        // Get location with the given id
        let locationToUpdate = self.getLocationByID(LocationID: locationID)
        
        locationToUpdate.name = locationName
        locationToUpdate.address = locationAddress
        
        //Update location item from persistance layer
        self.saveMOC()
    }
    
    // Add default data to the location to be displayed when there ino data to be displayed
    func addDefaultLocationsData(){
        
        // Check to see default data already exists in the core data
        var fetchedResults: [Locations];
        let locationID = "" // ID will be "" for default data
        
        // Create request on Locations entity
        let fetchRequest = NSFetchRequest(entityName: EntityTypes.Locations.rawValue)
        
        //Add a predicate to filter by userId
        let findByUserIDPredicate =
            NSPredicate(format: "\(Locations.Attributes.id) = %@", locationID)
        fetchRequest.predicate = findByUserIDPredicate
        
        //Execute Fetch request
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Locations]
            fetchedResults = result
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = [Locations]()
        }
        
        if (fetchedResults.count != 2){
            // Delete all the friend records and recreate from scratch
            for aLocation in fetchedResults{
                self.deleteLocation(aLocation)
            }
            
            // Add Friend Requests section header
            var locationDetails = Dictionary<String,String>()
            
            locationDetails[Locations.Attributes.id.rawValue] = ""
            locationDetails[Locations.Attributes.name.rawValue] = StringConstants.noLocationRequestsMsg
            locationDetails[Locations.Attributes.address.rawValue] = ""
            locationDetails[Locations.Attributes.acceptStatus.rawValue] = "0"
            locationDetails[Locations.Attributes.latitude.rawValue] = "0"
            locationDetails[Locations.Attributes.longitude.rawValue] = "0"
            locationDetails[Locations.Attributes.zoomLevel.rawValue] = "0"
            
            // Create the friend
            self.createNewLocation(locationDetails, acceptStatus: "0")
            
            // Now create saved friends default data
            locationDetails[Locations.Attributes.acceptStatus.rawValue] = "1"
            locationDetails[Locations.Attributes.name.rawValue] = StringConstants.noSavedLocationsMsg
            
            // Create the friend
            self.createNewLocation(locationDetails, acceptStatus: "1")
            
        }
        
    }
    
}