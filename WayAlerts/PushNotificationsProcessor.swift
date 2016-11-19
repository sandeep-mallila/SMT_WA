//
//  PushNotificationsProcessor.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 24/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData
import BRYXBanner
import AVFoundation

class PushNotificationsProcessor{
    class func makeSenseOutOfPN(PushMessage pushMessage: [String: AnyObject]){
        // Get the alert from the PN
        let pnAlert = pushMessage["alert"] as! Dictionary<String, AnyObject>
        
        // Get the pnCode and ackid from the alert
        let pnCode = String(pnAlert["code"]!)
        let ackid = String(pnAlert["ackid"]!)
        //let pnCode = pnAlert["code"]!.stringValue
        //let ackid = pnAlert["ackid"]!.stringValue
        
        // Call Pushnotification Ack API
        DataController.sharedInstance.callPushNotificationAckPI(AckID: ackid, PNCode: pnCode, success: { (serverResponse) in
            })
        { (error) in
        }
        
        // Get the actual server sent data from alert as a dictionary
        let pnDataRaw = pnAlert["data"] as! Dictionary<String,AnyObject>
        let pnDataDict = pnDataRaw
        //let pnDataJson = pnDataRaw!.dataUsingEncoding(NSUTF8StringEncoding)
        //let pnDataDict = try! NSJSONSerialization.JSONObjectWithData(pnDataJson!, options: NSJSONReadingOptions(rawValue: 0)) as! Dictionary<String,AnyObject>
        
        //Utils.showAlertOK(Title: "Received Push Message", Message: "Push Message Code: \(pnCode)")
        
        // Now send this alert data for further processing
        processPNData(PNCode: pnCode, PNData: pnDataDict)
        
        // Display user notification
        self.displayUserNotification(NotificationType: pnCode)
    }
    
    class func displayUserNotification(NotificationType notificationType: String){
        var bannerTitle = ""
        var bannerSubTitle = ""
        var bannerImage = ""
        switch (notificationType){
        case Constants.PNTypes.FriendInviteReceived:
            bannerTitle = StringConstants.PushNotifications.friendRequestReceivedTitle
            bannerSubTitle = StringConstants.PushNotifications.friendRequestReceivedSubTitle
            bannerImage = "" // TODO: Fetch friend image and display here
            break;
        case Constants.PNTypes.LocationShared:
            bannerTitle = StringConstants.PushNotifications.locationSharedTitle
            bannerSubTitle = StringConstants.PushNotifications.locationSharedSubTitle
            bannerImage = "" // TODO: Fetch friend image and display here
            break;
        default:
            break;
        }
      
        self.playAlertSound()
        let banner = Banner(title: bannerTitle, subtitle: bannerSubTitle, image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
        banner.dismissesOnTap = true
        banner.show(duration: 3.0)
    }
    
    class func playAlertSound(){
        // create a sound ID, in this case its the tweet sound.
        let systemSoundID: SystemSoundID = 1016
        
        // to play sound
        AudioServicesPlaySystemSound (systemSoundID)
    }
    
    class func processPNData(PNCode pnCode: String, PNData pnData: Dictionary<String,AnyObject>){
        switch (pnCode) {
        case "10001":
            break;
        case "10002":
            break;
        case "10003":
            break;
        case "10004":
            break;
        case Constants.PNTypes.FriendInviteReceived:
            processFriendInvitePN(PNData: pnData)
            break;
        case Constants.PNTypes.FriendInviteAccepted:
            processFriendInviteAcceptedPN(PNData: pnData)
            break;
        case "10007":
            break;
        case Constants.PNTypes.LocationShared:
            processLocatedSharedPN(PNData: pnData)
            break;
        case "10009":
            break;
        case "10010":
            break;
        case "10011":
            break;
        case "10012":
            break;
        case "10013":
            break;
        case "10014":
            break;
        case "10015":
            break;
        case "10016":
            break;
        case "10017":
            break;
        case "10018":
            break;
        case "10019":
            break;
        case "10020":
            break;
        case "10021":
            break;
        case "10022":
            break;
        case "10023":
            break;
        case "10024":
            break;
        default:
        break
        }
    }
    
    class func processFriendInvitePN(PNData pnData: Dictionary<String,AnyObject>){
        let userFriendsData = PushNotificationsParser.sharedInstance.getFriendDetailsFromPN(FriendDataRaw: pnData)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let friendsAPI = FriendsAPI(ApplicationDelegate: appDelegate)
        
        // Save userFriends Data to local db
        friendsAPI.createNewFriend(userFriendsData)
        
    }
    
    class func processFriendInviteAcceptedPN(PNData pnData: Dictionary<String,AnyObject>){
        
        let userFriendsData = PushNotificationsParser.sharedInstance.getAcceptedFriendDetailsFromPN(FriendDataRaw: pnData)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let friendsAPI = FriendsAPI(ApplicationDelegate: appDelegate)
        
        // Save userFriends Data to local db
        friendsAPI.markInviteAsFriendAccepted(AcceptedFriendUserID: userFriendsData[Friends.Attributes.userID.rawValue]!)
        
    }
    
    class func processLocatedSharedPN(PNData pnData: Dictionary<String,AnyObject>){
        let locationData = PushNotificationsParser.sharedInstance.getSharedLocationDetailsFromPN(LocationDataRaw: pnData)
        
        // Create instance of LocationsAPI
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let locationsAPI = LocationsAPI(ApplicationDelegate: appDelegate)
        
        // Save Location Data to local db
        locationsAPI.createNewLocation(locationData, acceptStatus: "0")
        
    }
    
}