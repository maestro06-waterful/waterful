//
//  HealthManager.swift
//  waterful
//
//  Created by 차정민 on 2015. 10. 25..
//  Copyright © 2015년 suz. All rights reserved.
//

import UIKit
import Foundation
import HealthKit
import CoreData

class HealthManager {

    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // Returns the Singleton instance
    class var sharedInstance: HealthManager {
        struct Singleton {
            static let instance: HealthManager = HealthManager()
        }
        return Singleton.instance
    }
    
    // Sleep time
    let sleepTime: NSTimeInterval = 4 * 3_600;  // 4 hours
    
    // healthkit store
    let healthKitStore: HKHealthStore = HKHealthStore()

    // sample types to use
    let stepCountType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    let workoutType = HKWorkoutType.workoutType()
    let waterType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)
    
    // Sets sample types to use and requests healthkit authorization for that types
    func authorizeHealthKit(completion: ((success: Bool, error: NSError?) -> Void)!) {

        // Set the sample types to read
        let typesToShare = Set(arrayLiteral: waterType!)

        // Set the sample types to read
        let typesToRead = Set(arrayLiteral: stepCountType!, workoutType, waterType!)
        
        // If the store is not available, return
        if HKHealthStore.isHealthDataAvailable() == false {
            if completion != nil {
                completion(success: false, error: nil)
            }
            return
        }
        // Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(typesToShare,
            readTypes: typesToRead,
            completion: {(success: Bool, error: NSError?) -> Void in
                if success == true && error == nil {
                    print("Request Authorization succeeded.")
                    self.executeStepObserverQuery()
                    self.executeWorkoutObserverQuery()
                } else {
                    print("Request Authorization failed.")
                }
                
                if completion != nil {
                    completion(success: success, error: nil)
                }
            }
        )
    }
    
    func executeWorkoutObserverQuery() {
        
        // Set the observer query for observing workout
        let workoutObserverQuery: HKObserverQuery = HKObserverQuery(sampleType: HKWorkoutType.workoutType(), predicate: nil) {
            (query, completionHandler, error) -> Void in    // updateHandler
            print("updateHandler called. (workout)")
            
            // When updateHandler is called in the background mode
            if self.appDelegate.isBackground == true {
                print("background updateHandler is called. (workout)")
                self.appDelegate.registerNotification(NSDate().dateByAddingTimeInterval(60),
                    alertBody: "운동을 열심히 하셨군요! 운동을 하는 동안 물을 얼마나 마셨나요??")
            }
            completionHandler()
        }
        
        // Exectue the observer query which is observing workout sample
        self.healthKitStore.executeQuery(workoutObserverQuery)
        
        // Enable the background delivery for workout samples
        self.healthKitStore.enableBackgroundDeliveryForType(HKWorkoutType.workoutType(),
            frequency: .Hourly) {
                (success, error) -> Void in // completionHandler
                
                if success {
                    print("Enabling background delivery for workout succeeded.")
                } else {
                    print("Enabling background delivery for workout failed.")
                    if error != nil {
                        print("error: \(error?.localizedDescription)")
                    }
                }
        }
    }
    
    func executeStepObserverQuery () {
        
        // Set the observer query for observing step counts
        let stepObserverQuery: HKObserverQuery = HKObserverQuery(sampleType: stepCountType!, predicate: nil) {
            (query, completionHandler, error) -> Void in    // updateHandler
            print("updateHandler called. (step count)")
            
            // When updateHandler is called in the background mode
            if self.appDelegate.isBackground == true {
                print("background updateHandler called (step count)")
                
                // Save the current time to coreData framework.
                // The date logs will be used to catch wakeup time
                self.saveCurrentDate()
                self.catchWakeup()
                print("success!")
            }
            completionHandler()
        }
        
        // Execute the observer query which is observing step count samples
        self.healthKitStore.executeQuery(stepObserverQuery)
        
        // Enable the background delivery for step count samples
        self.healthKitStore.enableBackgroundDeliveryForType(stepCountType!,
            frequency: .Hourly) {
                (success, error) -> Void in // completionHandler
                
                if success {
                    print("Enabling background delivery for step count succeeded.")
                } else {
                    print("Enabling background delivery for step count failed.")
                    if error != nil {
                        print("error: \(error?.localizedDescription)")
                    }
                }
        }
    }
    
    // save current time (NSDate instance) to CoreData Framework
    func saveCurrentDate() {
        
        let entityDescription = NSEntityDescription.entityForName("StepDate",
            inManagedObjectContext: managedObjectContext)
        let stepDate = StepDate(entity: entityDescription!,
            insertIntoManagedObjectContext: managedObjectContext)
        stepDate.date = NSDate()    // NSDate instance representing now
        
        do {
            try managedObjectContext.save()
            print("core data save() succeeded.")
        } catch {
            print("core data save() error")
        }
    }
    
    // This method is called when the updateHandler of HKObserverQuery observing step counts
    // is called in the background modes.
    func catchWakeup() {
        
        // Get step date logs in one day
        let objects: [AnyObject]? = getStepDateLogsToday()
        
        if let results = objects {
            if results.count > 1 {
                var latestWakeupIndex: Int = 0
                
                // Calculate all time intervals and get max time interval
                for index in 0...(results.count-2) {
                    let date1 = (results[index+1] as! NSManagedObject).valueForKey("date")!
                    let date2 = (results[index] as! NSManagedObject).valueForKey("date")!
                    let timeInterval = date1.timeIntervalSinceDate(date2 as! NSDate)
                    
                    if timeInterval > sleepTime {
                        latestWakeupIndex = index + 1
                    }
                }
                
                // There's no time interval larger than sleep time
                if latestWakeupIndex == 0 {
                    print("There was not a sleep time")
                    return
                }
                
                // latest wakeup log is now
                if latestWakeupIndex == (results.count-1) {
                    print("Wake up...!")
                    appDelegate.registerNotification(NSDate().dateByAddingTimeInterval(60),
                        alertBody: "방금 일어나셨군요! 하루를 알차게 잘 보내시기 바랍니다.")
                } else {
                    print("It passed an hour after wake up")
                }
            }
        }
    }
    
    // Returns date logs in the latest 24 hours
    func getStepDateLogsToday() -> [AnyObject]? {
        
        // Set one day to 86,400 seconds
        let day: Double = 86_400
        
        // "StepDate" entity in core data model
        let entityDescription = NSEntityDescription.entityForName("StepDate", inManagedObjectContext: managedObjectContext)
        let request = NSFetchRequest()
        
        // predicate = from '-one day' to 'now'
        let pred = NSPredicate(format: "(date > %@)", NSDate().dateByAddingTimeInterval(-day))
        request.entity = entityDescription
        request.predicate = pred
        
        // Query results to return
        var results: [AnyObject]? = nil
        do {
            results = try managedObjectContext.executeFetchRequest(request)
        } catch {
            print("Fetch Request Error.")
            return nil
        }
        return results
    }
}
