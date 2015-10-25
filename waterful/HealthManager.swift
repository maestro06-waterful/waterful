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

class HealthManager {
   
    // Returns the Singleton instance
    class var sharedInstance: HealthManager {
        struct Singleton {
            static let instance: HealthManager = HealthManager()
        }
        return Singleton.instance
    }
    
    // healthkit store
    let healthKitStore: HKHealthStore = HKHealthStore()

    // sample types to use
    let stepCountType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
    let workoutType = HKWorkoutType.workoutType()
    
    // Sets sample types to use and requests healthkit authorization for that types
    func authorizeHealthKit(completion: ((success: Bool, error: NSError?) -> Void)!) {
        
        // Set the sample types to read
        let typesToRead = Set(arrayLiteral: stepCountType!, workoutType)
        
        // If the store is not available, return
        if HKHealthStore.isHealthDataAvailable() == false {
            if completion != nil {
                completion(success: false, error: nil)
            }
            return
        }
        // Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(nil,
            readTypes: typesToRead,
            completion: {(success: Bool, error: NSError?) -> Void in
                if success == true && error == nil {
                    print("Request Authorization succeeded.")
                } else {
                    print("Request Authorization failed.")
                }
                
                if completion != nil {
                    completion(success: success, error: nil)
                }
            }
        )
    }
}
