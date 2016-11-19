//
//  WayOnMap.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 25/09/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import GoogleMaps

class WayOnMap{
    var wayId: String
    var color: UIColor
    var isOwnedByCurrentUser: Bool
    var routePolylines: [GMSPolyline]
    var routeBounds: GMSCoordinateBounds
    
    init (WayId wayId: String, Color color: UIColor, IsOwnedByCurrentUser isOwnedByCurrentUser: Bool, RoutePolylines routePolylines: [GMSPolyline], RouteBounds routeBounds: GMSCoordinateBounds){
        self.wayId = wayId
        self.color = color
        self.isOwnedByCurrentUser = isOwnedByCurrentUser
        self.routePolylines = routePolylines
        self.routeBounds = routeBounds
    }
}