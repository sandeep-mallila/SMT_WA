//
//  Friends+CoreDataProperties.swift
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

extension Friends {

    @NSManaged var acceptStatus: String?
    @NSManaged var allowAlertsIn: String?
    @NSManaged var allowAlertsOut: String?
    @NSManaged var fullName: String?
    @NSManaged var isRequestInitiator: String?
    @NSManaged var mobileNumber: String?
    @NSManaged var profileImage: NSData?
    @NSManaged var userID: String?
    @NSManaged var user: User?

}
