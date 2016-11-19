//
//  ResponseProcessor.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 18/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import SwiftyJSON

class ResponseParser: NSObject {
    static let sharedInstance = ResponseParser()
    
    func getUserDetailsToInsert(ServerResponse serverResponse: Dictionary<String, AnyObject>) -> Dictionary<String, String> {
        let responseDataJson = serverResponse[Constants.ServerResponseKeys.userdetails];
        var userDetailsToInsert = [String: String]()
        
        // Converts the JSON response to dictionary
        let responseData = SwiftyJSON.JSON(responseDataJson as! Dictionary<String, AnyObject>)
        
        // Create dictionary to be returned
        
        userDetailsToInsert[User.Attributes.userID.rawValue] = responseData[Constants.ServerResponseKeys.userid].stringValue
        userDetailsToInsert[User.Attributes.firstName.rawValue] = responseData[Constants.ServerResponseKeys.fname].stringValue
        userDetailsToInsert[User.Attributes.lastName.rawValue] = responseData[Constants.ServerResponseKeys.lname].stringValue
        //userDetailsToInsert[User.Attributes.mobileNumber.rawValue] = responseData["mobile"].stringValue
        userDetailsToInsert[User.Attributes.mobileNumber.rawValue] = Utils.getNSDString(WithKey: Constants.NSDKeys.thisMobileNumberKey)
        
        // Return
        return userDetailsToInsert
    }
    
    // getPostLoginData
    func getUserFriendsData(ServerResponse serverResponse: Dictionary<String, AnyObject>, DataIsFromPN dataIsFromPN: Bool) -> [Dictionary<String, String>]{
        let userFriendsDataObj = serverResponse[Constants.ServerResponseKeys.userFNFContacts]!;
        let userFriendsDataArray = userFriendsDataObj as! Array<Dictionary<String,String>>
        var userFriendsData = [Dictionary<String,String>]()
        
        for aRecord in userFriendsDataArray{
            var aFriendRec = [String: String]()
            
            // Create Friend record
            aFriendRec[Friends.Attributes.acceptStatus.rawValue] = aRecord[Constants.ServerResponseKeys.acceptstatus]!
            aFriendRec[Friends.Attributes.fullName.rawValue] = aRecord[Constants.ServerResponseKeys.username]!
            aFriendRec[Friends.Attributes.mobileNumber.rawValue] = aRecord[Constants.ServerResponseKeys.mobile]!
            aFriendRec[Friends.Attributes.userID.rawValue] = aRecord[Constants.ServerResponseKeys.fafuserid]!
            
            var isRequestInitiator = "0";
            if (Utils.getThisUserID() == (aRecord[Constants.ServerResponseKeys.fafuserid])){
                isRequestInitiator = "1";
            }
            
            
            aFriendRec[Friends.Attributes.allowAlertsOut.rawValue] = aRecord[Constants.ServerResponseKeys.trackablestatus]!
            aFriendRec[Friends.Attributes.allowAlertsIn.rawValue] = aRecord[Constants.ServerResponseKeys.status]
            aFriendRec[Friends.Attributes.isRequestInitiator.rawValue] = isRequestInitiator
            
            // Now append this record to the array to be returned
            userFriendsData.append(aFriendRec)
            
        }
        return userFriendsData
    }
    
    func getUserLocationsData(ServerResponse serverResponse: Dictionary<String, AnyObject>) -> [Dictionary<String, String>]{
        let userLocationsDataObj = serverResponse[Constants.ServerResponseKeys.userLocations]!;
        let userLocationsDataArray = userLocationsDataObj as! Array<Dictionary<String,String>>
        var userLocationsData = [Dictionary<String,String>]()
        
        for aRecord in userLocationsDataArray{
            var aLocationRec = [String: String]()
            
            // Create Friend record
            aLocationRec[Locations.Attributes.id.rawValue] = aRecord[Constants.ServerResponseKeys.ID]!
            aLocationRec[Locations.Attributes.name.rawValue] = aRecord[Constants.ServerResponseKeys.LocName]!
            aLocationRec[Locations.Attributes.address.rawValue] = aRecord[Constants.ServerResponseKeys.LocAddr]!
            aLocationRec[Locations.Attributes.latitude.rawValue] = aRecord[Constants.ServerResponseKeys.LocLat]!
            aLocationRec[Locations.Attributes.longitude.rawValue] = aRecord[Constants.ServerResponseKeys.LocLong]!
            aLocationRec[Locations.Attributes.zoomLevel.rawValue] = aRecord[Constants.ServerResponseKeys.ZoomLevel]!
            
            // Now append this record to the array to be returned
            userLocationsData.append(aLocationRec)
            
        }
        return userLocationsData
    }
    
    // getPostLoginData
    func getFriendDetailsFromPN(FriendDataRaw friendDataRaw: Dictionary<String, AnyObject>) -> Dictionary<String, String>{
        let userFriendsRec = friendDataRaw// as! Array<Dictionary<String,String>>
        var aFriendRec = [String: String]()
        
        // Create Friend record
        aFriendRec[Friends.Attributes.acceptStatus.rawValue] = String(userFriendsRec[Constants.ServerResponseKeys.acceptstatus]!)
        aFriendRec[Friends.Attributes.fullName.rawValue] = String(userFriendsRec[Constants.ServerResponseKeys.username]!)
        aFriendRec[Friends.Attributes.mobileNumber.rawValue] = String(userFriendsRec[Constants.ServerResponseKeys.mobile]!)
        aFriendRec[Friends.Attributes.userID.rawValue] = String(userFriendsRec[Constants.ServerResponseKeys.id]!)
        
        let isRequestInitiator = "1"; // Request Initiator will always be 1 since this is s friend invite sent by the friend of thisuser so thisUser cant be the initiator
        
        aFriendRec[Friends.Attributes.allowAlertsOut.rawValue] = String(userFriendsRec[Constants.ServerResponseKeys.trackablestatus]!)
        aFriendRec[Friends.Attributes.allowAlertsIn.rawValue] = String(userFriendsRec[Constants.ServerResponseKeys.status]!)
        aFriendRec[Friends.Attributes.isRequestInitiator.rawValue] = isRequestInitiator
        
        return aFriendRec
    }
    
    // Get friend details to insert, called after addMember API call
    func getFriendDetailsToInsert(ServerResponse serverResponse: Dictionary<String, AnyObject>) -> Dictionary<String, String> {
        let responseDataJson = serverResponse[Constants.ServerResponseKeys.result];
        //var friendDetailsToInsert = [String: String]()
        
        var aFriendRec = [String: String]()
        
        // Create Friend record
        aFriendRec[Friends.Attributes.acceptStatus.rawValue] = "0"
        aFriendRec[Friends.Attributes.fullName.rawValue] = (responseDataJson?.valueForKey("username")as! [String])[0]
        aFriendRec[Friends.Attributes.mobileNumber.rawValue] = (responseDataJson?.valueForKey("mobile")as! [String])[0]
        aFriendRec[Friends.Attributes.userID.rawValue] = (responseDataJson?.valueForKey("fafuserid")as! [String])[0]
        
        let isRequestInitiator = "0"; // Request Initiator will always be 1 since this is s friend invite sent by the friend of thisuser so thisUser cant be the initiator
        
        aFriendRec[Friends.Attributes.allowAlertsOut.rawValue] = "1"
        aFriendRec[Friends.Attributes.allowAlertsIn.rawValue] = "1"
        aFriendRec[Friends.Attributes.isRequestInitiator.rawValue] = isRequestInitiator
        
        return aFriendRec
    }
    
    // Get location details to insert, called after addLocation API call
    func getLocationDetailsToInsert(ServerResponse serverResponse: Dictionary<String, AnyObject>) -> Dictionary<String, String> {
        
        let responseDataJson = serverResponse[Constants.ServerResponseKeys.result];
        var aLocationRec = [String: String]()
        
        // Converts the JSON response to dictionary
        let responseData = SwiftyJSON.JSON(responseDataJson as! Dictionary<String, AnyObject>)
        
        // Create Location record
        aLocationRec[Locations.Attributes.name.rawValue] = responseData[Constants.ServerResponseKeys.LocName].stringValue
        aLocationRec[Locations.Attributes.latitude.rawValue] = responseData[Constants.ServerResponseKeys.LocLat].stringValue
        aLocationRec[Locations.Attributes.longitude.rawValue] = responseData[Constants.ServerResponseKeys.LocLong].stringValue
        aLocationRec[Locations.Attributes.address.rawValue] = responseData[Constants.ServerResponseKeys.LocAddr].stringValue
        aLocationRec[Locations.Attributes.zoomLevel.rawValue] = responseData[Constants.ServerResponseKeys.ZoomLevel].stringValue
        aLocationRec[Locations.Attributes.id.rawValue] = responseData[Constants.ServerResponseKeys.ID].stringValue
        
        return aLocationRec
    }
    
    // Get way details to insert, called after createWay API call
    func getWayDetailsToInsert(ServerResponse serverResponse: Dictionary<String, AnyObject>, RequestParams requestParams: Dictionary<String, AnyObject>) -> Dictionary<String, String> {
        
        let responseDataJson = serverResponse[Constants.ServerResponseKeys.result];
        var aWayRec = [String: String]()
        
        // Converts the JSON response to dictionary
        //let responseData = SwiftyJSON.JSON(responseDataJson as! Dictionary<String, AnyObject>)
        let responseData = self.getDictionaryfromString(StringData: responseDataJson! as! String)!
        //let aVariable:
        //responseDataJson! as! Dictionary<String, AnyObject>
        
        // Create Location record
        aWayRec[Ways.Attributes.wayID.rawValue] = (responseData[Constants.ServerResponseKeys.WayID]! as! String)
        aWayRec[Ways.Attributes.wayName.rawValue] = (requestParams[Constants.ServerRequestKeys.wayname]! as! String)
        aWayRec[Ways.Attributes.owningUserID.rawValue] = (requestParams[Constants.ServerRequestKeys.userid]! as! String)
        aWayRec[Ways.Attributes.sourceLatLong.rawValue] = (requestParams[Constants.ServerRequestKeys.waysource]! as! String)
        aWayRec[Ways.Attributes.destinationLatLong.rawValue] = (requestParams[Constants.ServerRequestKeys.waydestination]! as! String)
        aWayRec[Ways.Attributes.wayFriends.rawValue] = (requestParams[Constants.ServerRequestKeys.fnfuserids]! as! String)
        aWayRec[Ways.Attributes.wayPhoto.rawValue] = (requestParams[Constants.ServerRequestKeys.photo]! as! String)
        aWayRec[Ways.Attributes.qrCodeData.rawValue] = (requestParams[Constants.ServerRequestKeys.qrcodedata]! as! String)
        aWayRec[Ways.Attributes.vehicleNumber.rawValue] = (requestParams[Constants.ServerRequestKeys.vehiclenumber]! as! String)
        aWayRec[Ways.Attributes.wayType.rawValue] = (requestParams[Constants.ServerRequestKeys.waytype]! as! String)
        
        aWayRec[Ways.Attributes.sourceAddress.rawValue] = "TBD: Source Address"
        aWayRec[Ways.Attributes.destinationAddress.rawValue] = "TBD: Destination Address"
        
        aWayRec[Ways.Attributes.status.rawValue] = Constants.Lookups.WayStatusCreated
        aWayRec[Ways.Attributes.createdDateTime.rawValue] = Utils.getCurrentDateTimeAsString()
        
        return aWayRec
    }
    
    // Get way details to update, called after getWayData API call
    func getWayDetailsToUpdate(ServerResponse serverResponse: Dictionary<String, AnyObject>, RequestParams requestParams: Dictionary<String, AnyObject>) -> Dictionary<String, String> {
        
        let responseDataJson = serverResponse[Constants.ServerResponseKeys.result];
        var aWayRec = [String: String]()
        
        // Converts the JSON response to dictionary
        //let responseData = SwiftyJSON.JSON(responseDataJson as! Dictionary<String, AnyObject>)
        let responseData = self.getDictionaryfromString(StringData: responseDataJson! as! String)!
        //let aVariable:
        //responseDataJson! as! Dictionary<String, AnyObject>
        
        // Create Location record
        aWayRec[Ways.Attributes.wayID.rawValue] = (requestParams[Constants.ServerRequestKeys.wayid]! as! String)
        aWayRec[Ways.Attributes.estimatedDistance.rawValue] = (responseData[Constants.ServerResponseKeys.distance]! as! String)
        aWayRec[Ways.Attributes.estimatedDuration.rawValue] = (responseData[Constants.ServerResponseKeys.duration]! as! String)
        aWayRec[Ways.Attributes.polyLinesData.rawValue] = (responseData[Constants.ServerResponseKeys.polylines]! as! String)
        aWayRec[Ways.Attributes.distanceTravelledSoFar.rawValue] = "0"
        aWayRec[Ways.Attributes.timeElapsed.rawValue] = "0"
        aWayRec[Ways.Attributes.ownerBatteryLevel.rawValue] = ""
        
        return aWayRec
    }
    
    // Get way details to update, called after updateMyPosition API call
    func getResultFromUpdateMyPositionResponse(ServerResponse serverResponse: Dictionary<String, AnyObject>, RequestParams requestParams: Dictionary<String, String>) -> Dictionary<String, String> {
        
        let responseDataJson = serverResponse[Constants.ServerResponseKeys.result];
        var aWayRec = [String: String]()
        
        // Converts the JSON response to dictionary
        //let responseData = SwiftyJSON.JSON(responseDataJson as! Dictionary<String, AnyObject>)
        let responseData = self.getDictionaryfromString(StringData: responseDataJson! as! String)!
        
        // Create way record
        aWayRec[WayLocationHistory.Attributes.wayID.rawValue] = (requestParams[Constants.ServerRequestKeys.wayid]! )
        aWayRec[WayLocationHistory.Attributes.timeElapsed.rawValue] = responseData[Constants.ServerResponseKeys.timeelapsed]!.stringValue
        aWayRec[WayLocationHistory.Attributes.batteryLevel.rawValue] = responseData[Constants.ServerResponseKeys.batterylevel]!.stringValue
        aWayRec[WayLocationHistory.Attributes.estimatedDuration.rawValue] = responseData[Constants.ServerResponseKeys.timeestimated]!.stringValue
        
        // Get the latlong
        //String(responseData[Constants.ServerResponseKeys.latitude]!)
        let latitude = String(responseData[Constants.ServerResponseKeys.latitude]!)
        let longitude = String(responseData[Constants.ServerResponseKeys.longitude]!)
        aWayRec[WayLocationHistory.Attributes.recordedLatLong.rawValue] = "\(latitude),\(longitude)"
        
        aWayRec[WayLocationHistory.Attributes.isWayRecalculated.rawValue] = responseData[Constants.ServerResponseKeys.callapi]!.stringValue
        aWayRec[WayLocationHistory.Attributes.estimatedDistance.rawValue] = responseData[Constants.ServerResponseKeys.totaldistance]!.stringValue
        aWayRec[WayLocationHistory.Attributes.receivedDateTime.rawValue] = Utils.getCurrentDateTimeAsString()
        
        return aWayRec
    }
    
    func getDictionaryfromString(StringData stringData: String) -> Dictionary<String,AnyObject>!{
        do{
            return try NSJSONSerialization.JSONObjectWithData(stringData.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! [String:AnyObject]
        }catch let error as NSError {
            print(error)
        }
        return Dictionary<String,AnyObject>()
    }
    
}
