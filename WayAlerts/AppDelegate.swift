//
//  AppDelegate.swift
//  WayAlerts
//
//  Created by Hari Kishore on 6/6/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
import MAThemeKit
import DropDown

import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Register fr push notifications
        registerForPushNotifications(application)
        
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey(Constants.Generic.googleMapsApiKey)
        
        // Handle Pushnotifications
        // Check if launched from notification
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject] {
            let aps = notification["aps"] as! [String: AnyObject]
            PushNotificationsProcessor.makeSenseOutOfPN(PushMessage: aps)
            //createNewNewsItem(aps)
            //(window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        }
        
        // Dropdown
        DropDown.startListeningToKeyboard()
        
        // Set App color theme
        // self.setAppColorTheme()
        
        // Save NSD keys for CoreData
        //NSUserDefaults.standardUserDefaults().setObject(self, forKey: Constants.NSDKeys.appDelegage)
        //NSUserDefaults.standardUserDefaults().setObject(self.managedObjectContext, forKey: Constants.NSDKeys.moc)
        
        // Set theme
        //let theme = ThemeManager.currentTheme()
        //ThemeManager.applyTheme(theme)
        
        MAThemeKit.setupThemeWithPrimaryColor(UIColor.init(red: 0, green: 184/256, blue: 156/256, alpha: 1), secondaryColor: UIColor.whiteColor(), fontName: "HelveticaNeue-Light", lightStatusBar: true)
        
        // Crashlytics initializer
        Crashlytics().debugMode = true
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    func sharedInstance() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    //    lazy var datastoreCoordinator: DatastoreCoordinator = {
    //        return DatastoreCoordinator()
    //    }()
    //    
    //    lazy var contextManager: ContextManager = {
    //        return ContextManager()
    //    }()
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        //let activeWayId = Utils.getNSDString(WithKey: "ActiveWayId")
        //let bgLocationmanager = BackgroundLocationManager()
        //bgLocationmanager.start(ActiveWayId: activeWayId)
        //Singleton.sharedInstance.waLocationManager.startLocationMonitor()
        print()
        print("Entering Inactive Mode...")
        print("****************************")
        globalLocationManager.startLocationMonitor()
        //Singleton.sharedInstance.AppIsInBackgroundMode = true
        Utils.setNSDBool(AsKey: "AppIsBackground", WithValue: true)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //Singleton.sharedInstance.AppIsInBackgroundMode = true
        Utils.setNSDBool(AsKey: "AppIsBackground", WithValue: true)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        Utils.setNSDBool(AsKey: "AppIsBackground", WithValue: false)
        //Singleton.sharedInstance.AppIsInBackgroundMode = false
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Utils.setNSDBool(AsKey: "AppIsBackground", WithValue: false)
        //Singleton.sharedInstance.AppIsInBackgroundMode = false
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    var shouldSupportAllOrientation = false
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if (shouldSupportAllOrientation == true){
            return UIInterfaceOrientationMask.All
        }
        
        return UIInterfaceOrientationMask.Portrait
    }
    
    // MARK: Methods supporting Push notifications protocol
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        Utils.setDeviceToken(DeviceToken: tokenString)
        //Utils.setNSDString(AsKey: Constants.NSDKeys.thisDeviceToken, WithValue: tokenString)
        print("Device Token:", tokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let aps = userInfo["aps"] as! [String: AnyObject]
        PushNotificationsProcessor.makeSenseOutOfPN(PushMessage: aps)
    }
    //-->
    
    // MARK: App Theme customizations
    func UIColorFromRGB(colorCode: String, alpha: Float = 1.0) -> UIColor{
        var scanner = NSScanner(string:colorCode)
        var color:UInt32 = 0;
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
    func setAppColorTheme(){
        //UINavigationBar.appearance().barTintColor = UIColor(red: 46.0/255.0, green: 14.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = UIColorFromRGB("#00DCF8")
        UIBarButtonItem.appearance().tintColor = UIColorFromRGB("#00DCF8")
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColorFromRGB("#00DCF8")]
        UITabBar.appearance().backgroundColor = UIColorFromRGB("#00DCF8");
        
        //        //Also if you want to add an image instead of just text, that works as well
        //
        //        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        //        imageView.contentMode = .ScaleAspectFit
        //
        //        var image = UIImage(named: "logo")
        //        imageView.image = image
        //        navigationItem.titleView = imageView
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.smt.CoreDataDemo" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("WayAlertsCoreModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("WayAlertsCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    //--<
}

