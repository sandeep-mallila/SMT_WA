//
//  Singleton.swift
//  WayAlerts
//
//  Created by Sandeep Mallila on 25/09/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation

class Singleton {
    var wayid : String = ""
    class var sharedInstance : Singleton {
        struct Static {
            static let instance : Singleton = Singleton()
        }
        return Static.instance
    }
    
    var wayID : String {
        get{
            return self.wayid
        }
        
        set {
            self.wayid = newValue
        }
    }
    //var WALocationManager waLocationManager { get; set; }
    //var waLocationManager = WALocationManager()
    
}