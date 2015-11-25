//
//  WaterLogManager.swift
//  waterful
//
//  Created by 차정민 on 2015. 11. 15..
//  Copyright © 2015년 suz. All rights reserved.
//

import Foundation
import UIKit
import HealthKit
import CoreData

class WaterLogManager {
    // managed object context to control core data framework
    static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // Returns the total amount of water consumed in today.
    class func getTodayConsumption() -> Double {
        
        let fetchRequest = NSFetchRequest(entityName: "WaterLog")
        
        var fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [WaterLog]
        fetchResults = fetchResults?.reverse()
        
        var consumed : Double = 0
        
        let today = getDate(NSDate())
        
        for result in fetchResults! {
            if (getDate(result.loggedTime!) == today){
                consumed = consumed + Double(result.amount!)
            }
        }
        return consumed
    }
    
    // store amount of water user consumed
    class func saveWaterLog(container : String, loggedTime : NSDate = NSDate() ){
        let amount = getVolume(container)
        
        // insert new object into core data framework.
        let waterLog = NSEntityDescription.insertNewObjectForEntityForName("WaterLog",
            inManagedObjectContext: managedObjectContext) as! WaterLog

        // When the log is saved, 'amount' in current unit is converted to mili-litter unit.
        waterLog.amount = amount
        waterLog.loggedTime = loggedTime
        waterLog.container = container
        
        do {
            // save the managet object context
            try managedObjectContext.save()
            
            // save HK Sample object for logging drinking water.
            HealthManager.sharedInstance.requesSavingHKWaterSample(amount, logDate: loggedTime)
            
        } catch {
            print("Unresolved error")
            abort()
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).setShortcutItems()
    }

    // return size(ml) of container.
    class func getVolume(container : String) -> Double {
        let currentSetting = Setting.getSetting()
        
        if container == "sip" {
            return (currentSetting!.sipVolume?.doubleValue)!
        }
        else if container == "cup" {
            return (currentSetting!.cupVolume?.doubleValue)!
        }
            
        else if container == "mug" {
            return (currentSetting!.mugVolume?.doubleValue)!
        }
        else if container == "bottle" {
            return (currentSetting!.bottleVolume?.doubleValue)!
        }
        else {
            return 0
        }
    }
    
    // Returns the last WaterLog object in core data framework.
    class func getLastWaterLog() -> WaterLog! {
        
        let fetchRequest = NSFetchRequest(entityName: "WaterLog")
        
        let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [WaterLog]
        if (fetchResults?.count>0){
            return fetchResults![(fetchResults?.endIndex)!-1]
        }
        else {
            return nil
        }
    }
    
    // Returns core data objects, which is saved in today, in WaterLog entity.
    class func getTodayWaterLogs() -> [WaterLog]? {
        
        // today water logs to return.
        var todayWaterLogs = [WaterLog]()
        let today = getDate(NSDate())
        
        let fetchRequest = NSFetchRequest(entityName: "WaterLog")
        let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [WaterLog]
        
        if let results = fetchResults {
            for result in results {
                if getDate(result.loggedTime!) == today {
                    todayWaterLogs.append(result)
                }
            }
        } else {
            // There's no fetch results, return nil.
            return nil
        }
        
        return todayWaterLogs
    }
    
    // Delete the last water log
    class func undoLastWaterLog(){
        
        if let todayWaterLogs = getTodayWaterLogs() {
            
            let endIndex = todayWaterLogs.endIndex - 1
            if endIndex >= 0 {
                // Delete the last object in WaterLog entity.
                managedObjectContext.deleteObject(todayWaterLogs[endIndex])
                // Delete last saved HKSample object meaning drinking water.
                HealthManager.sharedInstance.requestDeletingLastHKWaterSample()
            }
            do {
                try managedObjectContext.save()
            } catch {
                // Do something in response to error condition
            }
        }
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).setShortcutItems()
    }
}

typealias DateProcessor = WaterLogManager
extension DateProcessor {
    class func getDate(date : NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
}