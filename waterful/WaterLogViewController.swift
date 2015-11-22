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
    
    @IBOutlet weak var waterLogBarView: UIView!
    @IBOutlet var waterLogTableView: UITableView!
    
    var waterLogs : [String :[WaterLog]]!
    var setting_info : Setting!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        waterLogs = getWaterLogs()
        setting_info = fetchSetting()
        drawCharts()
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
        footer.textLabel!.text = "TOTAL: " + sum.toString + " " + (setting_info.unit?.description)!
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
        return "TOTAL: " + sum.toString
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
        tableViewCell.amount.text = amount.toString + " " +  (setting_info.unit?.description)!
        tableViewCell.icon.image = UIImage(named: container! + "_icon")
        
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

extension WaterLogViewController {
    func getDay(date : NSDate) -> String {
        // get day. (Mon, Tue, ...)
        let dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "EE"
        dayFormatter.timeZone = NSTimeZone.defaultTimeZone()
        let dayString = dayFormatter.stringFromDate(date)
        return dayString
        
    }
    func drawCharts() {
        /// get date
        let ti = NSTimeInterval.init(86400) //time interval for one day
        
        let width : CGFloat = self.view.bounds.width/14
        let cellWidth : CGFloat = 1.8 * width
        
        for i in  0...6 {
            let j = 6-i // to print backward.
            var sum = Double()
            let date = NSDate().dateByAddingTimeInterval(-ti * Double(j))
            
            if waterLogs[getDate(date)] != nil {
                for item in waterLogs[getDate(date)]! {
                    sum = sum + (item.amount?.doubleValue)!
                }
            }
            
            let processPercentage : Double = sum / (setting_info.goal?.doubleValue)!
            
            // draw image of bar
            
            let maximum_bar_height : CGFloat = 170
            let imageView = UIImageView(frame: CGRectMake(cellWidth + cellWidth*CGFloat(i), 10 , width, CGFloat(maximum_bar_height)))
            imageView.contentMode = .Bottom
            self.view.addSubview(imageView)
            var height : CGFloat = maximum_bar_height * CGFloat(processPercentage)
            if height >= maximum_bar_height {
                height = maximum_bar_height
                let achievementView = UIImageView(frame: CGRectMake(cellWidth + cellWidth*CGFloat(i), 10 , width, width))
                achievementView.image = UIImage(named: "achievementBadge")
                self.view.addSubview(achievementView)
            }
            if height > 0 {
                let image = drawCustomImage(width, height: height)
                imageView.image = image
            }
            
            
            // put label of day (Mon, Tue, ...)
            let label = UILabel(frame: CGRectMake(cellWidth + cellWidth * CGFloat(i), 180, width , 20))
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont(name: label.font.fontName, size: 10)
            
            label.text = getDay(date)
            self.view.addSubview(label)
        }
        
        
        let maxLabel = UILabel(frame: CGRectMake(10 , 10, width , 20))
        maxLabel.textAlignment = NSTextAlignment.Center
        maxLabel.font = UIFont(name: maxLabel.font.fontName, size: 10)
        //maxLabel.textColor = UIColor.whiteColor()
        maxLabel.text = "100%"
        
        self.view.addSubview(maxLabel)
        
        let middleLabel = UILabel(frame: CGRectMake(10 , 90, width , 20))
        middleLabel.textAlignment = NSTextAlignment.Center
        middleLabel.font = UIFont(name: middleLabel.font.fontName, size: 10)
        //middleLabel.textColor = UIColor.whiteColor()
        middleLabel.text = "50%"
        
        self.view.addSubview(middleLabel)
        
        let minLabel = UILabel(frame: CGRectMake(10 , 170, width , 20))
        minLabel.textAlignment = NSTextAlignment.Center
        minLabel.font = UIFont(name: minLabel.font.fontName, size: 10)
        //minLabel.textColor = UIColor.whiteColor()
        minLabel.text = "0%"
        self.view.addSubview(minLabel)
        
    }
    
    func drawCustomImage(width
        :CGFloat , height: CGFloat) -> UIImage {
        // Setup our context
        let themeColor : UIColor = UIColor(patternImage: UIImage(named: "themeColor")!)
        let size = CGSize(width: width, height: height)
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        themeColor.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image    }
}

class WaterLogTableCell : UITableViewCell {
    
    @IBOutlet weak var loggedTime: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
}
