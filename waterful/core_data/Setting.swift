//
//  Setting.swift
//  waterful
//
//  Created by 차정민 on 2015. 10. 25..
//  Copyright © 2015년 suz. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import HealthKit

class Setting: NSManagedObject {

    // Returns the initial setting.
    // This method should be called only when there's no setting object.
    class func initialSetting() -> Setting {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let initialSetting = NSEntityDescription.insertNewObjectForEntityForName("Setting",
            inManagedObjectContext: managedObjectContext) as! Setting
        
        
        initialSetting.goal = Double(1500)
        initialSetting.alarmEndTime = 23
        initialSetting.alarmStartTime = 9
        initialSetting.alarmInterval = 3
        initialSetting.unit = HKUnit(fromString: "mL")
        initialSetting.sipVolume = 40
        initialSetting.cupVolume = 120
        initialSetting.mugVolume = 350
        initialSetting.bottleVolume = 500
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Unresolved error")
            abort()
        }
        return initialSetting
    }
    
    // Returns the setting object
    class func getSetting() -> Setting? {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [Setting]
        
        if (fetchResults!.count == 0){
            return nil
        } else {
            return fetchResults![0]
        }
    }
    
    // Returns the unit attribute in Setting entity in core data framework.
    class func getUnit() -> HKUnit {
        
        let currentSetting = Setting.getSetting()
        
        if currentSetting != nil {
            return currentSetting!.valueForKey("unit") as! HKUnit
        }
        
        // If there's no setting entity,
        // return milli litter unit as the global-standard unit.
        return HKUnit(fromString: "mL")
    }
}
