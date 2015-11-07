//
//  DrinkWaterViewController.swift
//  waterful
//
//  Created by suz on 10/9/15.
//  Copyright © 2015 suz. All rights reserved.
//

import UIKit
import CoreData
import HealthKit

class DrinkWaterViewController: UIViewController {

    @IBOutlet weak var waterInput: UITextField!

    var amount : Double = 0

    func log()
    {
        logWater(amount)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ADD", style: UIBarButtonItemStyle.Plain, target: self, action: "log")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func button1Pressed(sender: AnyObject) {
        amount = amount + 40
        waterInput.text = String(amount)
    }
    @IBAction func button2Pressed(sender: AnyObject) {
        amount = amount + 120
        waterInput.text = String(amount)
    }
    @IBAction func button3Pressed(sender: AnyObject) {
        amount = amount + 400
        waterInput.text = String(amount)
    }
    @IBAction func button4Pressed(sender: AnyObject) {
        amount = amount + 500
        waterInput.text = String(amount)
    }

    // save CoreData and HKSample object for logging drinking water.
    func logWater(amount : Double){

        let unitML: HKUnit = HKUnit(fromString: "mL")       // standard unit
        let curUnit: HKUnit = currentUnit()                 // current unit

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext

        let water_info = NSEntityDescription.insertNewObjectForEntityForName("WaterLog",
            inManagedObjectContext: managedContext) as! WaterLog
        water_info.unit = curUnit
        water_info.amount = HKQuantity(unit: curUnit, doubleValue: amount).doubleValueForUnit(unitML)
        water_info.loggedTime = NSDate(timeIntervalSinceNow: NSTimeInterval(NSTimeZone.defaultTimeZone().secondsFromGMT))

        do {
            // save the CoreData object
            try managedContext.save()
        } catch {
            print("Unresolved error")
            abort()
        }

        // save HKSample object
        self.requestAuthForSavingHKWaterObject()
    }

    // Returns 'unit' attribute from 'Settings' entity
    // If an exception occurs, it returns milli liter (global-standard unit)
    func currentUnit() -> HKUnit {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext

        let fetchRequest = NSFetchRequest(entityName: "Setting")
        let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [Setting]

        if fetchResults != nil {
            if fetchResults!.count != 0 {
                return fetchResults![0].valueForKey("unit") as! HKUnit
            } else {
                return HKUnit(fromString: "mL")
            }
        } else {
            return HKUnit(fromString: "mL")
        }
    }
}

extension DrinkWaterViewController {

    // Requests HK authorization for saving HKSample object for logging water
    func requestAuthForSavingHKWaterObject() {
        let dataTypesToRead = Set(arrayLiteral: HealthManager.sharedInstance.weightType!)
        HealthManager.sharedInstance.healthKitStore.requestAuthorizationToShareTypes(nil,
            readTypes: dataTypesToRead) {
                (success, error) -> Void in
                if success {
                    self.healthKitSaveWaterLog()
                } else {
                    print("requestHealthKitAuthorization() failed.")
                }
        }
    }

    // Saves a HKSample object representing drinking water
    func healthKitSaveWaterLog() {
        let curUnit: HKUnit = self.currentUnit()
        // Create a water sample (HKQuantitySample object)
        let waterType = HealthManager.sharedInstance.waterType
        let waterQuantity = HKQuantity(unit: curUnit, doubleValue: self.amount)
        let waterSample = HKQuantitySample(type: waterType!,
            quantity: waterQuantity,
            startDate: NSDate(),
            endDate: NSDate())

        // Save the water sample into the HKstore
        HealthManager.sharedInstance.healthKitStore.saveObject(waterSample) {
            (success, error) -> Void in
            if error != nil {
                print("Error saving water sample: \(error?.localizedDescription)")
            } else {
                print("water sample saved successfully.")
            }
        }
    }
}