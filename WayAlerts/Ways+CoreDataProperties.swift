//
//  Ways+CoreDataProperties.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 24/09/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Ways {

    @NSManaged var wayID: String?
    @NSManaged var wayName: String?
    @NSManaged var owningUserID: String?
    @NSManaged var sourceLatLong: String?
    @NSManaged var destinationLatLong: String?
    @NSManaged var polyLinesData: String?
    @NSManaged var estimatedDistance: String?
    @NSManaged var estimatedDuration: String?
    @NSManaged var wayFriends: String?
    @NSManaged var wayPhoto: String?
    @NSManaged var qrCodeData: String?
    @NSManaged var vehicleNumber: String?
    @NSManaged var wayType: String?
    @NSManaged var sourceAddress: String?
    @NSManaged var destinationAddress: String?
    @NSManaged var status: String?
    @NSManaged var createdDateTime: String?
    @NSManaged var lastUpdatedDateTime: String?
    @NSManaged var startedDateTime: String?
    @NSManaged var endedDateTime: String?
    @NSManaged var distanceTravelledSoFar: String?
    @NSManaged var timeElapsed: String?
    @NSManaged var ownerBatteryLevel: String?
    

}
