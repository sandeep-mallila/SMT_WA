//
//  WaysAPI.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 24/09/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

/**
 Ways API contains the endpoints to Create/Read/Update/Delete User.
 */
class WaysAPI {
    
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
    
    func createNewWay(wayDetails: Dictionary<String,String>) {
        //Create new Object of Way entity
        let wayItem = NSEntityDescription.insertNewObjectForEntityForName(EntityTypes.Ways.rawValue,
                                                                          inManagedObjectContext: self.managedObjectContext) as! Ways;
        
        // Assign values to each attribute of User entity
        wayItem.wayID = wayDetails[Ways.Attributes.wayID.rawValue]
        wayItem.wayName = wayDetails[Ways.Attributes.wayName.rawValue]
        wayItem.owningUserID = wayDetails[Ways.Attributes.owningUserID.rawValue]
        wayItem.sourceLatLong = wayDetails[Ways.Attributes.sourceLatLong.rawValue]
        wayItem.destinationLatLong = wayDetails[Ways.Attributes.destinationLatLong.rawValue]
        wayItem.sourceAddress = wayDetails[Ways.Attributes.sourceAddress.rawValue]
        wayItem.destinationAddress = wayDetails[Ways.Attributes.destinationAddress.rawValue]
        wayItem.wayFriends = wayDetails[Ways.Attributes.wayFriends.rawValue]
        wayItem.wayPhoto = wayDetails[Ways.Attributes.wayPhoto.rawValue]
        wayItem.qrCodeData = wayDetails[Ways.Attributes.qrCodeData.rawValue]
        wayItem.vehicleNumber = wayDetails[Ways.Attributes.vehicleNumber.rawValue]
        wayItem.wayType = wayDetails[Ways.Attributes.wayType.rawValue]
        
        self.saveMOC()
    }
    
    // Get Way By ID
    func getWayByID(WayID wayID: String) -> Ways {
        var fetchedResults: Ways;
        
        // Create request on Ways entity
        let fetchRequest = NSFetchRequest(entityName: EntityTypes.Ways.rawValue)
        
        //Add a predicate to filter by ID
        let findWayByIDPredicate =
            NSPredicate(format: "\(Ways.Attributes.wayID) = %@", wayID)
        fetchRequest.predicate = findWayByIDPredicate
        
        //Execute Fetch request
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Ways!]
            if(result.count > 0){
                fetchedResults = result[0]
            }else{
                fetchedResults = Ways()
            }
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Ways()
        }
        return fetchedResults
    }
    
    func updateWayWithGetWayDataApiResponse(wayDetails: Dictionary<String,String>) {
        // Get wayID from the wayDetails
        let wayID = wayDetails[Ways.Attributes.wayID.rawValue]!
        
        // Get way with the given id
        let wayItem = self.getWayByID(WayID: wayID)
        
        // Assign values to each attribute of User entity
        wayItem.polyLinesData = wayDetails[Ways.Attributes.polyLinesData.rawValue]
        wayItem.estimatedDistance = wayDetails[Ways.Attributes.estimatedDistance.rawValue]
        wayItem.estimatedDuration = wayDetails[Ways.Attributes.estimatedDuration.rawValue]
        wayItem.distanceTravelledSoFar = wayDetails[Ways.Attributes.distanceTravelledSoFar.rawValue]
        wayItem.timeElapsed = wayDetails[Ways.Attributes.timeElapsed.rawValue]
        wayItem.ownerBatteryLevel = wayDetails[Ways.Attributes.ownerBatteryLevel.rawValue]
        wayItem.lastUpdatedDateTime = Utils.getCurrentDateTimeAsString()
        
        //Update location item from persistance layer
        self.saveMOC()
    }
    
    func updateWayStatusToStarted(StartedWayId startedWayId: String) {
        
        // Get way with the given id
        let wayItem = self.getWayByID(WayID: startedWayId)
        
        // Update status to Started
        wayItem.status = Constants.Lookups.WayStatusStarted
        wayItem.startedDateTime = Utils.getCurrentDateTimeAsString()
        
        //Update location item from persistance layer
        self.saveMOC()
    }
    
    func getPolylineAsString(WayId wayId: String) -> String {
        // Get way with the given id
        let wayItem = self.getWayByID(WayID: wayId)
        return wayItem.polyLinesData!
    }
    
    func updateWayWithProcessedCurrentLocationDataFromServer(wayDetails: Dictionary<String,String>){
        // Insert way location history item
        self.insertWayLocationHistoryRecord(wayDetails)
        
        // Update way with estimatedDistance,estimatedDuration,distanceTravelledSoFar,timeElapsed, lastUpdatedDateTime
        let wayId = wayDetails[Ways.Attributes.wayID.rawValue]!
        
        let wayItem = self.getWayByID(WayID: wayId)
        
        // Assign values to each attribute of Way location history entity
        wayItem.distanceTravelledSoFar = wayDetails[Ways.Attributes.distanceTravelledSoFar.rawValue]
        wayItem.timeElapsed = wayDetails[Ways.Attributes.timeElapsed.rawValue]
        wayItem.estimatedDuration = wayDetails[Ways.Attributes.estimatedDuration.rawValue]
        wayItem.estimatedDistance = wayDetails[Ways.Attributes.estimatedDistance.rawValue]
        wayItem.lastUpdatedDateTime = wayDetails[WayLocationHistory.Attributes.receivedDateTime.rawValue]
        
        //Update location item from persistance layer
        self.saveMOC()
    }
    
    // MARK: - Way History Functions
    func insertWayLocationHistoryRecord(wayDetails: Dictionary<String,String>) {
        //Create new Object of Way history entity
        let wayLocationHistoryItem = NSEntityDescription.insertNewObjectForEntityForName(EntityTypes.WayLocationHistory.rawValue,
                                                                                         inManagedObjectContext: self.managedObjectContext) as! WayLocationHistory;
        
        // Assign values to each attribute of Way location history entity
        wayLocationHistoryItem.wayID = wayDetails[WayLocationHistory.Attributes.wayID.rawValue]
        wayLocationHistoryItem.batteryLevel = wayDetails[WayLocationHistory.Attributes.batteryLevel.rawValue]
        wayLocationHistoryItem.distanceTravelledSoFar = wayDetails[WayLocationHistory.Attributes.distanceTravelledSoFar.rawValue]
        wayLocationHistoryItem.estimatedDistance = wayDetails[WayLocationHistory.Attributes.estimatedDistance.rawValue]
        wayLocationHistoryItem.estimatedDuration = wayDetails[WayLocationHistory.Attributes.estimatedDuration.rawValue]
        wayLocationHistoryItem.isWayRecalculated = wayDetails[WayLocationHistory.Attributes.isWayRecalculated.rawValue]
        wayLocationHistoryItem.receivedDateTime = wayDetails[WayLocationHistory.Attributes.receivedDateTime.rawValue]
        wayLocationHistoryItem.recordedLatLong = wayDetails[WayLocationHistory.Attributes.recordedLatLong.rawValue]
        wayLocationHistoryItem.timeElapsed = wayDetails[WayLocationHistory.Attributes.timeElapsed.rawValue]
        
        self.saveMOC()
    }
}