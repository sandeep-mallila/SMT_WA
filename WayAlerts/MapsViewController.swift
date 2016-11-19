//
//  MapsViewController.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 30/08/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import EZAlertController

var globalLocationManager = WALocationManager()

class MapsViewController: UIViewController, GMSMapViewDelegate, WayLocationUpdatedDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var btnWayAction: UIBarButtonItem!
    @IBAction func btnWayActionTapped(sender: AnyObject) {
        if(btnWayAction.title == "Start"){
            btnWayAction.title = "Stop"
            btnWayAction.tintColor = UIColor.redColor()
            self.startWay()
        }else if(btnWayAction.title == "Stop"){
            btnWayAction.title = "Start"
            btnWayAction.tintColor = UIColor.blueColor()
            self.endWay()
        }
    }
    
    
    var selectedMapPoint = GMSMarker()
    var selectedMapPointAddress = ""
    var dynamicMenuView = UIView()
    var mapSelectionAvailable = false
    
    var allSavedMarkers: Dictionary<String, GMSMarker> = [:]
    
    var zoomedLocationId = ""
    
    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext = NSManagedObjectContext()
    
    // Variables to hold way routes to be displayed
    var allVisibleWays = [WayOnMap]()
    var waLocationManager = WALocationManager.sharedInstance
    
    ////// Google map initialization
    
    //    lazy var locationManager: CLLocationManager! = {
    //        let manager = CLLocationManager()
    //        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    //        manager.delegate = self
    //        let authorizationStatus = CLLocationManager.authorizationStatus()
    //        if (authorizationStatus == CLAuthorizationStatus.NotDetermined) {
    //            manager.requestWhenInUseAuthorization()
    //        } else if (authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse) {
    //            manager.startUpdatingLocation()
    //        }
    //        
    //        return manager
    //    }()
    
    //////
    
    override func loadView() {
        super.loadView()
        
        // Set the Way Location Updated delegate
        DataController.sharedInstance.wayLocationUpdatedDelegate = self
        
        // self.locationManager.startUpdatingLocation()
        mapView.delegate = self
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Draw all saved locations on map
        self.drawAllSavedLocationMarkers()
        
        // Create dynamic menu subview
        self.createDynamicMenuSubView()
        
        if (mapSelectionAvailable) {
            dynamicMenuView.hidden = false
        } else {
            dynamicMenuView.hidden = true
        }
        
        // Populate all visible Ways
        self.populateAllMapVisibleWays()
        
        // Create active way status view
        self.createActiveWaysView()
    }
    
    override func viewWillAppear(animated: Bool) {
        waLocationManager.startLocationMonitor()
        if !Singleton.sharedInstance.wayID.isEmpty {
            print(Singleton.sharedInstance.wayID)
            
            // Populate all visible Ways
            self.populateAllMapVisibleWays()
            
            self.drawAllVisibleWays()
            
            //// self.drawWayOnMap(WayId: Singleton.sharedInstance.wayID)
            // self.callGetWayDataApi(WayId: Singleton.sharedInstance.wayID)
            Singleton.sharedInstance.wayID = ""
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if Singleton.sharedInstance.wayID.isEmpty {
            waLocationManager.stopLocationMonitor()
        }
    }
    
    // func drawWayOnMap(WayId wayId: String){
    // // Get the encoded polyline string associated with this way
    // let wayPolylinesAsString = self.getEncodedPolylineStringForWay(WayId: wayId)
    //
    // //-->
    // let polylinesStringArray = wayPolylinesAsString.componentsSeparatedByString(",")
    // var polylinesArray = [GMSPolyline]()
    // var bounds = GMSCoordinateBounds()
    // for aPolyline in polylinesStringArray{
    // let path = GMSMutablePath(fromEncodedPath: aPolyline)
    // let polyLine = GMSPolyline(path: path)
    // polyLine.strokeWidth = 5
    // polyLine.strokeColor = UIColor.redColor()
    // polylinesArray.append(polyLine)
    // for index in 1...path!.count() {
    // bounds = bounds.includingCoordinate(path!.coordinateAtIndex(index))
    // }
    // }
    //
    // for aPolyline in polylinesArray{
    // aPolyline.map = mapView
    // }
    // mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
    // //--<
    //
    // //let wayPath = GMSPath(fromEncodedPath: wayPolylinesAsString)
    // //let polyline = GMSPolyline(path: wayPath)
    // //polyline.map = self.mapView
    // }
    
    // TODO: - getColorForWay
    func getColorForWay(WayId wayId: String) -> UIColor {
        return UIColor.redColor()
    }
    
    func drawAllVisibleWays() {
        // Loop through all visible ways
        for aWay in self.allVisibleWays {
            // Loop through all polylines for the way
            for aPolyline in aWay.routePolylines {
                // Prepare polyline to draw on map
                // aPolyline.strokeWidth = Constants.Generic.polylineStrokeWidth
                // aPolyline.strokeColor = aWay.color
                aPolyline.map = mapView
            }
            
            // By default, Zoom map to current users way
            if (aWay.isOwnedByCurrentUser) {
                mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(aWay.routeBounds))
            }
        }
    }
    
    func resetVisibleMapWays() {
        for aWay in self.allVisibleWays {
            for aPolyline in (aWay.routePolylines) {
                aPolyline.map = nil
            }
        }
        self.allVisibleWays = [WayOnMap]()
    }
    
    func populateAllMapVisibleWays() {
        self.resetVisibleMapWays()
        // First get the current users ways, if exists
        // Get the encoded polyline string associated with this way
        if (!Singleton.sharedInstance.wayID.isEmpty) {
            let wayId = Singleton.sharedInstance.wayID
            let wayPolylinesAsString = self.getEncodedPolylineStringForWay(WayId: wayId)
            let polylinesStringArray = wayPolylinesAsString.componentsSeparatedByString(",")
            var polylinesArray = [GMSPolyline]()
            var bounds = GMSCoordinateBounds()
            for aPolyline in polylinesStringArray {
                let path = GMSMutablePath(fromEncodedPath: aPolyline)
                let polyLine = GMSPolyline(path: path)
                polyLine.strokeWidth = Constants.Generic.polylineStrokeWidth
                polyLine.strokeColor = self.getColorForWay(WayId: wayId)
                polylinesArray.append(polyLine)
                for index in 1...path!.count() {
                    bounds = bounds.includingCoordinate(path!.coordinateAtIndex(index))
                }
            }
            
            let aWay = WayOnMap(WayId: wayId, Color: self.getColorForWay(WayId: wayId), IsOwnedByCurrentUser: true, RoutePolylines: polylinesArray, RouteBounds: bounds)
            self.allVisibleWays.append(aWay)
        }
        
        // Get all the friends ways
    }
    
    // func callGetWayDataApi(WayId wayId: String){
    // // Show busy icon
    // self.view.startBusySpinner()
    // // Now perform Accept action on this user
    // DataController.sharedInstance.callGetWayDataAPI(WayID: wayId, success: {serverResponse in
    // // Hide busy icon
    // self.view.stopBusySpinner()
    //
    // // Now display the saved location on map
    // //self.drawWayOnMap(WayId: wayId)
    //
    // })
    // { (error) in
    // // Hide busy icon
    // self.view.stopBusySpinner()
    // print("error : \(error)")
    // Utils.showAlertOK(Title: "Error",Message: "\(error)")
    // }
    // }
    
    func getEncodedPolylineStringForWay(WayId wayId: String) -> String {
        var polylineString = ""
        
        let waysAPI = WaysAPI(ApplicationDelegate: self.appDelegate)
        polylineString = waysAPI.getPolylineAsString(WayId: wayId)
        
        return polylineString
    }
    
    override func viewDidAppear(animated: Bool) {
        print("Zoomed location id: \(self.zoomedLocationId)")
        if (!self.zoomedLocationId.isEmpty) {
            self.zoomToLocation(LocationId: self.zoomedLocationId)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createDynamicMenuSubView() {
        dynamicMenuView.frame = CGRectMake(0, 50, 50, 250)
        dynamicMenuView.backgroundColor = UIColor(white: 1, alpha: 0.7)
        
        let saveButton = UIButton()
        saveButton.titleLabel!.font = UIFont(name: "Arial-MT", size: 8)
        saveButton.setTitle("Save", forState: .Normal)
        saveButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        mapView.userInteractionEnabled = true
        saveButton.frame = CGRectMake(0, 0, 100, 40)
        saveButton.setImage(UIImage(named: "SaveLocation_29x29"), forState: UIControlState.Normal)
        saveButton.addTarget(self, action: #selector(self.saveButtonAction(_:)), forControlEvents: .TouchUpInside)
        saveButton.titleEdgeInsets = UIEdgeInsetsMake(45, -70, 0, 0);
        dynamicMenuView.addSubview(saveButton)
        
        let shareButton = UIButton()
        saveButton.titleLabel!.font = UIFont(name: "Arial-MT", size: 8)
        shareButton.setTitle("Share", forState: .Normal)
        shareButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        mapView.userInteractionEnabled = true
        shareButton.frame = CGRectMake(0, dynamicMenuView.frame.minY + 40, 100, 40)
        shareButton.setImage(UIImage(named: "ShareLocation_29x29"), forState: UIControlState.Normal)
        shareButton.addTarget(self, action: #selector(self.shareButtonAction(_:)), forControlEvents: .TouchUpInside)
        shareButton.titleEdgeInsets = UIEdgeInsetsMake(45, -70, 0, 0);
        // shareButton.titleLabel!.font = UIFont(name: "Arial-MT", size: 8)
        dynamicMenuView.addSubview(shareButton)
        
        let createWayButton = UIButton()
        saveButton.titleLabel!.font = UIFont(name: "Arial-MT", size: 8)
        createWayButton.setTitle("Create Way", forState: .Normal)
        createWayButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        mapView.userInteractionEnabled = true
        createWayButton.frame = CGRectMake(0, dynamicMenuView.frame.minY + 140, 100, 40)
        createWayButton.setImage(UIImage(named: "CreateWay_29x29"), forState: UIControlState.Normal)
        createWayButton.addTarget(self, action: #selector(self.createWayButtonAction(_:)), forControlEvents: .TouchUpInside)
        createWayButton.titleEdgeInsets = UIEdgeInsetsMake(45, -70, 0, 0);
        // createWayButton.titleLabel!.font = UIFont(name: "Arial-MT", size: 8)
        dynamicMenuView.addSubview(createWayButton)
        
        self.mapView.addSubview(dynamicMenuView)
    }
    
    func saveButtonAction(sender: UIButton) {
        //
        if (self.mapSelectionAvailable) {
            self.requestLocationNameFromUser()
        } else {
            Utils.showAlertOK(Title: "No Map Selection", Message: "Select a location on the map to be saved.")
        }
    }
    
    func shareButtonAction(sender: UIButton) {
        Utils.showAlertOK(Title: "Share Clicked", Message: "Location Shared")
        self.endWay()
    }
    
    func createWayButtonAction(sender: UIButton) {
        // Utils.showAlertOK(Title: "Create Way Clicked", Message: "Way Created")
        self.startWay()
    }
    
    // Location Name user input container
    func requestLocationNameFromUser() {
        let alertController = UIAlertController(title: StringConstants.ForLocations.locationNameToSavePleaseTitle, message: StringConstants.ForLocations.locationNameToSavePleaseMsg, preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                let locationName = field.text!
                let locationLat = String(self.selectedMapPoint.position.latitude)
                let locationLong = String(self.selectedMapPoint.position.longitude)
                let locationAddress = self.selectedMapPointAddress
                
                self.addNewLocation(LocationName: locationName, LocationLatitude: locationLat, LocationLongitude: locationLong, LocationAddress: locationAddress)
                // Utils.showAlertOK(Title: "Save Clicked", Message: "Name: \(locationName); Location (\(locationLat),\(locationLong))")
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Location Name"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func addNewLocation(LocationName locationName: String, LocationLatitude locationLatitude: String, LocationLongitude locationLongitude: String, LocationAddress locationAddress: String) {
        // Show busy icon
        self.view.startBusySpinner()
        // Now perform Accept action on this user
        DataController.sharedInstance.callAddLocationAPI(LocationName: locationName, LocationLatitude: locationLatitude, LocationLongitude: locationLongitude, LocationAddress: locationAddress, success: { serverResponse in
            // Hide busy icon
            self.view.stopBusySpinner()
            
            // Now display the saved location on map
            self.selectedMapPoint.map = nil
            let marker = self.drawMarkerOnMap(LocationName: locationName, LocationLatitude: locationLatitude, LocationLongitude: locationLongitude, LocationAddress: locationAddress, LocationIcon: Constants.Generic.savedLocationMarkerIconName)
            self.mapView.selectedMarker = marker
            
            })
        { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        }
    }
    
    func startWay() {
        // Show busy icon
        self.view.startBusySpinner()
        // Now perform Start Way action on this user
        let activeWay = self.getUserActiveWay()
        Utils.setNSDString(AsKey: "ActiveWayId", WithValue: (activeWay?.wayId)!)
        globalLocationManager = self.waLocationManager
        
        if (activeWay == nil) {
            EZAlertController.alert("No active way available that can be started")
            // Hide busy icon
            self.view.stopBusySpinner()
            return
        }
        let currentLocation = self.waLocationManager.getLastKnownLocation()
        let currentLatLong = "\(currentLocation?.coordinate.latitude),\(currentLocation?.coordinate.longitude)"
        let batteryLevel = Utils.getDeviceBatteryLevel()
        let accuracy = Utils.getLocationAccuracyAsString(Location: currentLocation!)
        
        DataController.sharedInstance.callStartWayAPI(WayId: (activeWay?.wayId)!, CurrentLocation: currentLatLong, BatteryLevel: batteryLevel, Accuracy: accuracy, success: { serverResponse in
            
            //-->
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            
            dispatch_async(backgroundQueue, {
                print("This is run on the background queue")
                // Now start updating psition to server
                self.waLocationManager.startUpdatingLocation(WayID: (activeWay?.wayId)!, WayJustStarted: true)
                //self.waLocationManager.locationManager.startUpdatingLocation()
                
                //dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //    print("This is run on the main queue, after the previous code in outer block")
                //})
            })
            //--<
            
            // Now start updating psition to server
            ////self.waLocationManager.startUpdatingLocation(WayID: (activeWay?.wayId)!)
            
            // Hide busy icon
            self.view.stopBusySpinner()
            })
        { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        }
    }
    
    func endWay() {
        // Show busy icon
        self.view.startBusySpinner()
        // Now perform Start Way action on this user
        let activeWay = self.getUserActiveWay()
        if (activeWay == nil) {
            EZAlertController.alert("No active way available that can be ended")
            // Hide busy icon
            self.view.stopBusySpinner()
            return
        }
        
        DataController.sharedInstance.callEndWayAPI(WayId: (activeWay?.wayId)!, success: { serverResponse in
            
            // Now start updating psition to server
            self.waLocationManager.stopUpdatingLocation(true)
            //self.waLocationManager.isBGLocationUpdatesRunning = false
            
            // Hide busy icon
            self.view.stopBusySpinner()
            })
        { (error) in
            // Hide busy icon
            self.view.stopBusySpinner()
            print("error : \(error)")
            Utils.showAlertOK(Title: "Error", Message: "\(error)")
        }
    }
    
    func getUserActiveWay() -> WayOnMap? {
        for aWay in self.allVisibleWays {
            if (aWay.isOwnedByCurrentUser) {
                return aWay
            }
        }
        return nil
    }
    
    func drawMarkerOnMap(LocationName locationName: String, LocationLatitude locationLatitude: String, LocationLongitude locationLongitude: String, LocationAddress locationAddress: String, LocationIcon locationIcon: String) -> GMSMarker {
        let marker = GMSMarker()
        marker.snippet = locationAddress
        marker.title = locationName
        marker.position = CLLocationCoordinate2DMake(Double(locationLatitude)!, Double(locationLongitude)!)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = UIImage(named: locationIcon)
        marker.map = self.mapView
        
        return marker
    }
    
    func drawAllSavedLocationMarkers() {
        // Get all saved locations from local db
        let locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
        let savedLocationsArray = locationsAPI.getLocationsWithAcceptStatus(AcceptStatus: "1")
        
        // Reset saved markers collection
        self.allSavedMarkers = [:]
        
        // Display each of the saved location on the map
        for aLocation in savedLocationsArray {
            let aMarker = self.drawMarkerOnMap(LocationName: aLocation.name!, LocationLatitude: aLocation.latitude!, LocationLongitude: aLocation.longitude!, LocationAddress: aLocation.address!, LocationIcon: Constants.Generic.savedLocationMarkerIconName)
            // Add this marker to the list markers collection
            self.allSavedMarkers[aLocation.id!] = aMarker
        }
    }
    
    func getLocationAddress(latitude: Double, longitude: Double, completion: (answer: String?) -> Void) {
        let coordinates = CLLocation(latitude: latitude, longitude: longitude)
        
        if (!Utils.isConnectedToNetwork()) {
            completion(answer: "No Internet")
            return
        }
        
        CLGeocoder().reverseGeocodeLocation(coordinates, completionHandler: { (placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with an error" + error!.localizedDescription)
                completion(answer: "")
            } else if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                completion(answer: self.displayLocationInfo(pm))
            } else {
                print("Problems with the data received from geocoder.")
                completion(answer: "")
            }
        })
        
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) -> String
    {
        // var returnVal = "No Internet"
        if (!Utils.isConnectedToNetwork()) {
            return "No Internet"
        }
        
        if let containsPlacemark = placemark
        {
            var returnVal = ""
            // let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            // let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            // let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            // let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            
            let formattedAddresssArray = containsPlacemark.addressDictionary!["FormattedAddressLines"] as! [String]
            
            for anElement in formattedAddresssArray {
                if (returnVal.isEmpty) {
                    returnVal = anElement
                } else {
                    returnVal = returnVal + ", " + anElement
                }
                
            }
            // print(locality)
            // print(postalCode)
            // print(administrativeArea)
            // print(country)
            
            return returnVal
            
        } else {
            
            return ""
            
        }
        
    }
    
    // Map Events Handler
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        selectedMapPoint.map = nil
        
        // let marker = self.drawMarkerOnMap(LocationName: "Current Selection", LocationLatitude: String(coordinate.latitude), LocationLongitude: String(coordinate.longitude), LocationAddress: "Selected Location", LocationIcon: "selected_location_29x29")
        
        let address = ""
        // getLocationAddress(marker, completion: { (answer) -> Void in print(address) })
        getLocationAddress(coordinate.latitude, longitude: coordinate.longitude, completion: { (answer) -> Void in
            
            let marker = self.drawMarkerOnMap(LocationName: "Current Selection", LocationLatitude: String(coordinate.latitude), LocationLongitude: String(coordinate.longitude), LocationAddress: answer!, LocationIcon: "selected_location_29x29")
            self.selectedMapPoint = marker
            self.mapSelectionAvailable = true
            self.dynamicMenuView.hidden = false
            self.selectedMapPointAddress = answer!
            
            mapView.selectedMarker = marker
            
        })
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if (self.selectedMapPoint != marker) {
            self.selectedMapPoint.map = nil
            self.mapView.selectedMarker = marker
        }
        return true
    }
    
    // MARK: - CLLocationManagerDelegate
    
    //    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    //        if status == .AuthorizedWhenInUse {
    //            manager.startUpdatingLocation()
    //            
    //            mapView.myLocationEnabled = true
    //            mapView.settings.myLocationButton = true
    //        }
    //        
    //        if (status == CLAuthorizationStatus.AuthorizedWhenInUse) {
    //            manager.startUpdatingLocation()
    //        }
    //    }
    //    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        if let location = locations.first {
    //            
    //            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    //            // manager.stopUpdatingLocation()
    //            
    //            if UIApplication.sharedApplication().applicationState == .Active {
    //                // mapView.showAnnotations(locations, animated: true)
    //                //
    //                // let alert = AlertBox.sharedInstance
    //                // //alert.showAlert(title: "Error", message: "Error Message", parentViewController: self)
    //                //
    //                // alert.show(title: "TestTitle", message: "TestMessage", okAction: {
    //                // print("test OK Success")
    //                // }, cancelAction: {
    //                // print("test Cancel Success")
    //                // }, parentViewController: self)
    //                
    //            } else if (UIApplication.sharedApplication().backgroundRefreshStatus == UIBackgroundRefreshStatus.Restricted) // if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    //            {
    //                let alert = UIAlertController(title: "Error", message: "The functions of this app are limited because the Background app Refresh is disable.", preferredStyle: UIAlertControllerStyle.Alert)
    //                
    //                // add an action (button)
    //                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
    //                
    //                // show the alert
    //                self.presentViewController(alert, animated: true, completion: nil)
    //                
    //            } else {
    //                NSLog("App is backgrounded. New location is %@", location)
    //                // Background service is enabled, you can start the background supported location updates process
    //            }
    //        }
    //    }
    
    func zoomToLocation(LocationId locationId: String) {
        
        if (!self.zoomedLocationId.isEmpty) {
            // Get the location object with the given ID
            let locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
            let locationToZoom = locationsAPI.getLocationByID(LocationID: locationId)
            
            self.mapView.animateToLocation(CLLocationCoordinate2D(latitude: Double(locationToZoom.latitude!)!, longitude: Double(locationToZoom.longitude!)!))
            self.mapView.animateToZoom(Float(Constants.Generic.defaultZoomLevel)!)
            
            // Make this the seleted marker on the map (display marker info window)
            self.mapView.selectedMarker = self.allSavedMarkers[locationId]
            // self.selectedMapPoint = self.allSavedMarkers[locationId]!
            // self.mapSelectionAvailable = true
            self.dynamicMenuView.hidden = false
            
        }
        //        else {
        //            self.locationManager.startUpdatingLocation()
        //        }
        
        // Zoom to the latlong of the location
        // let camera = GMSCameraPosition.cameraWithLatitude(Double(locationToZoom.latitude!)!,
        // longitude: Double(locationToZoom.longitude!)!, zoom: Float(Constants.Generic.defaultZoomLevel)!)
        // let mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
    }
    
    func createActiveWaysView() {
        var wayStatusChangeBtn = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        wayStatusChangeBtn.backgroundColor = .greenColor()
        wayStatusChangeBtn.setTitle("Start Way", forState: .Normal)
        wayStatusChangeBtn.addTarget(self, action: #selector(wayStatusChangeAction), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(wayStatusChangeBtn)
    }
    
    func wayStatusChangeAction(sender: UIButton!) {
        print("Start Way Tapped...")
    }
    
    // // You don't need to modify the default init(nibName:bundle:) method.
    //
    // override func loadView() {
    // // Create a GMSCameraPosition that tells the map to display the
    // // coordinate -33.86,151.20 at zoom level 6.
    // let camera = GMSCameraPosition.cameraWithLatitude(-33.86, longitude: 151.20, zoom: 6.0)
    // let mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
    // mapView.myLocationEnabled = true
    // view = mapView
    //
    // // Creates a marker in the center of the map.
    // let marker = GMSMarker()
    // marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
    // marker.title = "Sydney"
    // marker.snippet = "Australia"
    // marker.map = mapView
    // }
    
    // MARK: - WayLocationUpdatedDelegate functions
    func wayCurrentLocationUpdated(WayId wayId: String, LatestLocationLatLong latestLocationLatLong: String) {
        // TODO: Draw the location on map
        let marker = GMSMarker()
        let latLong = latestLocationLatLong.componentsSeparatedByString(",")
        
        marker.position = CLLocationCoordinate2DMake(Double(latLong.first!)!, Double(latLong.last!)!)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = UIImage(named: "black_dot")
        marker.map = self.mapView
        
        //-->
        //        let latLong = latestLocationLatLong.componentsSeparatedByString(",")
        //        let circleCenter : CLLocationCoordinate2D  = CLLocationCoordinate2DMake(Double(latLong.first!)!, Double(latLong.last!)!)
        //        let circ = GMSCircle(position: circleCenter, radius: 0.001 * 1609.34)
        //        circ.fillColor = UIColor(red: 0.0, green: 0.7, blue: 0, alpha: 0.1)
        //        circ.strokeColor = UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.5)
        //        circ.strokeWidth = 2.5
        //        circ.map = self.mapView
        //--<
        
        //return marker
    }
}

