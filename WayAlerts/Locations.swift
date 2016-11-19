//
//  Locations.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 22/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import CoreData


class Locations: NSManagedObject {

    enum Attributes : String {
        case
        id    = "id",
        name      = "name",
        address       = "address",
        latitude      = "latitude",
        longitude       = "longitude",
        zoomLevel    = "zoomLevel",
        acceptStatus    = "acceptStatus"
    }
    
    //Utilize Singleton pattern by instanciating.
    class var sharedInstance: Locations {
        struct Singleton {
            static let instance = Locations()
        }
        
        return Singleton.instance
    }


}
