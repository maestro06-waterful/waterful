//
//  WaterLogTableViewController.swift
//  waterful
//
//  Created by HONGYOONSEOK on 2015. 10. 31..
//  Copyright © 2015년 suz. All rights reserved.
//

import UIKit
import CoreData

class WaterLogTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        initializeLogData()
        
    }
    
    var todayLogArray : [WaterLog] = []
//    var waterLogTotalArray : [WaterLog] = []
    
    
    let dateFormatter = NSDateFormatter()
    
    func initializeLogData(){

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
//        dateFormatter.timeStyle = .ShortStyle
//        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()

        let waterLogTotalArray = fetchWaterLog()
        todayLogArray.removeAll()
        
        let today = getDate(NSDate(timeIntervalSinceNow: NSTimeInterval(NSTimeZone.defaultTimeZone().secondsFromGMT)))
        
        for result in waterLogTotalArray {
            if(getDate(result.loggedTime!) == today){
                todayLogArray.append(result)
            }
        }
        
    }
    
    func fetchWaterLog() -> [WaterLog]{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "WaterLog")
        
        let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [WaterLog]
        return fetchResults!
    }
    
    func getDate(date : NSDate) -> String{
        return (date.description as NSString).substringToIndex(10)
    }
    
    func deleteObject(index : Int){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
            
        let logItemToDelete = todayLogArray[index]
            
        // Delete it from the managedObjectContext
        managedContext.deleteObject(logItemToDelete)
        
        do {
            try managedContext.save()
            
        } catch {
            print("DeleteObject Managed Context Save Error")
            abort()
        }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        /*

            여기서 헬스킷 데이터 지우면 됩니당~



        */
        
//        initializeLogData()
            todayLogArray.removeAtIndex(index)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todayLogArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WaterLogTableViewCell", forIndexPath: indexPath) as! WaterLogTableViewCell

        // Configure the cell...
        let rowData : WaterLog = todayLogArray[indexPath.row]
        cell.label_logDate.text = dateFormatter.stringFromDate(rowData.loggedTime!)
        cell.label_logCount.text = String(rowData.amount!)
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source

            
            deleteObject(indexPath.row)

            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
