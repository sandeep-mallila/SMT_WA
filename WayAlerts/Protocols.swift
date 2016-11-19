//
//  Protocols.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 19/09/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

protocol SelectedFriendsForWayDelegate{
    func selectedFriendsForWay(selectedFriends: [String])
}

protocol WayLocationUpdatedDelegate{
    func wayCurrentLocationUpdated(WayId wayId: String, LatestLocationLatLong latestLocationLatLong: String)
}