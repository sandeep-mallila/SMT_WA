//
//  Ways.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 24/09/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import CoreData


class Ways: NSManagedObject {

    enum Attributes : String {
        case
        wayID    = "wayID",
        wayName      = "wayName",
        owningUserID       = "owningUserID",
        sourceLatLong      = "sourceLatLong",
        destinationLatLong       = "destinationLatLong",
        polyLinesData    = "polyLinesData",
        estimatedDistance    = "estimatedDistance",
        estimatedDuration = "estimatedDuration",
        wayFriends      = "wayFriends",
        wayPhoto       = "wayPhoto",
        qrCodeData      = "qrCodeData",
        vehicleNumber       = "vehicleNumber",
        wayType    = "wayType",
        distanceTravelledSoFar    = "distanceTravelledSoFar",
        timeElapsed    = "timeElapsed",
        ownerBatteryLevel      = "ownerBatteryLevel",
        sourceAddress       = "sourceAddress",
        destinationAddress      = "destinationAddress",
        status = "status",
        createdDateTime = "createdDateTime",
        lastUpdatedDateTime = "lastUpdatedDateTime",
        startedDateTime = "startedDateTime",
        endedDateTime = "endedDateTime"
        
    }
    
    //Utilize Singleton pattern by instanciating.
    class var sharedInstance: Ways {
        struct Singleton {
            static let instance = Ways()
        }
        
        return Singleton.instance
    }
}
