//
//  WayLocationHistory+CoreDataProperties.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 03/10/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WayLocationHistory {

    @NSManaged var wayID: String?
    @NSManaged var recordedLatLong: String?
    @NSManaged var receivedDateTime: String?
    @NSManaged var batteryLevel: String?
    @NSManaged var distanceTravelledSoFar: String?
    @NSManaged var timeElapsed: String?
    @NSManaged var estimatedDistance: String?
    @NSManaged var estimatedDuration: String?
    @NSManaged var isWayRecalculated: String?

}
