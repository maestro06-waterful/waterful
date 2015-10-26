//
//  Plant+CoreDataProperties.swift
//  waterful
//
//  Created by 차정민 on 2015. 10. 25..
//  Copyright © 2015년 suz. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Plant {

    @NSManaged var bornDate: NSDate?
    @NSManaged var growthRate: NSNumber?
    @NSManaged var name: String?
    @NSManaged var plantId: NSNumber?
    @NSManaged var type: String?
}
