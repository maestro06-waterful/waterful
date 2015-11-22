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
    
    
    @IBOutlet weak var sipUnitLabel: UILabel!
    @IBOutlet weak var cupUnitLabel: UILabel!
    @IBOutlet weak var mugUnitLabel: UILabel!
    @IBOutlet weak var bottleUnitLabel: UILabel!
    @IBOutlet weak var goalUnitLabel: UILabel!
    
    @IBOutlet weak var unitButton: UIButton!
    @IBAction func unitButtonPressed(sender: AnyObject) {
        if setting_info.unit == HKUnit(fromString: "mL") {
            setting_info.unit = HKUnit(fromString: "oz")
        }
        else if setting_info.unit == HKUnit(fromString: "oz") {
            setting_info.unit = HKUnit(fromString: "mL")
        }
        updateTexts()
    }
    
    var goalVolume : Double = Double()
    var sipVolume : Double =  Double()
    var cupVolume : Double =  Double()
    var mugVolume : Double =  Double()
    var bottleVolume : Double =  Double()

    
    @IBAction func userdone(sender: AnyObject) {
        saveSetting()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    var setting_info : Setting!

    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        
        setting_info = fetchSetting()
        
        goalVolume = (setting_info.goal?.doubleValue)!
        sipVolume = (setting_info.sipVolume?.doubleValue)!
        cupVolume = (setting_info.cupVolume?.doubleValue)!
        mugVolume = (setting_info.mugVolume?.doubleValue)!
        bottleVolume = (setting_info.bottleVolume?.doubleValue)!
        
        updateTexts()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.addDoneButtonOnKeyboard()
        
        
        super.viewDidLoad()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTexts (){
        if setting_info.unit == HKUnit(fromString: "mL"){
            goalLabel.text = goalVolume.toString
            sipLabel.text = sipVolume.toString
            cupLabel.text = cupVolume.toString
            mugLabel.text = mugVolume.toString
            bottleLabel.text = bottleVolume.toString
        }
        else if setting_info.unit == HKUnit(fromString: "oz"){
            goalLabel.text = goalVolume.ml_to_oz.toString
            sipLabel.text = sipVolume.ml_to_oz.toString
            cupLabel.text = cupVolume.ml_to_oz.toString
            mugLabel.text = mugVolume.ml_to_oz.toString
            bottleLabel.text = bottleVolume.ml_to_oz.toString
        }
        
        unitButton.setTitle(setting_info.unit?.description, forState: UIControlState.Normal)
        sipUnitLabel.text = setting_info.unit?.description
        cupUnitLabel.text = setting_info.unit?.description
        mugUnitLabel.text = setting_info.unit?.description
        bottleUnitLabel.text = setting_info.unit?.description
        goalUnitLabel.text = setting_info.unit?.description
        
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
        setting_info.sipVolume = sipVolume
        setting_info.cupVolume = cupVolume
        setting_info.mugVolume = mugVolume
        setting_info.bottleVolume = bottleVolume
        setting_info.goal = goalVolume
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        do {
            // save the managet object context
            try managedObjectContext.save()
            
        } catch {
            print("Unresolved error")
            abort()
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // if user writes oz volume when user prefers oz, it convers to ml and save it as ml.
    
    @IBAction func sipLabelChanged(sender: AnyObject) {
        if Double(sipLabel.text!) != nil{
            if setting_info.unit == HKUnit(fromString: "mL"){
                sipVolume = Double(sipLabel.text!)!
            }
            else if setting_info.unit == HKUnit(fromString: "oz"){
                sipVolume = (Double(sipLabel.text!)!.oz_to_ml)
            }
        }
        else{
            let alertController = UIAlertController(title: "invalid", message: "try again", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            updateTexts()
        }
    }
    @IBAction func cupLabelChanged(sender: AnyObject) {
        if Double(cupLabel.text!) != nil {
            if setting_info.unit == HKUnit(fromString: "mL"){
                cupVolume = Double(cupLabel.text!)!
            }
            else if setting_info.unit == HKUnit(fromString: "oz"){
                cupVolume = (Double(cupLabel.text!)!.oz_to_ml)
            }
        }
        else{
            let alertController = UIAlertController(title: "invalid", message: "try again", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            updateTexts()
        }
    }
    
    @IBAction func mugLabelChanged(sender: AnyObject) {
        if Double(mugLabel.text!) != nil {
            if setting_info.unit == HKUnit(fromString: "mL"){
                mugVolume = Double(mugLabel.text!)!
            }
            else if setting_info.unit == HKUnit(fromString: "oz"){
                mugVolume = (Double(mugLabel.text!)!.oz_to_ml)
            }
        }
        else{
            let alertController = UIAlertController(title: "invalid", message: "try again", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            updateTexts()
        }
    }

    @IBAction func bottleLabelChanged(sender: AnyObject) {
        if Double(bottleLabel.text!) != nil {
            if setting_info.unit == HKUnit(fromString: "mL"){
                bottleVolume = Double(bottleLabel.text!)!
            }
            else if setting_info.unit == HKUnit(fromString: "oz"){
                bottleVolume = (Double(bottleLabel.text!)!.oz_to_ml)
            }
        }
        else{
            let alertController = UIAlertController(title: "invalid", message: "try again", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            updateTexts()
        }
    }
    @IBAction func goalLabelChanged(sender: AnyObject) {
        if Double(goalLabel.text!) != nil {
            if setting_info.unit == HKUnit(fromString: "mL"){
                goalVolume = Double(goalLabel.text!)!
            }
            else if setting_info.unit == HKUnit(fromString: "oz"){
                goalVolume = (Double(goalLabel.text!)!.oz_to_ml)
            }
        }
        else{
            let alertController = UIAlertController(title: "invalid", message: "try again", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            updateTexts()
        }
    }
   
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 300, 50))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain  , target: self, action: Selector("dismissKeyboard"))

        
        var items = [AnyObject]()
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items as? [UIBarButtonItem]

        self.sipLabel.inputAccessoryView = doneToolbar
        self.cupLabel.inputAccessoryView = doneToolbar
        self.mugLabel.inputAccessoryView = doneToolbar
        self.bottleLabel.inputAccessoryView = doneToolbar
        self.goalLabel.inputAccessoryView = doneToolbar
        
    }
    
    func doneButtonAction()
    {
        dismissKeyboard()
    }
}
