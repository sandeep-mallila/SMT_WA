//
//  User+CoreDataProperties.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 22/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var masterAlertsInToggle: String?
    @NSManaged var masterAlertsOutToggle: String?
    @NSManaged var mobileNumber: String?
    @NSManaged var profileImage: NSData?
    @NSManaged var userID: String?
    @NSManaged var friends: NSSet?

}
