//
//  DataController.swift
//  WayAlerts
//
//  Created by Hari Kishore on 6/9/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import CoreData

class DataController: NSObject {
    
    var appDelegate: AppDelegate
    var moc : NSManagedObjectContext
    var wayLocationUpdatedDelegate: WayLocationUpdatedDelegate!
    
    static let sharedInstance = DataController()
    private var responseParser = ResponseParser.sharedInstance
    
    //var friendsAPI = FriendsAPI(appDelegate:nil, ManagedObjectContext: nil)
    //var locationsAPI = LocationsAPI(appDelegate:nil, ManagedObjectContext: nil)
    let thisUserID = Utils.getThisUserID()
    
    let ncInstance = NetworkController.sharedInstance;
    
    override init(){
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        moc = self.appDelegate.managedObjectContext
        //self.userAPI = UserAPI()
        //self.friendsAPI = FriendsAPI(appDelegate: appDelegate, ManagedObjectContext: moc)
    }
    
    // MARK: Server API Call Methods
    // ProcessServerResponse
    func processServerResponse(RequestName requestName: String, ServerResponse serverResponse: Dictionary<String, AnyObject>, RequestParams requestParams: Dictionary<String,String>){
        // Check to see if server responded success
        if (serverResponse.count == 0){
            return
        }
        
        var responseCode = "-1"
        do{
            responseCode =  String(serverResponse[Constants.ServerResponseKeys.code]!)// as! String
        }
        catch let error as NSError {
            Utils.showAlertOK(Title: "Oops",Message: "Server response code not set.")
        }
        
        // Proceed only if the response code is good.
        if(responseCode == Constants.Generic.goodResponseCode){
            
            let userAPI = UserAPI(ApplicationDelegate: self.appDelegate)
            let friendsAPI = FriendsAPI(ApplicationDelegate: self.appDelegate)
            let locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
            let waysAPI = WaysAPI(ApplicationDelegate: self.appDelegate)
            
            // Switch case to perform relevent action for the provided requestName
            switch (requestName){
            case (Constants.ServerAPINames.registration):
                // Parse response and get the user data to be saved in te local db
                let userDetailsToInsert = self.responseParser.getUserDetailsToInsert(ServerResponse: serverResponse)
                //
                //                // Save the data to local db
                //                self.userAPI.createNewUser(userDetailsToInsert);
                
                // Save thisUserId in memory
                Utils.setNSDString(AsKey: Constants.NSDKeys.thisUserIdKey, WithValue: userDetailsToInsert[User.Attributes.userID.rawValue]!)
                
                break
            case (Constants.ServerAPINames.loginRequest):
                break;
            case (Constants.ServerAPINames.login):
                // Parse response and get the user data to be saved in te local db
                let userDetailsToInsert = self.responseParser.getUserDetailsToInsert(ServerResponse: serverResponse)
                
                // Save the data to local db
                //var userAPI = UserAPI(ApplicationDelegate: self.appDelegate)
                userAPI.createNewUser(userDetailsToInsert);
                
                //-->
                //Call postLogin Server API to get user data stored in the server
                DataController.sharedInstance.callPostLoginAPI({ (serverResponse) in
                    })
                { (error) in
                    print("error : \(error)")
                    Utils.showAlertOK(Title: "Error",Message: "\(error)")
                    //let alert = AlertBox.shareInstance()
                    //alert.show(title: "Error", message: "\(error)", parentViewController: self)
                }
                //--<
                
                break;
            case (Constants.ServerAPINames.postLogin):
                // Parse response and get the userFriends and userLocations to be saved in te local db
                let userFriendsData = self.responseParser.getUserFriendsData(ServerResponse: serverResponse, DataIsFromPN: false)
                let userLocationsData = self.responseParser.getUserLocationsData(ServerResponse: serverResponse)
                
                // Save userFriends Data to local db
                //var friendsAPI = FriendsAPI(ApplicationDelegate: self.appDelegate)
                for aFriend in userFriendsData{
                    friendsAPI.createNewFriend(aFriend)
                }
                
                // Save userLocations Data to local db
                //var locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
                for aLocation in userLocationsData{
                    locationsAPI.createNewLocation(aLocation, acceptStatus: "1")
                }
                break;
            case (Constants.ServerAPINames.fnfRequestAction):
                // Parse request params and get the Friend user id on which action has been taken
                let primaryUserID = requestParams[Constants.ServerRequestKeys.userid]!
                let friendUserID = primaryUserID
                let actionVal = requestParams[Constants.ServerRequestKeys.actionval]!
                
                // Perform same action on local core data
                if(actionVal == "1"){
                    friendsAPI.acceptFriendRequest(FriendUserID: friendUserID)
                }
                else{
                    friendsAPI.rejectFriendRequest(FriendUserID: friendUserID)
                }
                
                break;
            case (Constants.ServerAPINames.deleteFNF):
                // Parse request params and get the Friend user id on which action has been taken
                let deletedUserID = requestParams[Constants.ServerRequestKeys.deleteid]!
                
                // Delete user from Core Data
                friendsAPI.deleteFriendWithID(deletedUserID)
                
                break;
            case (Constants.ServerAPINames.addMember):
                // Parse response and get the friend data to be saved in te local db
                let friendDetailsToInsert = self.responseParser.getFriendDetailsToInsert(ServerResponse: serverResponse)
                
                // Add friend to Core Data
                friendsAPI.createNewFriend(friendDetailsToInsert)
                
                break;
            case (Constants.ServerAPINames.blockFNFUser):
                // Get latest status of Incoming Alerts
                let oldStatus = requestParams[Constants.ServerRequestKeys.currstatus]!
                let friendUserID = requestParams[Constants.ServerRequestKeys.fnfuserid]!
                
                friendsAPI.setIncomingAlertsFlag(OldFlagValue: oldStatus, FriendUserID: friendUserID)
                
                break;
            case (Constants.ServerAPINames.toggleTrackStatus):
                // Get latest status of Outgoing Alerts
                let oldStatus = requestParams[Constants.ServerRequestKeys.currtrackstatus]!
                let friendUserID = requestParams[Constants.ServerRequestKeys.fnfuserid]!
                
                friendsAPI.setOutgoingAlertsFlag(OldFlagValue: oldStatus, FriendUserID: friendUserID)
                
                break;
            case (Constants.ServerAPINames.addLocation):
                // Parse response and get the location data to be saved in te local db
                let locationDetailsToInsert = self.responseParser.getLocationDetailsToInsert(ServerResponse: serverResponse)
                
                // Add location to Core Data
                locationsAPI.createNewLocation(locationDetailsToInsert,acceptStatus: "1")
                
                break;
            case (Constants.ServerAPINames.deleteLocation):
                // Get the deleted location id fmor request params
                let deletedLocId = requestParams[Constants.ServerRequestKeys.locid]!
                
                // Delete location from Core Data
                locationsAPI.deleteLocationWithID(deletedLocId)
                
                break;
            case (Constants.ServerAPINames.updateLocation):
                // Get the updated location id fmor request params
                let updatedLocId = requestParams[Constants.ServerRequestKeys.locid]!
                let updatedLocName = requestParams[Constants.ServerRequestKeys.locname]!
                let updatedLocAddress = requestParams[Constants.ServerRequestKeys.locaddr]!
                
                // Update location from Core Data
                locationsAPI.updateLocation(LocID: updatedLocId, LocName: updatedLocName, LocAddress: updatedLocAddress)
                
                break;
            case (Constants.ServerAPINames.createway):
                // Parse response and get the way data to be saved in te local db
                let wayDetailsToInsert = self.responseParser.getWayDetailsToInsert(ServerResponse: serverResponse, RequestParams:requestParams)
                
                // Add Way to Core Data
                waysAPI.createNewWay(wayDetailsToInsert)
                
                // Set the wayId in singleton class
                Singleton.sharedInstance.wayID = wayDetailsToInsert[Ways.Attributes.wayID.rawValue]!
                
                // Now call getWayData API
                self.callGetWayDataAPI(WayID: wayDetailsToInsert[Ways.Attributes.wayID.rawValue]!, success: {serverResponse in
                    })
                { (error) in
                    print("error : \(error)")
                    Utils.showAlertOK(Title: "Error",Message: "\(error)")
                }
                
                break;
            case (Constants.ServerAPINames.getWayData):
                // Parse response and get the way data to be saved in te local db
                let wayDetailsToUpdate = self.responseParser.getWayDetailsToUpdate(ServerResponse: serverResponse, RequestParams:requestParams)
                
                // Add Way to Core Data
                waysAPI.updateWayWithGetWayDataApiResponse(wayDetailsToUpdate)
                
                break;
            case (Constants.ServerAPINames.startWay):
                // Get the wayId thats been started
                let startedWayId = requestParams[Constants.ServerRequestKeys.wayid]
                
                // Add Way to Core Data
                waysAPI.updateWayStatusToStarted(StartedWayId: startedWayId!)
                
                break;
            case (Constants.ServerAPINames.updateMyPosition):
                // Get the wayId thats been started
                let wayId = requestParams[Constants.ServerRequestKeys.wayid]
                
                // TODO: Write code to update my position...
                let wayDetailsToUpdate = self.responseParser.getResultFromUpdateMyPositionResponse(ServerResponse: serverResponse, RequestParams:requestParams)
                
                // Now update core data
                waysAPI.updateWayWithProcessedCurrentLocationDataFromServer(wayDetailsToUpdate)
                
                // Now send message to map to redraw current location marker
                let latestLocationLatLong = String(wayDetailsToUpdate["recordedLatLong"]!)
                self.wayLocationUpdatedDelegate!.wayCurrentLocationUpdated(WayId: wayId!, LatestLocationLatLong: latestLocationLatLong)
                
                break;
            case (Constants.ServerAPINames.endWay):
                // Get the wayId thats been started
                let endedWayId = requestParams[Constants.ServerRequestKeys.wayid]
                
                // TODO: Write code to update my position...
                
                break;
            case (Constants.ServerAPINames.logClientError):
                // No Action required. Just ignore it.
                break;
            default:
                print("Illegal Request Name")
            }
        }
        else{
            Utils.showAlertOK(Title: serverResponse[Constants.ServerResponseKeys.message]! as! String, Message: serverResponse[Constants.ServerResponseKeys.description]! as! String)
        }
    }
    
    // Registration API
    func callRegistrationAPI(FirstName fname : String!,
                                       LastName lname : String!,
                                                //Email email : String,
        Mobile mobile : String!,
               //CountryCode countrycode : String,
        //Gender gender : String,
        //DateOfBirth dob : String,
        IMEI imei : String!,
             GCMRegToken gcmregtoken : String!,
                         success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.registration;
        
        //2. Create API specific parameters into a dictionary
        //let apiSpecificParams = ["fname":fname,"lname":lname,"email":"","mobile":mobile,"countrycode":"91","gender":"","dob":"","imei":imei,"gcmregtoken":gcmregtoken]  as Dictionary<String, String>;
        let apiSpecificParams = [Constants.ServerRequestKeys.fname:fname,
                                 Constants.ServerRequestKeys.lname:lname,
                                 Constants.ServerRequestKeys.email:"",
                                 Constants.ServerRequestKeys.mobile:mobile,
                                 Constants.ServerRequestKeys.countrycode:Constants.Generic.defaultCountryCode,
                                 Constants.ServerRequestKeys.gender:"",
                                 Constants.ServerRequestKeys.dob:"",
                                 Constants.ServerRequestKeys.imei:"",
                                 Constants.ServerRequestKeys.gcmregtoken:Constants.Generic.iosGCMTokenDummmy
            ]  as Dictionary<String, String>!;
        
        //3. Place server API request
        ncInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse )
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    // LoginRequest API
    func callLoginRequestAPI(mobile mobileNumber : String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.loginRequest;
        
        //2. Create API specific parameters into a dictionary
        let apiSpecificParams = [Constants.ServerRequestKeys.mobile:mobileNumber] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (data) in
            success(responseData: data)
            
            // Save thisMobileNumber in memory
            Utils.setNSDString(AsKey: Constants.NSDKeys.thisMobileNumberKey, WithValue: mobileNumber)
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    // Login API
    func callLoginAPI(Mobile mobileNumber : String, OTP otp: String, GCMRegToken gcmregtoken: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.login;
        
        //2. Create API specific parameters into a dictionary
        let apiSpecificParams = [Constants.ServerRequestKeys.email:mobileNumber,
                                 Constants.ServerRequestKeys.password:otp,
                                 Constants.ServerRequestKeys.gcmregtoken:gcmregtoken,
                                 Constants.ServerRequestKeys.devicetype:Constants.Generic.iPhone
            ] as Dictionary<String,String>;
        
        //3. Place server API request
        ncInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse )
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
        
    }
    
    // Update Device Token API
    func callUpdateDeviceTokenAPI (DeviceToken deviceToken: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.updateUserDeviceToken;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID();
        let apiSpecificParams = [Constants.ServerRequestKeys.userid:userID, Constants.ServerRequestKeys.devicetoken: deviceToken] as Dictionary<String,String>;
        
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    
    // postLogin API Call
    func callPostLoginAPI (success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.postLogin;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID();
        let apiSpecificParams = [Constants.ServerRequestKeys.userid:userID] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
        
    }
    
    // Push Notification Ack API Call
    func callPushNotificationAckPI (AckID ackID: String, PNCode pnCode: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.pushNotificationAck;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID();
        let apiSpecificParams = [Constants.ServerRequestKeys.userid:userID,
                                 Constants.ServerRequestKeys.ackid:ackID,
                                 Constants.ServerRequestKeys.pncode: pnCode] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName,
                                                            APISpecificParams: apiSpecificParams,
                                                            Success: { (serverResponse) in
                                                                success(responseData: serverResponse)
                                                                
                                                                // Process server response to poopulate local db, if needed.
                                                                //self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse );
                                                                
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
        
    }
    
    // MyAccountView API
    func callMyAccountViewAPI(UserID userID : String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.myAccountView;
        
        //2. Create API specific parameters into a dictionary
        let apiSpecificParams = [Constants.ServerRequestKeys.userid:userID] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (data) in
            success(responseData: data )
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    
    // MARK: FNFRequest API
    func callFnfRequestActionAPI(FnfID fnfID : String, ActionVal actionVal : String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.fnfRequestAction;
        
        //2. Create API specific parameters into a dictionary
        //let userID = Utils.getThisUserID()
        let prmaryiUserID = fnfID // Use who actually sent this friend request
        let relID = prmaryiUserID // Will always be equal to primary user id
        let secondaryUserID = Utils.getThisUserID() // User who received this friend request
        
        let apiSpecificParams = [Constants.ServerRequestKeys.relid: relID, Constants.ServerRequestKeys.userid: prmaryiUserID, Constants.ServerRequestKeys.fnfid: secondaryUserID, Constants.ServerRequestKeys.actionval: actionVal] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    // MARK: Delete Friend API
    func callDeleteFNFAPI(DeletedFriendID deletedFriendID : String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.deleteFNF;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID() // User who received this friend request
        
        let apiSpecificParams = [Constants.ServerRequestKeys.deleteid: deletedFriendID, Constants.ServerRequestKeys.userid: userID] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    // MARK: Friend Invite Friend API
    func callAddMemberAPI(MobileNumber mobileNumber : String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.addMember;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID() // User who received this friend request
        
        let apiSpecificParams = [Constants.ServerRequestKeys.mobile: mobileNumber, Constants.ServerRequestKeys.userid: userID] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    // MARK: Block User API
    func callBlockUserAPI(FriendUserID friendUserID: String, CurrentStatus currentStatus : String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.blockFNFUser;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID()
        
        let apiSpecificParams = [Constants.ServerRequestKeys.userid: userID, Constants.ServerRequestKeys.currstatus: currentStatus, Constants.ServerRequestKeys.fnfuserid: friendUserID] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    // MARK: Toggle Track Status API
    func callToggleTrackStatusrAPI(FriendUserID friendUserID: String, CurrentStatus currentStatus : String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.toggleTrackStatus;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID()
        
        let apiSpecificParams = [Constants.ServerRequestKeys.userid: userID, Constants.ServerRequestKeys.currtrackstatus: currentStatus, Constants.ServerRequestKeys.fnfuserid: friendUserID] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    // MARK: Add Location API
    func callAddLocationAPI(LocationName locationName: String, LocationLatitude locationLatitude : String, LocationLongitude locationLongitude : String, LocationAddress locationAddress : String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.addLocation;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID()
        
        let apiSpecificParams = [Constants.ServerRequestKeys.userid: userID, Constants.ServerRequestKeys.locname: locationName, Constants.ServerRequestKeys.loclat: locationLatitude, Constants.ServerRequestKeys.loclong: locationLongitude, Constants.ServerRequestKeys.locaddr: locationAddress, Constants.ServerRequestKeys.zoomlevel: Constants.Generic.defaultZoomLevel] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    // MARK: Delete Location API
    func callDeleteLocationAPI(LocationId locationId: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.deleteLocation;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID()
        
        let apiSpecificParams = [Constants.ServerRequestKeys.userid: userID, Constants.ServerRequestKeys.locid: locationId] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    // MARK: Share Location API
    func callShareLocationAPI(LocationId locationId: String, SelectedFriendsString selectedFriends: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.shareLocation;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID()
        
        let apiSpecificParams = [Constants.ServerRequestKeys.userid: userID,
                                 Constants.ServerRequestKeys.locid: locationId,
                                 Constants.ServerRequestKeys.fnfids: selectedFriends] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    // MARK: Update Location API
    func callUpdateLocationAPI(LocationId locationId: String,
                                          LocationName locationName: String,
                                                       LocationAddress locationAddress: String,
                                                                       success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.updateLocation;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID()
        
        let apiSpecificParams = [Constants.ServerRequestKeys.userid: userID,
                                 Constants.ServerRequestKeys.locid: locationId,
                                 Constants.ServerRequestKeys.locaddr: locationAddress,
                                 Constants.ServerRequestKeys.locname: locationName] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    // MARK: Ways Module APIs
    func callGetWayDataAPI(WayID wayID: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.getWayData;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID()
        
        let apiSpecificParams = [Constants.ServerRequestKeys.userid: userID,
                                 Constants.ServerRequestKeys.wayid: wayID] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    func callCreateWayAPI (WayName wayName: String, WaySource waySource: String, WayDestination wayDestination: String,WayType wayType: String, VehicleNumber vehicleNumber: String, QrcodeData qrcodeData: String,Photo photo: String, FnfUserIds fnfUserIds: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.createway;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID()
        
        let apiSpecificParams = [Constants.ServerRequestKeys.userid: userID,
                                 Constants.ServerRequestKeys.wayname: wayName,
                                 Constants.ServerRequestKeys.waysource: waySource,
                                 Constants.ServerRequestKeys.waydestination: wayDestination,
                                 Constants.ServerRequestKeys.waytype: wayType,
                                 Constants.ServerRequestKeys.vehiclenumber: vehicleNumber,
                                 Constants.ServerRequestKeys.qrcodedata: qrcodeData,
                                 Constants.ServerRequestKeys.photo: photo,
                                 Constants.ServerRequestKeys.fnfuserids: fnfUserIds] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    func callStartWayAPI (WayId wayId: String, CurrentLocation currentLocation: String, BatteryLevel batteryLevel: String, Accuracy accuracy: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.startWay;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID()
        
        let apiSpecificParams = [Constants.ServerRequestKeys.userid: userID,
                                 Constants.ServerRequestKeys.wayid: wayId,
                                 Constants.ServerRequestKeys.currentlocation: currentLocation,
                                 Constants.ServerRequestKeys.accuracy: accuracy,
                                 Constants.ServerRequestKeys.batterylevel: batteryLevel] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    func callEndWayAPI (WayId wayId: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.endWay;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID()
        
        let apiSpecificParams = [Constants.ServerRequestKeys.userid: userID,
                                 Constants.ServerRequestKeys.wayid: wayId] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    func callUpdateMyPositionAPI (WayId wayId: String, CurrentLocation currentLocation: String, BatteryLevel batteryLevel: String, Accuracy accuracy: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.updateMyPosition;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID()
        
        let apiSpecificParams = [Constants.ServerRequestKeys.userid: userID,
                                 Constants.ServerRequestKeys.wayid: wayId,
                                 Constants.ServerRequestKeys.currentlocation: currentLocation,
                                 Constants.ServerRequestKeys.accuracy: accuracy,
                                 Constants.ServerRequestKeys.batterylevel: batteryLevel] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
    func callLogClientErrorAPI (DeviceType deviceType: String, ErrorType errorType: String, ErrorMsg errorMsg: String, success : (responseData : Dictionary<String,AnyObject>)->(), failure : (error : NSError)->()) {
        
        return;
        
        
        //1. Set requestName param
        let requestName = Constants.ServerAPINames.logClientError;
        
        //2. Create API specific parameters into a dictionary
        let userID = Utils.getThisUserID()
        
        let apiSpecificParams = [Constants.ServerRequestKeys.UserID: userID,
                                 Constants.ServerRequestKeys.DeviceType: deviceType,
                                 Constants.ServerRequestKeys.ErrorType: errorType,
                                 Constants.ServerRequestKeys.ErrorMsg: errorMsg] as Dictionary<String,String>;
        
        //3. Place server API request
        NetworkController.sharedInstance.placeServerRequest(RequestName: requestName, APISpecificParams: apiSpecificParams, Success: { (serverResponse) in
            success(responseData: serverResponse)
            
            // Process server response to poopulate local db, if needed.
            self.processServerResponse(RequestName: requestName,ServerResponse: serverResponse, RequestParams: apiSpecificParams );
            
            })
        { (error) in
            //print(error)
            failure(error: error)
        }
    }
    
}
