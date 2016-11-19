//
//  Locations+CoreDataProperties.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 23/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Locations {

    @NSManaged var address: String?
    @NSManaged var id: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var name: String?
    @NSManaged var zoomLevel: String?
    @NSManaged var acceptStatus: String?

}
