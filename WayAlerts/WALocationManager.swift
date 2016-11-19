//
//  WALocationManager.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 24/09/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class WALocationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Local Variables
    let locationManager = CLLocationManager()
    //var callingViewController = UIViewController()
    var locationRetrievalAllowed = false
    var lastKnownLocation = CLLocation()
    var isBGLocationUpdatesRunning = false
    var activeWayId = ""
    var deferringUpdates = false
    static let sharedInstance = WALocationManager()
    var hasWayEnded = false
    
    var nsTimer_1 = NSTimer()
    var nsTimer_2 = NSTimer()
    var nsBGTimer_1 = NSTimer()
    var nsBGTimer_2 = NSTimer()
    
    var currTimerMode = "FOREGROUND"
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    var didProcessLocationUpdateInThisCycle = false
    
    var currentLocationsList = [CLLocation]()
    var startedPopulatingCurrLocationsList = false
    
    override init(){
        super.init()
        self.setupLocationService()
    }
    // MARK: - Convenience Init
    //    convenience init(CallingVC callingVC: UIViewController) {
    //        self.init()
    //        //self.callingViewController = callingVC
    //        self.setupLocationService()
    //
    //    }
    
    // MARK: - Custom Functions
    func setupLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            switch (CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied, .AuthorizedWhenInUse:
                // print("No access")
                self.requestGrantLocationServicesAccess()
            case .AuthorizedAlways:
                // Access available
                locationRetrievalAllowed = true
                locationManager.delegate = self
                
                // Location Manager best practices
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.activityType = CLActivityType.AutomotiveNavigation
                locationManager.pausesLocationUpdatesAutomatically = false
                
                // As per the special note in https://developer.apple.com/reference/corelocation/cllocationmanager/1620547-allowdeferredlocationupdates
                //locationManager.distanceFilter = self.getDefaultDistanceThreshold()
                self.setDistanceFilter()
                
                //Utils.setNSDBool(AsKey: "AppIsBackground", WithValue: false)
                //Singleton.sharedInstance.waLocationManager = self
                //waLocationManager = self
            }
        } else {
            // Location services are not enabled
            self.requestEnableLocationServices()
        }
    }
    
    func startLocationMonitor(){
        locationManager.startUpdatingLocation()
        
        //--> Debug: Sandeep Mallila, 12 Nov 16
        DataController.sharedInstance.callLogClientErrorAPI(DeviceType: "2", ErrorType: "startLocationMonitor", ErrorMsg: "Loc Monitoring Started",  success: { serverResponse in
            })
        { (error) in
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        }
        //--< Debug: Sandeep Mallila, 12 Nov 16
        
    }
    
    func stopLocationMonitor(){
        locationManager.stopUpdatingLocation()
        
        //--> Debug: Sandeep Mallila, 12 Nov 16
        DataController.sharedInstance.callLogClientErrorAPI(DeviceType: "2", ErrorType: "stopLocationMonitor", ErrorMsg: "Loc Monitoring Stopped",  success: { serverResponse in
            })
        { (error) in
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        }
        //--< Debug: Sandeep Mallila, 12 Nov 16
    }
    
    func requestEnableLocationServices()
    {
        let alert = UIAlertController(title: StringConstants.ForLocationServices.enableLocationServicesAlertTitle, message: StringConstants.ForLocationServices.enableLocationServicesAlertMsg, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: StringConstants.ForLocationServices.enableLocationServicesAlertSettingsBtnLbl, style: UIAlertActionStyle.Default, handler:
            {
                (alert: UIAlertAction!) in
                // action -> Void in success?()
                // print("")
                UIApplication.sharedApplication().openURL(NSURL(string: "prefs:root=Privacy&path=LOCATION")!)
        })
        )
        
        // Now add cancel action
        let cancelAction = UIAlertAction(title: StringConstants.ForLocationServices.enableLocationServicesAlertCancelBtnLbl, style: .Cancel, handler:
            {
                // action -> Void in cancel?()
                (alert: UIAlertAction!) -> Void in
        })
        
        alert.addAction(cancelAction)
        //self.callingViewController.presentViewController(alert, animated: true, completion: nil)
        Utils.getCurrentViewController()?.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func requestGrantLocationServicesAccess()
    {
        let alert = UIAlertController(title: StringConstants.ForLocationServices.enableLocationServicesAccessAlertTitle, message: StringConstants.ForLocationServices.enableLocationServicesAccessAlertMsg, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: StringConstants.ForLocationServices.enableLocationServicesAlertSettingsBtnLbl, style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction!) in
            // print("")
            // action -> Void in success?()
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }))
        // Now add cancel action
        let cancelAction = UIAlertAction(title: StringConstants.ForLocationServices.enableLocationServicesAlertCancelBtnLbl, style: .Cancel, handler:
            {
                // action -> Void in cancel?()
                (alert: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        //self.callingViewController.presentViewController(alert, animated: true, completion: nil)
        Utils.getCurrentViewController()?.presentViewController(alert, animated: true, completion: nil)
        // self.presentViewController(alert, animated: true, completion: nil)
        
        self.locationManager.requestAlwaysAuthorization()
        
    }
    
    func getLastKnownLocation() -> CLLocation?{
        if (locationRetrievalAllowed) {
            return self.lastKnownLocation
        } else {
            self.setupLocationService()
            return nil
        }
    }
    
    func startUpdatingLocation(WayID wayId: String, WayJustStarted wayJustStarted: Bool) {
        self.startUpdatingLocation(WayID: wayId)
        if (wayJustStarted){
            self.hasWayEnded = false
        }
    }
    
    func startUpdatingLocation(WayID wayId: String) {
        print("In startUpdatingLocation")
        if (locationRetrievalAllowed && !self.isBGLocationUpdatesRunning) {
            print("1")
            locationManager.allowsBackgroundLocationUpdates = true
            self.activeWayId = wayId
            locationManager.startUpdatingLocation()
            self.isBGLocationUpdatesRunning = true
            
            //--> Debug: Sandeep Mallila, 12 Nov 16
            DataController.sharedInstance.callLogClientErrorAPI(DeviceType: "2", ErrorType: "startUpdatingLocation", ErrorMsg: "Loc Updates Started",  success: { serverResponse in
                })
            { (error) in
                print("error : \(error)")
                Utils.showAlertOK(Title: "Error", Message: "\(error)")
            }
            //--< Debug: Sandeep Mallila, 12 Nov 16
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
        self.isBGLocationUpdatesRunning = false
        
        //--> Debug: Sandeep Mallila, 12 Nov 16
        DataController.sharedInstance.callLogClientErrorAPI(DeviceType: "2", ErrorType: "stopUpdatingLocation", ErrorMsg: "Loc Updates Stopped",  success: { serverResponse in
            })
        { (error) in
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        }
        //--< Debug: Sandeep Mallila, 12 Nov 16
    }
    
    func stopUpdatingLocation(isWayEnded: Bool) {
        self.stopUpdatingLocation()
        self.hasWayEnded = true
    }
    
    func sendPositionUpdateToServer() {
        // Show busy icon
        //self.callingViewController.view.startBusySpinner()
        
        //--> Debug: Sandeep Mallila, 12 Nov 16
        DataController.sharedInstance.callLogClientErrorAPI(DeviceType: "2", ErrorType: "sendPositionUpdateToServer", ErrorMsg: "Loc To Server",  success: { serverResponse in
            })
        { (error) in
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        }
        //--< Debug: Sandeep Mallila, 12 Nov 16
        
        let currentLocation = self.lastKnownLocation
        let currentLatLong = "\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)"
        let batteryLevel = Utils.getDeviceBatteryLevel()
        let accuracy = Utils.getLocationAccuracyAsString(Location: currentLocation)
        
        DataController.sharedInstance.callUpdateMyPositionAPI(WayId: self.activeWayId, CurrentLocation: currentLatLong, BatteryLevel: batteryLevel, Accuracy: accuracy, success: { serverResponse in
            // Hide busy icon
            //self.callingViewController.view.stopBusySpinner()
            })
        { (error) in
            // Hide busy icon
            //self.callingViewController.view.stopBusySpinner()
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        }
    }
    
    //    func getDefaultDistanceThreshold() -> CLLocationDistance {
    //        let distance: String = Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent
    //        let mdf = MKDistanceFormatter()
    //        mdf.units = .Metric
    //        return mdf.distanceFromString(distance)
    //    }
    
    func getUserInstantaneousSpeed() -> CLLocationSpeed {
        var speed = ""
        // If a valid speed available, return it
        if(self.lastKnownLocation.speed > 0){
            return self.lastKnownLocation.speed
        }
        
        // Return speed from constants
        return CLLocationSpeed(Double(Constants.Generic.defaultAverageSpeedOfWayOwnerMetersPerSecond))
    }
    
    func setDistanceFilter() {
        let avgSpeed = self.getUserInstantaneousSpeed()
        let time = Constants.Generic.defaultSecondsAfterWhichLocationUpdatesSent
        let distance = avgSpeed * time
        
        if (distance < Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent){
            locationManager.distanceFilter = Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent
        }else{
            locationManager.distanceFilter = distance
        }
        
        //--> Debug: Sandeep Mallila, 12 Nov 16
        DataController.sharedInstance.callLogClientErrorAPI(DeviceType: "2", ErrorType: "setDistanceFilter", ErrorMsg: "Distance= \(locationManager.distanceFilter), Speed= \(avgSpeed)",  success: { serverResponse in
            })
        { (error) in
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        }
        //--< Debug: Sandeep Mallila, 12 Nov 16
        
        //let mdf = MKDistanceFormatter()
        //mdf.units = .Metric
        //locationManager.distanceFilter = distance
        //mdf.distanceFromString(String(distance))
    }
    
    func restartLocationUpdateService(){
        self.locationManager.stopUpdatingLocation()
        self.locationManager.startUpdatingLocation()
    }
    
    func startTimer(){
        print("@\(Utils.getCurrentDateTimeAsString()): StartTimer: \(self.currTimerMode))")
        //--> Debug: Sandeep Mallila, 12 Nov 16
        DataController.sharedInstance.callLogClientErrorAPI(DeviceType: "2", ErrorType: "startTimer", ErrorMsg: "About to start timer task: startLocationUpdates...",  success: { serverResponse in
            })
        { (error) in
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        }
        //--< Debug: Sandeep Mallila, 12 Nov 16
        
        self.startUpdatingLocation(WayID: self.activeWayId)
        self.didProcessLocationUpdateInThisCycle = false
        
    }
    
    func stopTimer(){
        print("@\(Utils.getCurrentDateTimeAsString()): Stop Timer: \(self.currTimerMode)")
        //self.startUpdatingLocation(WayID: self.activeWayId)
        self.stopUpdatingLocation()
        self.startedPopulatingCurrLocationsList = false
        self.currentLocationsList = [CLLocation]()
    }
    
    func processLocationToBeSentToServer(){
        let appIsBackground = Utils.getNSDBool(WithKey: "AppIsBackground")
        //var nsTimer_1 = NSTimer()
        //var nsTimer_2 = NSTimer()
        
        if(self.lastKnownLocation.horizontalAccuracy <= Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent){
            self.sendPositionUpdateToServer()
            print("Position updated...")
        }else{
            print("Accuracy: \(self.lastKnownLocation.horizontalAccuracy) is > Default accuracy: \(Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent). Ignoring this location...")
        }
        
        self.nsBGTimer_1.invalidate()
        self.nsBGTimer_2.invalidate()
        self.nsTimer_1.invalidate()
        self.nsTimer_2.invalidate()
        
        
        self.setDistanceFilter()
        self.stopUpdatingLocation()
        let timeInterval = Constants.Generic.defaultSecondsAfterWhichLocationUpdatesSent
        
        if(appIsBackground){
            backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
                UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskIdentifier!)
            })
            self.nsBGTimer_1 = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(startTimer), userInfo: nil, repeats: false)
        }else{
            self.nsTimer_1 = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(startTimer), userInfo: nil, repeats: false)
            self.nsTimer_2 = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(stopTimer), userInfo: nil, repeats: false)
            //self.nsTimer_1 = nsTimer_1
            //self.nsTimer_2 = nsTimer_2
            currTimerMode = "FOREGROUND"
        }
 
    }
    
    // MARK: - LocationManager Delegate Functions
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastKnownLocation = locations.last!
        print("<----------------@\(Utils.getCurrentDateTimeAsString()):----------------->")
        print("In didUpdateLocations: \(self.currTimerMode)")
        
        //-->
        if self.activeWayId.isEmpty{
            // No active way exists. This means user did not start a way and this location update is a result of one time location request by the user.
            // Stop the locations update service after 3 seconds
            //NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(stopTimer), userInfo: nil, repeats: false)
            self.stopLocationMonitor()
            //self.currentLocationsList.append(locations.last!)
            //self.startedPopulatingCurrLocationsList = true
        }
        else{
            
            // Active way id exists. This means there is an owner initiated actite way and location update service should be running periodically
            if(self.didProcessLocationUpdateInThisCycle){
                return
            }
            //--<
            
            //-->
            let appIsBackground = Utils.getNSDBool(WithKey: "AppIsBackground")
            if (appIsBackground){
                print("App is in Background mode... Keep it running...")
                
                // Send location update to server
                self.processLocationToBeSentToServer()
//                if(self.lastKnownLocation.horizontalAccuracy <= Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent){
//                    self.sendPositionUpdateToServer()
//                    print("Position updated...")
//                }else{
//                    print("Accuracy: \(self.lastKnownLocation.horizontalAccuracy) is > Default accuracy: \(Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent). Ignoring this location...")
//                }
//                
//                self.nsTimer_1.invalidate()
//                self.nsTimer_2.invalidate()
//                self.nsBGTimer_1.invalidate()
//                self.nsBGTimer_2.invalidate()
//                currTimerMode = "BACKGROUND"
//                
//                self.setDistanceFilter()
//                self.stopUpdatingLocation()
//                let timeInterval = Constants.Generic.defaultSecondsAfterWhichLocationUpdatesSent
//                
//                backgroundTaskIdentifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
//                    UIApplication.sharedApplication().endBackgroundTask(self.backgroundTaskIdentifier!)
//                })
//                self.nsBGTimer_1 = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(startTimer), userInfo: nil, repeats: false)
//                //self.nsBGTimer_2 = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(stopTimer), userInfo: nil, repeats: false)
                didProcessLocationUpdateInThisCycle = true
            }
            else{
                if ((self.isBGLocationUpdatesRunning) && !(self.hasWayEnded)){// && (self.lastKnownLocation.horizontalAccuracy <= Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent)){
                    print("isBGLocationUpdatesRunning is true...!")
                    self.processLocationToBeSentToServer()
//                    if(self.lastKnownLocation.horizontalAccuracy <= Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent){
//                        self.sendPositionUpdateToServer()
//                        print("Position updated...")
//                    }else{
//                        print("Accuracy: \(self.lastKnownLocation.horizontalAccuracy) is > Default accuracy: \(Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent). Ignoring this location...")
//                    }
//                    
//                    self.nsBGTimer_1.invalidate()
//                    self.nsBGTimer_2.invalidate()
//                    currTimerMode = "FOREGROUND"
//                    
//                    self.setDistanceFilter()
//                    self.stopUpdatingLocation()
//                    let timeInterval = Constants.Generic.defaultSecondsAfterWhichLocationUpdatesSent
//                    nsTimer_1 = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(startTimer), userInfo: nil, repeats: false)
//                    nsTimer_2 = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(stopTimer), userInfo: nil, repeats: false)
                }
                else{
                    if !(appIsBackground){
                        print("isBGLocationUpdatesRunning is FALSE...!")
                        print("Force stopping location updates...")
                        manager.stopUpdatingLocation()
                        self.stopUpdatingLocation()
                    }
                }
            }
        }
        //--<
        
        //        //--> Debug: Sandeep Mallila, 12 Nov 16
        //        DataController.sharedInstance.callLogClientErrorAPI(DeviceType: "2", ErrorType: "didUpdateLocations", ErrorMsg: "1",  success: { serverResponse in
        //            })
        //        { (error) in
        //            print("error : \(error)")
        //            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        //        }
        //        
        //        //--< Debug: Sandeep Mallila, 12 Nov 16
        
        //        if ((self.isBGLocationUpdatesRunning) && !(self.hasWayEnded)){// && (self.lastKnownLocation.horizontalAccuracy <= Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent)){
        //            print("isBGLocationUpdatesRunning is true...!")
        //            if(self.lastKnownLocation.horizontalAccuracy <= Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent){
        //                self.sendPositionUpdateToServer()
        //                print("Position updated...")
        //            }else{
        //                print("Accuracy: \(self.lastKnownLocation.horizontalAccuracy) is > Default accuracy: \(Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent). Ignoring this location...")
        //            }
        //            
        //            self.nsBGTimer_1.invalidate()
        //            self.nsBGTimer_2.invalidate()
        //            currTimerMode = "FOREGROUND"
        //            
        //            self.setDistanceFilter()
        //            self.stopUpdatingLocation()
        //            let timeInterval = Constants.Generic.defaultSecondsAfterWhichLocationUpdatesSent
        //            nsTimer_1 = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(startTimer), userInfo: nil, repeats: false)
        //            nsTimer_2 = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(stopTimer), userInfo: nil, repeats: false)
        //            
        //            
        //            //self.restartLocationUpdateService()
        //            
        //            //            // Defer updates until the user hikes a certain distance or a period of time has passed
        //            //            if (!deferringUpdates) {
        //            //                let distance: CLLocationDistance = self.getDefaultDistanceThreshold()
        //            //                let time: NSTimeInterval = Constants.Generic.defaultSecondsAfterWhichLocationUpdatesSent
        //            //                locationManager.allowDeferredLocationUpdatesUntilTraveled(distance, timeout: time)
        //            //                deferringUpdates = true;
        //            //            }
        //        }else{
        //            let appIsBackground = Utils.getNSDBool(WithKey: "AppIsBackground")
        //            if !(appIsBackground){
        //                print("isBGLocationUpdatesRunning is FALSE...!")
        //                print("Force stopping location updates...")
        //                manager.stopUpdatingLocation()
        //                self.stopUpdatingLocation()
        //            }else{
        //                print("App is in Background mode... Keep it running...")
        //                currTimerMode = "BACKGROUND"
        //                self.nsTimer_1.invalidate()
        //                self.nsTimer_2.invalidate()
        //                
        //                let timeInterval = Constants.Generic.defaultSecondsAfterWhichLocationUpdatesSent
        //                manager.stopUpdatingLocation()
        //                self.stopUpdatingLocation()
        //                
        //                self.setDistanceFilter()
        //                manager.startUpdatingLocation()
        //                self.startUpdatingLocation(WayID: self.activeWayId)
        //                
        //                self.nsBGTimer_1 = NSTimer.scheduledTimerWithTimeInterval(timeInterval*4, target: self, selector: #selector(startTimer), userInfo: nil, repeats: false)
        //                self.nsBGTimer_2 = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(stopTimer), userInfo: nil, repeats: false)
        //            }
        //        }
        
        //        if (self.hasWayEnded){
        //            print("Way ended. Stop location updates...")
        //            manager.stopUpdatingLocation()
        //            self.stopUpdatingLocation()
        //        }
        
        let locValue: CLLocationCoordinate2D = self.lastKnownLocation.coordinate
        print("@\(Utils.getCurrentDateTimeAsString()): \(locValue.latitude) \(locValue.longitude)")
    }
    
    //    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError!) {
    //        // Stop deferring updates
    //        self.deferringUpdates = false
    //    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // Stop busy spinner since requestLocation may take a few seconds before returning value
        // self.callingViewController.view.stopBusySpinner()
    }
}