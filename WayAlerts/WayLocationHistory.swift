//
//  WayLocationHistory.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 03/10/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import CoreData


class WayLocationHistory: NSManagedObject {
    
    enum Attributes : String {
        case
        wayID    = "wayID",
        recordedLatLong      = "recordedLatLong",
        receivedDateTime       = "receivedDateTime",
        batteryLevel      = "batteryLevel",
        distanceTravelledSoFar       = "distanceTravelledSoFar",
        timeElapsed    = "timeElapsed",
        estimatedDistance    = "estimatedDistance",
        estimatedDuration = "estimatedDuration",
        isWayRecalculated      = "isWayRecalculated"
        
    }
    
    //Utilize Singleton pattern by instanciating.
    class var sharedInstance: WayLocationHistory {
        struct Singleton {
            static let instance = WayLocationHistory()
        }
        
        return Singleton.instance
    }
    
}
