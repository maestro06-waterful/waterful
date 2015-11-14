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

    @IBOutlet weak var sipLabel: UITextField!
    @IBOutlet weak var cupLabel: UITextField!
    @IBOutlet weak var mugLabel: UITextField!
    @IBOutlet weak var bottleLabel: UITextField!
    @IBOutlet weak var goalLabel: UITextField!
    @IBOutlet weak var unitText: UILabel!
    
    @IBAction func userdone(sender: AnyObject) {
        print("done")
        saveSetting()
    }
    
    var sipVolume : Double = Double()
    var cupVolume : Double = Double()
    var mugVolume : Double = Double()
    var bottleVolume : Double = Double()
    var setting_info : Setting!

    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        setting_info = fetchSetting()
        
        unitText.text = setting_info.unit?.description
        sipVolume = (setting_info.sipVolume?.doubleValue)!
        cupVolume = (setting_info.cupVolume?.doubleValue)!
        mugVolume = (setting_info.mugVolume?.doubleValue)!
        bottleVolume = (setting_info.bottleVolume?.doubleValue)!
        goalLabel.text = String(format:"%0.1f",(setting_info.goal?.doubleValue)!)
        sipLabel.text = String(format:"%0.1f",(setting_info.sipVolume?.doubleValue)!)
        cupLabel.text = String(format:"%0.1f",(setting_info.cupVolume?.doubleValue)!)
        mugLabel.text = String(format:"%0.1f",(setting_info.mugVolume?.doubleValue)!)
        bottleLabel.text = String(format:"%0.1f",(setting_info.bottleVolume?.doubleValue)!)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
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
    
    func saveSetting() {
        setting_info.sipVolume = Double(sipLabel.text!)
        setting_info.cupVolume = Double(cupLabel.text!)
        setting_info.mugVolume = Double(mugLabel.text!)
        setting_info.bottleVolume = Double(bottleLabel.text!)
        setting_info.goal = Double(goalLabel.text!)
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        do {
            // save the managet object context
            try managedObjectContext.save()
            
        } catch {
            print("Unresolved error")
            abort()
        }
        navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
                    self.goalLabel.text = String(format: "%.1f", waterGoal)
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
