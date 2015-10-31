//
//  SettingTableViewController.swift
//  waterful
//
//  Created by suz on 10/27/15.
//  Copyright © 2015 suz. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import HealthKit

class SettingTableViewController: UITableViewController{

    @IBOutlet weak var fromUIView: UIView!
    @IBOutlet weak var fromText: UILabel!
    @IBOutlet weak var toText: UILabel!
    @IBOutlet weak var intervalText: UILabel!
    @IBOutlet weak var goalText: UILabel!
    @IBOutlet weak var unitText: UILabel!

    override func viewWillAppear(animated: Bool) {
    }
    override func viewDidLoad() {
        let setting_info : Setting = fetchSetting()
        fromText.text = setting_info.alarmStartTime?.description
        toText.text = setting_info.alarmEndTime?.description
        intervalText.text = setting_info.alarmInterval?.description
        goalText.text = setting_info.goal?.description
        unitText.text = setting_info.unit?.description
        
        self.requestHealthKitAuthorization()
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchSetting() -> Setting! {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        
        let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [Setting]
        
        if (fetchResults!.count == 0){
            return nil
        }
            
        else{
            return fetchResults![0]
        }
    }
}

extension SettingTableViewController {
    
    func requestHealthKitAuthorization() {
        let dataTypesToRead = Set(arrayLiteral: HealthManager.sharedInstance.weightType!)
        HealthManager.sharedInstance.healthKitStore.requestAuthorizationToShareTypes(nil,
            readTypes: dataTypesToRead) {
                (success, error) -> Void in

                if success {
                    print("requestHealthKitAuthorization() succeeded.")
                    self.setRecommendedWater()
                } else {
                    print("requestHealthKitAuthorization() failed.")
                }
        }
    }

    func setRecommendedWater() {

        print("set Recommended water")
        var weight: Double = 0
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        // Sample Query to get the latest weight (body mass)
        let weightSampleQuery = HKSampleQuery(sampleType: HealthManager.sharedInstance.weightType!,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]) {
                (query, results, error) -> Void in

                if let queryError = error {
                    print("weight query error: \(queryError.localizedDescription)")
                    return
                }

                if let queryResults = results {
                    let latestSample = queryResults[0] as! HKQuantitySample
                    weight = latestSample.quantity.doubleValueForUnit(HKUnit(fromString:"kg"))
                    print("weight: \(weight)")

                    let waterGoal = weight * 33
                    print("waterGoal: \(waterGoal)")

                    self.updateCoreDataGoal(waterGoal)
                    self.goalText.text = String(format: "%.1f", waterGoal)
                } else {
                    print("There are no query results.")
                    return
                }
        }
        // Execute the sample query to get the weight
        HealthManager.sharedInstance.healthKitStore.executeQuery(weightSampleQuery)
    }
    
    func updateCoreDataGoal(newGoal: Double) {

        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [Setting]

        if fetchResults != nil {
            if fetchResults!.count != 0 {
                fetchResults![0].goal = newGoal
            } else {
                print("updateCoreDataGoal -- There's no fetch results from Setting.")
            }
        }
    }
}
