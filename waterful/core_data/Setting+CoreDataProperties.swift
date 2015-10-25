//
//  Setting+CoreDataProperties.swift
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

extension Setting {

    @NSManaged var alarmEndTime: NSNumber?
    @NSManaged var alarmInterval: NSNumber?
    @NSManaged var alarmStartTime: NSNumber?
    @NSManaged var goal: NSNumber?
    @NSManaged var todayAmount: NSNumber?
    @NSManaged var unit: NSNumber?

}
