//
//  StringConstants.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 20/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import Foundation

struct StringConstants {
    static let resentOTPAlertTitle = "OTP SMS Resent";
    static let resentOTPAlertDesc = "A new OTP has been generated and has been sent to your registered mobile number.";
    
    static let noInternetAlertTitle = "No Internet connection"
    static let noInternetAlertDesc = "Please ensure you are connected to the Internet"
    
    static let noLocationRequestsMsg = "No location requests to display"
    static let noSavedLocationsMsg = "No saved locations to display"
    
    static let noFriendRequestsMsg = "No friend requests to display"
    static let noSavedFriendsMsg = "No saved friends to display"
    
    struct ForFriends{
        static let inviteAccepted = "Friend added to your saved list"
        static let inviteRejected = "Friend request rejected"
        static let friendDeleted = "Friend contact deleted"
        static let alertsOutTurnedOn = "Your friend is all set to receive your WayAlerts"
        static let alertsOutTurnedOff = "Your friend will no more receive your WayAlerts"
        static let alertsInTurnedOn = "You are all set to recdeive WayAlerts from your friend"
        static let alertsInTurnedOff = "Your friend will no more receive your WayAlerts"
    }
    
    struct ForLocations{
        static let noLocationRequestsMsg = "No location requests to display"
        static let noSavedLocationsMsg = "No saved locations to display"
        
        static let confirmLocationDeleteTitle = "Confirm Delete"
        static let confirmLocationDeleteMsg = "Are you sure you want to delete this location?"
        
        static let locationNameToSavePleaseMsg = "Please enter a name for this location:"
        static let locationNameToSavePleaseTitle = "Location Name"
    }
    
    struct PushNotifications{
        static let friendRequestReceivedTitle = "Friend Request Received"
        static let friendRequestReceivedSubTitle = "You received a new friend request"
        
        static let locationSharedTitle = "Location Shared"
        static let locationSharedSubTitle = "Your friend shared a location with you"
    }
    
    struct ForLocationServices{
        static let enableLocationServicesAlertTitle = "Enable Location Services"
        //static let enableLocationServicesAlertMsg = "WayAlerts needs location services to be anabled to proceed with its functions. Please turn on location services under 'Settings>Location' menu to proceed further."
        static let enableLocationServicesAlertMsg = "Location services are turned off. In order to use WayAlerts, please enable Location Services in the Settigs app under Privacy, Location."
        static let enableLocationServicesAlertSettingsBtnLbl = "Go to Settings now"
        static let enableLocationServicesAlertCancelBtnLbl = "Cancel"
        
        static let enableLocationServicesAccessAlertTitle = "Enable Location Services Access"
        static let enableLocationServicesAccessAlertMsg = "User application settings are set to 'Never' allow WayAlerts to use Location Services. In order to use WayAlerts, please allow WayAlerts to 'Always' access Location Services under the Settings"
    }
    
    struct ForWays{
        static let selectOnMapDropDownOption = "Select on Map"
        static let confirmCreateWayWithNoFriendsTitle = "Create Way with no friends?"
        static let confirmCreateWayWithNoFriendsMsg = "No friends selected for this way. Do you wish to create a way with out sharing it with friends?"
    }
}
