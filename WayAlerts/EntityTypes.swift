//
//  EntityTypes.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 17/07/16.
//  Copyright © 2016 SyncMinds Technologies. All rights reserved.
//

import Foundation

/**
 Enum for holding different entity type names (Coredata Models)
 */
enum EntityTypes:String {
    case User = "User",
    Friends = "Friends",
    Locations = "Locations",
    Ways = "Ways",
    WayLocationHistory = "WayLocationHistory"
    //case Bar = "Bar"
    
    static let getAll = [User,Friends, Locations, Ways] //[Event, Foo,Bar]
}
