//
//  WaterLog+CoreDataProperties.swift
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
import HealthKit

extension WaterLog {

    @NSManaged var amount: NSNumber?
    @NSManaged var loggedTime: NSDate?
    @NSManaged var container: String?

}
