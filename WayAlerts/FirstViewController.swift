//
//  FirstViewController.swift
//  WayAlerts
//
//  Created by Hari Kishore on 6/6/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import GoogleMaps

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
      @IBOutlet weak var mapView: GMSMapView!
    
    ////// Google map initialization
    
    lazy var locationManager : CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.delegate = self
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if (authorizationStatus == CLAuthorizationStatus.NotDetermined) {
            manager.requestWhenInUseAuthorization()
        } else if (authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
        
        return manager
    }()
    
    //////
    
    
    override func loadView() {
        super.loadView()
        
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
            
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
        
        if (status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            //manager.stopUpdatingLocation()
            
            if UIApplication.sharedApplication().applicationState == .Active {
                //mapView.showAnnotations(locations, animated: true)
//                
//                let alert = AlertBox.sharedInstance
//                //alert.showAlert(title: "Error", message: "Error Message", parentViewController: self)
//                
//                alert.show(title: "TestTitle", message: "TestMessage", okAction: { 
//                    print("test OK Success")
//                    }, cancelAction: { 
//                        print("test Cancel Success")
//                    }, parentViewController: self)
                
                
            }else if (UIApplication.sharedApplication().backgroundRefreshStatus == UIBackgroundRefreshStatus.Restricted) //if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
            {
                let alert = UIAlertController(title: "Error", message: "The functions of this app are limited because the Background app Refresh is disable.", preferredStyle: UIAlertControllerStyle.Alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                // show the alert
                self.presentViewController(alert, animated: true, completion: nil)

                
            } else {
                NSLog("App is backgrounded. New location is %@", location)
                // Background service is enabled, you can start the background supported location updates process
            }
        }
    }
    
    /*
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        // Add another annotation to the map.
        let  position = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
        let annotation = GMSMarker(position: position)//MKPointAnnotation()
        //annotation.coordinate = newLocation.coordinate
        annotation.title = "Test Marker"
        
        // Also add to our map so we can remove old values later
        locations.append(annotation)
        
        // Remove values if the array is too big
        while locations.count > 100 {
            let annotationToRemove = locations.first!
            locations.removeAtIndex(0)
            
            // Also remove from the map
            mapView.delete(annotationToRemove)
//            mapView.removeAnnotation(annotationToRemove)
        }
        
        if UIApplication.sharedApplication().applicationState == .Active {
            //mapView.showAnnotations(locations, animated: true)
            annotation.map = mapView
            
            mapView.settings.myLocationButton = true
        } else {
            NSLog("App is backgrounded. New location is %@", newLocation)
        }
    }*/
    
    
}

/*
extension FirstViewController : CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
            
            mapView.myLocationEnabled = true
            //mapView.settings.myLocationButton = true
            
            if UIApplication.sharedApplication().applicationState == .Active {
                mapView.settings.myLocationButton = true
            } else {
                print("App is backgrounded. New location is %@", manager.location)
            }

        }
        
        if (status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            manager.stopUpdatingLocation()
        }
    }
}
 */

