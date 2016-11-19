//
//  User.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 18/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    //private let coreDataHelper: CoreDataHelper! = CoreDataHelper.sharedInstance
    
    enum Attributes : String {
        case
        firstName    = "firstName",
        lastName      = "lastName",
        mobileNumber       = "mobileNumber",
        userID      = "userID",
        profileImage       = "profileImage",
        masterAlertsInToggle    = "masterAlertsInToggle",
        masterAlertsOutToggle  = "masterAlertsOutToggle",
        friends      = "friends"
    }
    static let getAll = [
        Attributes.firstName,
        Attributes.lastName,
        Attributes.mobileNumber,
        Attributes.userID,
        Attributes.profileImage,
        Attributes.masterAlertsInToggle,
        Attributes.masterAlertsOutToggle,
        Attributes.friends
    ]
    
    //Utilize Singleton pattern by instanciating UserAPI only once.
    class var sharedInstance: User {
        struct Singleton {
            static let instance = User()
        }
        
        return Singleton.instance
    }
}
