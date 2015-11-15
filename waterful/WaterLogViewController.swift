//
//  WaterLogViewController.swift
//  waterful
//
//  Created by suz on 11/13/15.
//  Copyright © 2015 suz. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import HealthKit

class WaterLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var waterLogTableView: UITableView!
    
    var waterLogs : [String :[WaterLog]]!
    var setting_info : Setting!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        waterLogs = getWaterLogs()
        setting_info = fetchSetting()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        //waterLogTableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let date = Array(waterLogs.keys)[indexPath.section]
            removeItem(date, rowIndex: indexPath.row)
            // tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            waterLogs = getWaterLogs()
            waterLogTableView.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return Array(waterLogs.keys).count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(waterLogs.keys)[section]
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let date = Array(waterLogs.keys)[section]
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.text = date
        header.textLabel?.font = UIFont(name: "Helvetica", size: 20)
        
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        var sum : Double = 0
        let date = Array(waterLogs.keys)[section]
        for item in waterLogs[date]! {
            sum = sum + (item.amount?.doubleValue)!
        }
        if setting_info.unit == HKUnit(fromString: "oz"){
            sum = sum.ml_to_oz
        }
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel!.text = "TOTAL: " + String(format: "%0.f", sum) + " " + (setting_info.unit?.description)!
        footer.textLabel!.textAlignment = NSTextAlignment.Right
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var sum : Double = 0
        let date = Array(waterLogs.keys)[section]
        for item in waterLogs[date]! {
            sum = sum + (item.amount?.doubleValue)!
        }
        if setting_info.unit == HKUnit(fromString: "oz"){
            sum = sum.ml_to_oz
        }
        return "SUM: " + String(format: "%0.f", sum)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        let date = Array(waterLogs.keys)[section]
        return (waterLogs[date]?.count)!
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableViewCell = waterLogTableView.dequeueReusableCellWithIdentifier("CELL") as! WaterLogTableCell
        
        //we know that cell is not empty now so we use ! to force unwrapping
        tableViewCell.editing = true
        //let date = Array(waterLogs.keys)[indexPath.row
        let date = Array(waterLogs.keys)[indexPath.section]
        let element :WaterLog = waterLogs[date]![indexPath.row]
        let loggedTime = getTime(element.loggedTime!)
        
        
        var amount: Double = Double()
        if setting_info.unit == HKUnit(fromString: "mL") {
            amount = (element.amount?.doubleValue)!
        }
        else if setting_info.unit == HKUnit(fromString: "oz") {
            amount = (element.amount?.doubleValue)!.ml_to_oz
        }

        let container = element.container
        
        tableViewCell.loggedTime.text = loggedTime
        tableViewCell.amount.text = String(format: "%.0f", amount) + " " +  (setting_info.unit?.description)!
        tableViewCell.icon.image = UIImage(named: container!)
        
        return tableViewCell
        
    }
    
    
    func getWaterLogs() -> [String :[WaterLog]]? {
        // today water logs to return.
        
        let fetchRequest = NSFetchRequest(entityName: "WaterLog")
        let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [WaterLog]
        
        var waterLogs : [String :[WaterLog]]! = [String :[WaterLog]]()
        
        for result in fetchResults!.reverse() {
            let date = getDate(result.loggedTime!)
            if (waterLogs[date] == nil) {
                waterLogs[date] = []
            }
            
            waterLogs[date]?.append(result)
        }
        
        return waterLogs
    }
    
    func getTime(date: NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        let timeString = dateFormatter.stringFromDate(date)
        return timeString
    }
    
    func getDate(date : NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
    
    func getTimestamp(date : NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:MM"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
    
    func fetchSetting() -> Setting! {
        
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [Setting]
        
        if (fetchResults!.count == 0){
            return nil
        } else {
            return fetchResults![0]
        }
        
    }
    
    func removeItem(date: String, rowIndex: Int) {
        managedObjectContext.deleteObject(self.waterLogs[date]![rowIndex])
        do {
            try managedObjectContext.save()
        } catch {
            // Do something in response to error condition
        }
        self.requestDeletingHKWaterSample(rowIndex)
    }

}

extension WaterLogViewController {
    
    // Requests HealthKit authorization for deleting HKSample object with specified index.
    func requestDeletingHKWaterSample(index: Int) {
        
        let dataTypes = Set(arrayLiteral: HealthManager.sharedInstance.waterType!)
        
        HealthManager.sharedInstance.healthKitStore.requestAuthorizationToShareTypes(dataTypes,
            readTypes: dataTypes,
            completion: {
                (success: Bool, error: NSError?) -> Void in
                if success {
                    self.deleteHKWaterSample(index)
                } else {
                    print("requestDeletingHKWaterSample() failed.")
                }
            }
        )
    }

    // Deletes the HK Sample object with specified index.
    func deleteHKWaterSample(index: Int) {
        
        // Sort the query in descending order.
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // HKSample query which gets the last saved HKQuantitySample object meaning drinking water.
        let sampleQuery = HKSampleQuery(sampleType: HealthManager.sharedInstance.waterType!,
            predicate: nil,
            limit: 0,
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
                    HealthManager.sharedInstance.healthKitStore.deleteObject(queryResults[index]) {
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

class WaterLogTableCell : UITableViewCell {
    
    @IBOutlet weak var loggedTime: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
}