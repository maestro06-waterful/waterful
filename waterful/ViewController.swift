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
    
    var setting_info : Setting!
    
    @IBOutlet var mainView: UIView!

    @IBOutlet weak var consumed: UILabel!
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var lastUnitView: UIImageView!
    
    @IBOutlet weak var goal: UILabel!
    
    @IBOutlet weak var unitLeft: UILabel!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    
    
    


    @IBAction func button1Pressed(sender: AnyObject) {
        logWater(40)
    }
    
    @IBAction func button2Pressed(sender: AnyObject) {
        logWater(120)
    }
    
    @IBAction func button3Pressed(sender: AnyObject) {
        logWater(400)
    }
    
    @IBAction func button4Pressed(sender: AnyObject) {
        logWater(500)
    }
    
    @IBAction func undoPressed(sender: AnyObject) {
        undoLog()
    }

    
    
    override func viewWillAppear(animated: Bool) {
        // Setting up informatinos about water
        updateWater()
        navigationController?.navigationBarHidden = true
    }
    
    override func viewDidLoad() {
        
        mainImageView.layer.masksToBounds = false
        mainImageView.layer.cornerRadius = mainImageView.frame.height/2
        mainImageView.clipsToBounds = true
        let dottedPattern = UIImage(named: "dottedPattern")
        
        mainImageView.layer.borderWidth = 1
        mainImageView.layer.borderColor = UIColor(patternImage: dottedPattern!).CGColor
        

        
        let buttons : [UIButton] = [button1, button2, button3, button4]
        for button in buttons {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(patternImage: dottedPattern!).CGColor
            button.layer.cornerRadius = button.frame.height/4

            
        }
        
        
        

        setting_info = fetchSetting()
        // first time user.
        if (setting_info == nil){
            setting_info = setSetting()
            

            // !!!!!!!! SUBVIEW !!!!!!!!!!
            // press OK in subview -> !!!! END BLUR !!!!!
        }

        goal.text = setting_info.goal?.description
        
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
    
    func fetchWater() -> Int {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "WaterLog")
        
        let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [WaterLog]
        
        var consumed : Int = 0
        
        let today = getDate(NSDate())
        
        for result in fetchResults! {
            if (getDate(result.loggedTime!) == today){
                consumed = consumed + Int(result.amount!)
            }
            else {
                break
            }
        }
        
        
        return consumed
    }
    
    // set settings, if there is no.
    func setSetting() -> Setting {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let setting_info = NSEntityDescription.insertNewObjectForEntityForName("Setting",
            inManagedObjectContext: managedContext) as! Setting
        
        setting_info.goal = 3000
        setting_info.alarmEndTime = 23
        setting_info.alarmStartTime = 9
        setting_info.alarmInterval = 3
        setting_info.unit = HKUnit(fromString: "mL")
        
        do {
            try managedContext.save()
            
        } catch {
            print("Unresolved error")
            abort()
        }
        
        return setting_info
    }

    // fetch settings from
    func fetchSetting() -> Setting! {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        
        let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [Setting]

        if (fetchResults!.count == 0){
            return nil
        }
            
        else {
            return fetchResults![0]
        }
    }
    
    // store amount of water user consumed
    func logWater(amount : Int){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let water_info = NSEntityDescription.insertNewObjectForEntityForName("WaterLog",
            inManagedObjectContext: managedContext) as! WaterLog
        
        water_info.amount = amount
        water_info.loggedTime = NSDate()
        
        do {
            try managedContext.save()
            
        } catch {
            print("Unresolved error")
            abort()
        }
        updateWater()
    }
    
    // update text of consumed water
    func updateWater() {
        let consumedWater = fetchWater()
        consumed.text = String(consumedWater)
        
        let ProgressPercentage = Double(consumedWater) / Double(setting_info.goal!)
        
        let lastElement : WaterLog! = getLastElement()
        // show image of last unit.
        if lastElement != nil {
            lastUnitView.image = UIImage(named: String(lastElement.amount!) + "ml")
            // show how much drinks you have to drink with the unit.
            let waterLeft : Double = Double(setting_info.goal!) - Double(consumedWater)
            if waterLeft > 0 {
                unitLeft.text = String( round(waterLeft * 100 / Double(lastElement.amount!)) / 100 ) + " left"
            }
            else {
                unitLeft.text = nil
            }
        }
        else {
            lastUnitView.image = nil
            unitLeft.text = nil
        }
        

        
        
        // cover blue background with white image to show progress status
        mainImageView.image = drawImage(ProgressPercentage)
    }
    
    func undoLog(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "WaterLog")
        
        let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [WaterLog]
        
        let today = getDate(NSDate())
        
        var todayResult : [WaterLog] = []
        
        for result in fetchResults! {
            if (getDate(result.loggedTime!) == today){
                todayResult.append(result)
            }
            else {
                break
            }
        }
        
        let tmp = todayResult.endIndex-1
        if (tmp >= 0){
            managedContext.deleteObject(todayResult[tmp])
        }
        
        do {
            try managedContext.save()
        } catch {
            // Do something in response to error condition
        }
        updateWater()
    }
    
    func blurView() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blurView.frame = mainView.bounds
        mainView.addSubview(blurView)
    }
    
    func drawImage(progressPercentage : Double) -> UIImage {

        let white_rect = CGRectMake(0, 0, mainImageView.frame.width, mainImageView.frame.height * CGFloat(1-progressPercentage))
        
        UIGraphicsBeginImageContextWithOptions(mainImageView.frame.size, false, 0)
        
        UIColor.whiteColor().setFill()
        UIRectFill(white_rect)
        
        let coverImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return coverImage
    }
    
    func getLastElement() -> WaterLog! {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "WaterLog")
        
        let fetchResults = (try? managedContext.executeFetchRequest(fetchRequest)) as? [WaterLog]
        if (fetchResults?.count>0){
            return fetchResults![(fetchResults?.endIndex)!-1]
        }
        else {
            return nil
        }
    }
}

