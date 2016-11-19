//
//  Friends.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 18/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import CoreData


class Friends: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    enum Attributes : String {
        case
        acceptStatus    = "acceptStatus",
        allowAlertsIn      = "allowAlertsIn",
        allowAlertsOut       = "allowAlertsOut",
        fullName      = "fullName",
        isRequestInitiator       = "isRequestInitiator",
        mobileNumber    = "mobileNumber",
        profileImage  = "profileImage",
        userID      = "userID",
        user = "user"
    }
    
    //Utilize Singleton pattern by instanciating UserAPI only once.
    class var sharedInstance: Friends {
        struct Singleton {
            static let instance = Friends()
        }
        
        return Singleton.instance
    }
}
