//
//  BackgroundLocationManager.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 13/11/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import CoreLocation

class BackgroundLocationManager: NSObject, CLLocationManagerDelegate{
    var activeWayId = ""
    var bgLocationManager = CLLocationManager()
    var lastKnownLocation = CLLocation()
    
    override init() {
        super.init()
        self.setup()
    }
    
    // MARK: Setup Location Manager
    func setup(){
        // Access available
        self.bgLocationManager.delegate = self
        
        // Location Manager best practices
        bgLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        //locationManager.allowsBackgroundLocationUpdates = false
        bgLocationManager.activityType = CLActivityType.AutomotiveNavigation
        
        bgLocationManager.allowsBackgroundLocationUpdates = true
        bgLocationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func start(ActiveWayId activeWayId: String){
        print("@\(Utils.getCurrentDateTimeAsString()): BG: Start")
        self.activeWayId = activeWayId
        bgLocationManager.startUpdatingLocation()
    }
    
    func stop(){
        print("@\(Utils.getCurrentDateTimeAsString()): BG: Stop")
        bgLocationManager.stopUpdatingLocation()
    }
    
    func startTimer(){
        print("@\(Utils.getCurrentDateTimeAsString()): BG: Start Timer")
        self.start(ActiveWayId: self.activeWayId)
        
    }
    
    func stopTimer(){
        print("@\(Utils.getCurrentDateTimeAsString()): BG: Stop Timer")
        self.stop()
    }
    
    func sendPositionUpdateToServer(){
        let currentLocation = self.lastKnownLocation
        let currentLatLong = "\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)"
        let batteryLevel = Utils.getDeviceBatteryLevel()
        let accuracy = Utils.getLocationAccuracyAsString(Location: currentLocation)
        
        DataController.sharedInstance.callUpdateMyPositionAPI(WayId: self.activeWayId, CurrentLocation: currentLatLong, BatteryLevel: batteryLevel, Accuracy: accuracy, success: { serverResponse in
            })
        { (error) in
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastKnownLocation = locations.last!
        print("@\(Utils.getCurrentDateTimeAsString()): BG: didUpdateLocations")
        if(self.lastKnownLocation.horizontalAccuracy <= Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent){
            self.sendPositionUpdateToServer()
            print("2. Position updated...")
            let locValue: CLLocationCoordinate2D = self.lastKnownLocation.coordinate
            print("@\(Utils.getCurrentDateTimeAsString()): \(locValue.latitude) \(locValue.longitude)")
        }else{
            print("Accuracy: \(self.lastKnownLocation.horizontalAccuracy) is > Default accuracy: \(Constants.Generic.defaultDistanceAfterWhichLocationUpdatesSent). Ignooring this location...")
        }
        
        let timeInterval = Constants.Generic.defaultSecondsAfterWhichLocationUpdatesSent
        NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(startTimer), userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(stopTimer), userInfo: nil, repeats: false)
    }
}