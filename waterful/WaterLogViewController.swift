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

class WaterLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var waterLogTableView: UITableView!
    
    var waterLogs : [String :[WaterLog]]!
    var setting : Setting!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        waterLogs = getWaterLogs()
        setting = fetchSetting()
        
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
            removeItem(waterLogs![date]![indexPath.row])
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

        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel!.text = "TOTAL: " + String(format: "%0.f", sum)
        footer.textLabel!.textAlignment = NSTextAlignment.Right
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var sum : Double = 0
        let date = Array(waterLogs.keys)[section]
        for item in waterLogs[date]! {
            sum = sum + (item.amount?.doubleValue)!
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
        let amount = String(format: "%.0f", element.amount!.doubleValue) + (setting.unit?.description)!
        let container = element.container
        
        tableViewCell.loggedTime.text = loggedTime
        tableViewCell.amount.text = amount
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
    
    func removeItem(item : WaterLog){
        managedObjectContext.deleteObject(item)
        do {
            try managedObjectContext.save()
        } catch {
            // Do something in response to error condition
        }
    }

}

class WaterLogTableCell : UITableViewCell {
    
    @IBOutlet weak var loggedTime: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
}