//
//  ViewController.swift
//  waterful
//
//  Created by suz on 10/9/15.
//  Copyright © 2015 suz. All rights reserved.
//

import UIKit
import CoreData
import QuartzCore

import HealthKit

class ViewController: UIViewController {

    // managed object context to control core data framework
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    // Setting object from core data framework
    var setting_info : Setting! = nil

    @IBOutlet var mainView: UIView!

    @IBOutlet weak var consumed: UILabel!
    @IBOutlet weak var goal: UILabel!
    @IBOutlet weak var consumedUnit: UILabel!
    @IBOutlet weak var goalUnit: UILabel!
    
    @IBOutlet weak var waterImageView: UIImageView!
    
    @IBOutlet weak var unitLeft: UILabel!
    @IBOutlet weak var amountLeft: UILabel!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var shortcut: UIButton!
    
    @IBAction func shortcutPressed(sender: AnyObject) {
        if let lastWaterLog = getLastWaterLog() {
            saveWaterLog(Double(lastWaterLog.amount!))
        }
    }

    @IBAction func button1Pressed(sender: AnyObject) {
        saveWaterLog(40)
    }
    
    @IBAction func button2Pressed(sender: AnyObject) {
        saveWaterLog(120)
    }
    
    @IBAction func button3Pressed(sender: AnyObject) {
        saveWaterLog(400)
    }
    
    @IBAction func button4Pressed(sender: AnyObject) {
        saveWaterLog(500)
    }
    
    @IBAction func undoPressed(sender: AnyObject) {
        undoLastWaterLog()
    }

    override func viewWillAppear(animated: Bool) {
        // Setting up informatinos about water
        updateSetting()
        updateWater()
    }

    
    override func viewDidLoad() {
        // make gradient background
        let gl : CAGradientLayer = CAGradientLayer()
        gl.colors = [UIColor.whiteColor().CGColor, UIColor(white: 0.80, alpha: 1).CGColor]
        gl.locations = [0.5,1.0]
        gl.frame = mainView.bounds
        self.view.layer.insertSublayer(gl, atIndex: 0)
        
        // make water image view circular.
        waterImageView.layer.masksToBounds = false
        waterImageView.layer.cornerRadius = waterImageView.frame.height/2
        waterImageView.clipsToBounds = true
        let dottedPattern = UIImage(named: "dottedPattern")
        
        waterImageView.layer.borderWidth = 1
        waterImageView.layer.borderColor = UIColor(patternImage: dottedPattern!).CGColor
        
        // make shortcut button circular.
        shortcut.layer.cornerRadius = shortcut.imageView!.frame.height/2
        shortcut.clipsToBounds = true
        shortcut.contentMode = UIViewContentMode.Center

        let themeColor : UIColor = UIColor(patternImage: UIImage(named: "themeColor")!)
        let buttons : [UIButton] = [button1, button2, button3, button4]
        for button in buttons {
            button.layer.cornerRadius = button.frame.height/2
            button.backgroundColor = themeColor
        }

        setting_info = fetchSetting()
        // first time user.
        if (setting_info == nil){
            setting_info = setSetting()
            

            // !!!!!!!! SUBVIEW !!!!!!!!!!
            // press OK in subview -> !!!! END BLUR !!!!!
        }

        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDate(date : NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
    
    func fetchWater() -> Double {
        
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
    
    // set settings, if there is no.
    func setSetting() -> Setting {
        
        let setting_info = NSEntityDescription.insertNewObjectForEntityForName("Setting",
            inManagedObjectContext: managedObjectContext) as! Setting
        
        setting_info.goal = Double(1500)
        setting_info.alarmEndTime = 23
        setting_info.alarmStartTime = 9
        setting_info.alarmInterval = 3
        setting_info.unit = HKUnit(fromString: "mL")
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Unresolved error")
            abort()
        }
        
        return setting_info
    }

    // fetch settings from
    func fetchSetting() -> Setting! {
        
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [Setting]

        if (fetchResults!.count == 0){
            return nil
        } else {
            return fetchResults![0]
        }
    }
    
    // Returns the unit attribute in Setting entity in core data framework.
    func currentUnit() -> HKUnit {

        let unitML: HKUnit = HKUnit(fromString: "mL")

        if setting_info != nil {
            return setting_info.valueForKey("unit") as! HKUnit
        }
        
        // If there's no setting entity,
        // return milli litter unit as the global-standard unit.
        return unitML
    }

    // store amount of water user consumed
    func saveWaterLog(amount : Double){

        let unitML: HKUnit = HKUnit(fromString: "mL")
        let currentUnit: HKUnit = self.currentUnit()
        
        // insert new object into core data framework.
        let waterLog = NSEntityDescription.insertNewObjectForEntityForName("WaterLog",
            inManagedObjectContext: managedObjectContext) as! WaterLog

        waterLog.unit = currentUnit
        // When the log is saved, 'amount' in current unit is converted to mili-litter unit.
        waterLog.amount = HKQuantity(unit: currentUnit, doubleValue: amount).doubleValueForUnit(unitML)
        waterLog.loggedTime = NSDate()
        
        do {
            // save the managet object context
            try managedObjectContext.save()
            
            // save HK Sample object for logging drinking water.
            self.requesSavingHKWaterSample(amount)
        } catch {
            print("Unresolved error")
            abort()
        }
        // update view in repspons to change of core data objects in WaterLog entity.
        updateWater()
    }
    
    // update text regards of settings
    func updateSetting() {
        setting_info = fetchSetting()
        goal.text = setting_info.goal?.description
        goalUnit.text = setting_info.unit?.description
        consumedUnit.text = setting_info.unit?.description
    }

    // update text of consumed water
    func updateWater() {

        let consumedWater = fetchWater()
        consumed.text = String(format:"%.0f", consumedWater)
        
        let progressPercentage = consumedWater / Double(setting_info.goal!)
        let lastWaterLog : WaterLog! = self.getLastWaterLog()
        let waterLeft : Double = Double(setting_info.goal!) - Double(consumedWater)

        // show image of last unit.
        if lastWaterLog != nil {
            let lastUnitImage = UIImage(named: (String(format: "%.0f", lastWaterLog.amount!.doubleValue)) + String(setting_info.unit!))
            shortcut.setBackgroundImage(lastUnitImage, forState: .Normal)
            // show how much drinks you have to drink with the unit.
            
            if waterLeft > 0 {
                unitLeft.text = "* " + (String(format: "%.1f", waterLeft / lastWaterLog.amount!.doubleValue)) + " left."
                amountLeft.text = "(" + String(waterLeft) + String(setting_info.unit!) + ")"
            }
            else {
                unitLeft.text = nil
                amountLeft.text = nil
            }
        }
        else {
            shortcut.setBackgroundImage(nil, forState: .Normal)
            unitLeft.text = nil
            amountLeft.text = "(" + String(waterLeft) + String(setting_info.unit!) + ")"
        }
        
        // cover blue background with white image to show progress status
        waterImageView.image = drawImage(progressPercentage)
    }
    
    // Returns core data objects, which is saved in today, in WaterLog entity.
    func getTodayWaterLogs() -> [WaterLog]? {
        
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
    func undoLastWaterLog(){

        if let todayWaterLogs = getTodayWaterLogs() {
            
            let endIndex = todayWaterLogs.endIndex - 1
            if endIndex >= 0 {
                // Delete the last object in WaterLog entity.
                managedObjectContext.deleteObject(todayWaterLogs[endIndex])
                // Delete last saved HKSample object meaning drinking water.
                self.requestDeletingLastHKWaterSample()
            }
            do {
                try managedObjectContext.save()
            } catch {
                // Do something in response to error condition
            }
        }
        // update view in repspons to change of core data objects in WaterLog entity.
        updateWater()
    }

    func blurView() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blurView.frame = mainView.bounds
        mainView.addSubview(blurView)
    }

    func drawImage(progressPercentage : Double) -> UIImage {

        let white_rect = CGRectMake(0, 0, waterImageView.frame.width, waterImageView.frame.height * CGFloat(1-progressPercentage))
        
        UIGraphicsBeginImageContextWithOptions(waterImageView.frame.size, false, 0)
        
        UIColor.whiteColor().setFill()
        UIRectFill(white_rect)
        
        let coverImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return coverImage
    }

    // Returns the last WaterLog object in core data framework.
    func getLastWaterLog() -> WaterLog! {
        
        let fetchRequest = NSFetchRequest(entityName: "WaterLog")
        
        let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [WaterLog]
        if (fetchResults?.count>0){
            return fetchResults![(fetchResults?.endIndex)!-1]
        }
        else {
            return nil
        }
    }
}

extension ViewController {

    // Requests HealthKit authorization for saving HKSample object for logging water.
    func requesSavingHKWaterSample(amount: Double) {

        // Set the water type to data types to share (write).
        let dataTypesToShare = Set(arrayLiteral: HealthManager.sharedInstance.waterType!)

        // request the healthkit authorization to share (write) water logs.
        HealthManager.sharedInstance.healthKitStore.requestAuthorizationToShareTypes(dataTypesToShare,
            readTypes: nil, completion: {
                (success: Bool, error: NSError?) -> Void in
                if success {
                    self.saveHKWaterSample(amount)
                } else {
                    print("requestAuthForSavingHKWaterObject() failed.")
                }
            }
        )
    }

    // Saves a HKSample object representing drinking water
    func saveHKWaterSample(amount: Double) {

        let currentUnit: HKUnit = self.currentUnit()

        let waterType = HealthManager.sharedInstance.waterType!
        let waterQuantity = HKQuantity(unit: currentUnit, doubleValue: amount)

        // Creates a water sample (HKQuantitySample object)
        let waterSample = HKQuantitySample(type: waterType,
            quantity: waterQuantity,
            startDate: NSDate(),
            endDate: NSDate())

        // Saves the water sample into the healthkit store.
        HealthManager.sharedInstance.healthKitStore.saveObject(waterSample,
            withCompletion: {
                (success: Bool, error: NSError?) -> Void in
                if error != nil {
                    print("Error saving water sample: \(error?.localizedDescription)")
                } else {
                    print("water sample saved successfully.")
                }
            }
        )
    }

    // Requests HealthKit authorization for deleting last saved HKSample object.
    func requestDeletingLastHKWaterSample() {

        // Set the water type to data types to share and read
        let dataTypes = Set(arrayLiteral: HealthManager.sharedInstance.waterType!)

        // request the healthkit authorization to share (write) water logs.
        HealthManager.sharedInstance.healthKitStore.requestAuthorizationToShareTypes(dataTypes,
            readTypes: dataTypes, completion: {
                (success: Bool, error: NSError?) -> Void in
                if success {
                    self.deleteLastHKWaterSample()
                } else {
                    print("requestAuthForSavingHKWaterObject() failed.")
                }
            }
        )
    }

    // Deletes the last saved HK Sample object representing drinking water.
    func deleteLastHKWaterSample() {

        // Sort the query in descending order.
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        // HKSample query which gets the last saved HKQuantitySample object meaning drinking water.
        let sampleQuery = HKSampleQuery(sampleType: HealthManager.sharedInstance.waterType!,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor],
            resultsHandler: {
                (query, results, error) -> Void in

                if error != nil{
                    print("error: \(error?.localizedDescription)")
                    return
                }

                // If there's some query results,
                if let queryResults = results {
                    // Delete the last saved sample object.
                    HealthManager.sharedInstance.healthKitStore.deleteObject(queryResults[0]) {
                        (success, error) -> Void in

                        if error != nil {
                            print("error: \(error?.localizedDescription)")
                            return
                        }

                        if success {
                            print("water sample deleted successfully.")
                        } else {
                            print("water sample deleted not successfully.")
                            print("error: \(error?.localizedDescription)")
                        }
                    }
                } else {
                    print("There's no HK Sample query results about drinking water")
                }
            }
        )
        
        // Execute the sample query
        HealthManager.sharedInstance.healthKitStore.executeQuery(sampleQuery)
    }
}
