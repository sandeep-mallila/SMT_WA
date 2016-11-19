//
//  PushNotificationsParser.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 24/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

class PushNotificationsParser{
    
    static let sharedInstance = PushNotificationsParser()

    
    // getFriendDetailsFromPN
    func getFriendDetailsFromPN (FriendDataRaw friendDataRaw: Dictionary<String, AnyObject>) -> Dictionary<String, String>{
        
        /* PN Format
         {
         "code":10005,"message":"Friend Invite","description":"WayAlerts user vamsi krishna (9000000009) has sent you a friend invite.","data":
         {
         "id":"1",
         "username":"vamsi krishna",
         "fafuserid":"190",
         "status":0,
         "trackablestatus":1,
         "mobile":"9000000009",
         "onlinestatus":0,
         "acceptstatus":0
         },
         "datetime":1456404750067
         }

        */
        
        let userFriendsRec = friendDataRaw// as! Array<Dictionary<String,String>>
        var aFriendRec = [String: String]()
        
        // Create Friend record
        aFriendRec[Friends.Attributes.acceptStatus.rawValue] = String(userFriendsRec[Constants.PNKeys.acceptstatus]!)
        aFriendRec[Friends.Attributes.fullName.rawValue] = String(userFriendsRec[Constants.PNKeys.username]!)
        aFriendRec[Friends.Attributes.mobileNumber.rawValue] = String(userFriendsRec[Constants.PNKeys.mobile]!)
        aFriendRec[Friends.Attributes.userID.rawValue] = String(userFriendsRec[Constants.PNKeys.id]!)
        
        let isRequestInitiator = "1"; // Request Initiator will always be 1 since this is s friend invite sent by the friend of thisuser so thisUser cant be the initiator
        
        aFriendRec[Friends.Attributes.allowAlertsOut.rawValue] = String(userFriendsRec[Constants.PNKeys.trackablestatus]!)
        aFriendRec[Friends.Attributes.allowAlertsIn.rawValue] = String(userFriendsRec[Constants.PNKeys.status]!)
        aFriendRec[Friends.Attributes.isRequestInitiator.rawValue] = isRequestInitiator
        
        return aFriendRec
    }
    
    // getAcceptedFriendDetailsFromPN
    func getAcceptedFriendDetailsFromPN (FriendDataRaw friendDataRaw: Dictionary<String, AnyObject>) -> Dictionary<String, String>{
        
        /* PN Format
         {"code":10006,"message":"FNF Request Accepted","description":"FNF Request Accepted","data":
         {
         "relid":"2",
         "fnfid":"3",
         "acceptstatus":1
         },
         "datetime":1456405686236}
        */
        
        let userFriendsRec = friendDataRaw// as! Array<Dictionary<String,String>>
        var aFriendRec = [String: String]()
        
        // Get the friend userid that accepted the request
        aFriendRec[Friends.Attributes.userID.rawValue] = String(userFriendsRec[Constants.PNKeys.fnfid]!)
        
        return aFriendRec
    }
    
    // getSharedLocationDetailsFromPN
    func getSharedLocationDetailsFromPN (LocationDataRaw locationDataRaw: Dictionary<String, AnyObject>) -> Dictionary<String, String>{
        
        /* PN Format
         {"code":10008,"message":"Location","description":"WayAlerts User vamsi krishna (9000000009) shared a location, 'Location Name', with you.","data":{"code":200,"message":"Success","description":"Location found","result":[{"ID":"1","LocName":"My Location","LocLat":"20.3484","LocLong":"30.2912","ZoomLevel":"","LocAddr":"updated address goes here"}]},"datetime":1456404856520}
         */
        
        // Get the location result object from pnData
        let pnLocResultArray = locationDataRaw["result"] as! [AnyObject]
        let pnLocResult = pnLocResultArray[0] as! Dictionary<String,AnyObject>
        
        // Get Locations detais to insert from PN
        var location = Dictionary<String,String>()
        location[Locations.Attributes.id.rawValue] = String(pnLocResult[Constants.PNKeys.ID]!)
        location[Locations.Attributes.name.rawValue] = String(pnLocResult[Constants.PNKeys.LocName]!)
        location[Locations.Attributes.address.rawValue] = String(pnLocResult[Constants.PNKeys.LocAddr]!)
        location[Locations.Attributes.latitude.rawValue] = String(pnLocResult[Constants.PNKeys.LocLat]!)
        location[Locations.Attributes.longitude.rawValue] = String(pnLocResult[Constants.PNKeys.LocLong]!)
        location[Locations.Attributes.zoomLevel.rawValue] = String(pnLocResult[Constants.PNKeys.ZoomLevel]!)
        
        return location
    }
}