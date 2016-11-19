//
//  Constants.swift
//  WayAlerts
//
//  Created by Hari Kishore on 6/9/16.
//  Copyright © 2016 SyncMinds Technologies. All rights reserved.
//

import UIKit
import Foundation

struct Constants {
    
    // Generic
    struct Generic{
        //static let googleMapsApiKey = "AIzaSyBsyZy8VXt_CJPi_zDrgRq1aOx0ITWvghM"
        static let googleMapsApiKey = "AIzaSyCMCQTn6xGznNdNwnquFb3brm7_BqKc6EM"
        static let waRequestURL = "http://sandbox.wayalerts.com/v1.0/api/requestprocessor/requestProcessing"
        //static let waRequestURL = "http://192.168.1.13/sandbox/v1.0/api/requestprocessor/requestProcessing"
        static let networkTestURL = "http://google.com"
        static let mobileNumberLimit = 10
        static let goodResponseCode = "200";
        
        static let iPhone = "1";
        static let whitespace = NSCharacterSet.whitespaceCharacterSet();
        static let mobileNumberRegex = "^[789]\\d{9}$";
        static let nameRegex = "/^[A-Za-z]+$/"
        
        static let defaultZoomLevel = "16"
        static let defaultCountryCode = "91"
        static let iosGCMTokenDummmy = "iPhone"
        
        static let savedLocationMarkerIconName = "saved_location_29x29"
        
        static let kDefaultNavigationBarFontSize: CGFloat = 22
        
        static let kDefaultTabBarFontSize: CGFloat = 14
        
        static let defaultWayType = "1"
        static let polylineStrokeWidth: CGFloat = 5
        static let defaultDistanceAfterWhichLocationUpdatesSent = 25.0
        static let defaultSecondsAfterWhichLocationUpdatesSent = 10.0
        static let defaultAverageSpeedOfWayOwnerMetersPerSecond = 15.0
    }
    
    struct Lookups{
        static let WayStatusCreated = "0"
        static let WayStatusStarted = "1"
        static let WayStatusStopped = "2"
        static let WayStatusDisconnected = "3"
    }
    
    // Table View section headers
    struct TableSectionHeaders{
        static let FriendRequests = "Friend Requests"
        static let FriendsList = "Friends List"
        
        static let LocationRequests = "Location Requests"
        static let LocationsList = "Locations List"
        
        static let MyWay = "My Way"
        static let FriendsWay = "Friends Ways"
        static let PublicWay = "Public Ways"
    }
    
    // NSDefaults Keys
    struct NSDKeys{
        static let thisUserIdKey = "thisUserId";
        static let thisMobileNumberKey = "thisMobileNumber";
        static let isUserLoggedin = "isUserLoggedin";
        static let thisDeviceToken = "thisDeviceToken"
        
        static let appDelegage = "appDelegate"
        static let moc = "moc"
    }
    
    // Push Notifications Keys
    struct PNKeys{
        static let id = "id"
        static let username = "username"
        static let status = "status"
        static let trackablestatus = "trackablestatus"
        static let mobile = "mobile"
        static let acceptstatus = "acceptstatus"
        static let relid = "relid"
        static let fnfid = "fnfid"
        
        static let ID = "ID"
        static let LocName = "LocName"
        static let LocLat = "LocLat"
        static let LocLong = "LocLong"
        static let ZoomLevel = "ZoomLevel"
        static let LocAddr = "LocAddr"
    }
    
    // Server API Names
    struct ServerAPINames{
        static let registration = "registration";
        static let loginRequest = "loginRequest";
        static let updateUserDeviceToken = "updateUserDeviceToken";
        static let login = "login";
        static let myAccountView = "myAccountView";
        static let updateMyAccount = "updateMyAccount";
        static let resendActivationOTP = "resendActivationOTP";
        static let activateUser = "activateUser";
        static let requestMigration = "requestMigration";
        static let authMigration = "authMigration";
        static let postLogin = "postLogin";
        static let getProfilePic = "getProfilePic";
        static let addMember = "addMember";
        static let getFNF = "getFNF";
        static let blockFNFUser = "blockFNFUser";
        static let toggleTrackStatus = "toggleTrackStatus";
        static let deleteFNF = "deleteFNF";
        static let fnfRequestAction = "fnfRequestAction";
        static let addLocation = "addLocation";
        static let updateLocation = "updateLocation";
        static let deleteLocation = "deleteLocation";
        static let getLocations = "getLocations";
        static let shareLocation = "shareLocation";
        static let getWayData = "getWayData";
        static let createway = "createway";
        static let startWay = "startWay";
        static let endWay = "endWay";
        static let updateMyPosition = "updateMyPosition";
        static let getWayDetailsByID = "getWayDetailsByID";
        static let getLatestFNFWayStat = "getLatestFNFWayStat";
        static let getUpdatedPosition = "getUpdatedPosition";
        static let panicCall = "panicCall";
        static let panicAcknowledge = "panicAcknowledge";
        static let pushNotificationAck = "pushNotificationAck";
        static let unscribeUserFromActiveWay = "unscribeUserFromActiveWay";
        static let logClientError = "logClientError";
        
    }
    
    // Server Response Keys
    struct ServerResponseKeys{
        static let code = "code";
        static let message = "message";
        static let description = "description";
        static let result = "result";
        static let userdetails = "userdetails";
        static let fname = "fname"
        static let lname = "lname"
        static let userid = "userid"
        static let userFNFContacts = "userFNFContacts"
        static let userLocations = "userLocations"
        static let userAccountDetails = "userAccountDetails"
        static let id = "id"
        static let username = "username"
        static let fafuserid = "fafuserid"
        static let status = "status"
        static let trackablestatus = "trackablestatus"
        static let mobile = "mobile"
        static let onlinestatus = "onlinestatus"
        static let acceptstatus = "acceptstatus"
        // MARK: Params for userLocations     
        static let ID = "ID"
        static let LocName = "LocName"
        static let LocLat = "LocLat"
        static let LocLong = "LocLong"
        static let LocAddr = "LocAddr"
        static let ZoomLevel = "ZoomLevel"
        
        static let pncode = "pncode"
        static let ackid = "ackid"
        
        // Ways response keys
        static let WayID = "WayID"
        static let distance = "distance"
        static let duration = "duration"
        static let polylines = "polylines"
        static let batterylevel = "batterylevel"
        static let timeestimated = "timeestimated"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let callapi = "callapi"
        static let timeelapsed = "timeelapsed"
        static let totaldistance = "totaldistance"
        static let distancetravelled = "distancetravelled"
        static let wayid = "wayid"
    }
    
    // Server Request Keys
    struct ServerRequestKeys{
        static let userid = "userid"
        static let devicetoken = "devicetoken"
        static let mobile = "mobile"
        static let email = "email"
        static let password = "password"
        static let gcmregtoken = "gcmregtoken"
        static let devicetype = "devicetype"
        static let fname = "fname"
        static let lname = "lname"
        static let countrycode = "countrycode"
        static let gender = "gender"
        static let dob = "dob"
        static let imei = "imei"
        static let profilepic = "profilepic"
        static let vcode = "vcode"
        static let profilepicuserid = "profilepicuserid"
        static let currstatus = "currstatus"
        static let fnfuserid = "fnfuserid"
        static let fnfid = "fnfid"
        static let currtrackstatus = "currtrackstatus"
        static let relid = "relid"
        static let actionval = "actionval"
        static let locname = "locname"
        static let loclat = "loclat"
        static let loclong = "loclong"
        static let locaddr = "locaddr"
        static let zoomlevel = "zoomlevel"
        static let locid = "locid"
        static let fnfids = "fnfids"
        static let wayid = "wayid"
        static let wayname = "wayname"
        static let waysource = "waysource"
        static let waydestination = "waydestination"
        static let waytype = "waytype"
        static let vehiclenumber = "vehiclenumber"
        static let qrcodedata = "qrcodedata"
        static let photo = "photo"
        static let fnfuserids = "fnfuserids"
        static let currentlocation = "currentlocation"
        static let batterylevel = "batterylevel"
        static let accuracy = "accuracy"
        static let panicuserid = "panicuserid"
        static let ackid = "ackid"
        static let pncode = "pncode"
        static let deleteid = "deleteid"
        static let DeviceType = "DeviceType"
        static let ErrorType = "ErrorType"
        static let ErrorMsg = "ErrorMsg"
        static let UserID = "UserID"
    }
    
    // CellIdentifiers
    struct LocationCellIdentifiers{
        
        static let LocationNameCell = "LocationNameCell"
        static let LocationDetailsCell = "LocationDetailsCell"
        static let ViewOnMapCell = "ViewOnMapCell"
        static let ShareWithFriendsCell = "ShareWithFriendsCell"
        static let CreateWayCell = "CreateWayCell"
        static let WaysHistoryCell = "WaysHistoryCell"
        static let DeleteCell = "DeleteCell"
        
    }
    
    // CellIdentifiers
    struct SegueIdentifiers{
        
        static let FriendDetailsViewController = "FriendDetailsViewController"
        static let LocationDetailsViewController = "LocationDetailsViewController"
        
    }
    
    // Push notification types
    struct PNTypes{
        static let FriendRegisteredAsUser = "10001"
        static let FriendProfileUpdated = "10003"
        static let FriendMobileNumberUpdated = "10004"
        static let FriendInviteReceived = "10005"
        static let FriendInviteAccepted = "10006"
        static let FriendInviteRejected = "10007"
        static let LocationShared = "10008"
        static let FriendStartedWay = "10009"
        static let WayLocationUpdated = "10010"
        static let FriendWayEnded = "10011"
        static let FriendWayRecalculated = "10012"
        static let PanicAlertActivated = "10013"
        static let FriendWayExpired = "10014"
        static let FriendWayDisconnected = "10015"
        static let MTUInvite = "10016"
        static let MTUOverSpeeding = "10017"
        static let MTUNotMoving = "10018"
        static let MTUGeoFenceBreached = "10019"
        static let MTUPOIReached = "10020"
        static let MTUReachedDestination = "10021"
        static let MTUDisconnected = "10022"
        static let FriendWayNotMoving = "10023"
        static let FriendAcknowledgedWayInvite = "10024"
    }
    
}
