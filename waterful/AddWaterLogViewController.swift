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
import WatchConnectivity
import HealthKit

class AddWaterLogViewController: UIViewController {
    var consumedWater : Double = Double()
    
    var sipCounter : Double = Double()
    var cupCounter : Double = Double()
    var mugCounter : Double = Double()
    var bottleCounter : Double = Double()
    
    var sipVolume : Double = Double()
    var cupVolume : Double = Double()
    var mugVolume : Double = Double()
    var bottleVolume : Double = Double()
    
    @IBOutlet weak var sipVolumeLabel: UILabel!
    @IBOutlet weak var cupVolumeLabel: UILabel!
    @IBOutlet weak var mugVolumeLabel: UILabel!
    @IBOutlet weak var bottleVolumeLabel: UILabel!
    
    @IBOutlet weak var sipCounterLabel: UILabel!
    @IBOutlet weak var cupCounterLabel: UILabel!
    @IBOutlet weak var mugCounterLabel: UILabel!
    @IBOutlet weak var bottleCounterLabel: UILabel!
    
    var consumedAmount : Double = Double()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var consumedLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    @IBAction func sipIncrease(sender: AnyObject) {
        sipCounter++
        updateView()
    }
    @IBAction func sipDecrease(sender: AnyObject) {
        if (sipCounter>=1){
            sipCounter--
            updateView()
        }
    }
    @IBAction func cupIncrease(sender: AnyObject) {
        cupCounter++
        updateView()
    }
    @IBAction func cupDecrease(sender: AnyObject) {
        if (cupCounter>=1){
            cupCounter--
            updateView()
        }
    }
    @IBAction func mugIncrease(sender: AnyObject) {
        mugCounter++
        updateView()
    }
    @IBAction func mugDecrease(sender: AnyObject) {
        if (mugCounter>=1){
            mugCounter--
            updateView()
        }
    }
    @IBAction func bottleIncrease(sender: AnyObject) {
        bottleCounter++
        updateView()
    }
    @IBAction func bottleDecrease(sender: AnyObject) {
        if (bottleCounter>=1){
            bottleCounter--
            updateView()
        }
    }
    
    
    @IBAction func savePressed(sender: AnyObject) {
        addWater()
        navigationController?.popViewControllerAnimated(true)
    }
    
    // managed object context to control core data framework
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // Setting object from core data framework
    var setting_info : Setting! = nil
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {        
        
        setting_info = Setting.getSetting()
        
        sipVolume = (setting_info.sipVolume?.doubleValue)!
        cupVolume = (setting_info.cupVolume?.doubleValue)!
        mugVolume = (setting_info.mugVolume?.doubleValue)!
        bottleVolume = (setting_info.bottleVolume?.doubleValue)!
        
        if setting_info.unit == HKUnit(fromString: "mL") {
            sipVolumeLabel.text = sipVolume.toString + (setting_info.unit?.description)!
            cupVolumeLabel.text = cupVolume.toString + (setting_info.unit?.description)!
            mugVolumeLabel.text = mugVolume.toString + (setting_info.unit?.description)!
            bottleVolumeLabel.text = bottleVolume.toString + (setting_info.unit?.description)!
        }
        else {
            sipVolumeLabel.text = sipVolume.ml_to_oz.toString + (setting_info.unit?.description)!
            cupVolumeLabel.text = cupVolume.ml_to_oz.toString + (setting_info.unit?.description)!
            mugVolumeLabel.text = mugVolume.ml_to_oz.toString + (setting_info.unit?.description)!
            bottleVolumeLabel.text = bottleVolume.ml_to_oz.toString + (setting_info.unit?.description)!
        }
        
        unitLabel.text = setting_info.unit?.description
        
        updateView()
        


        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateView() {
        sipCounterLabel.text = sipCounter.toString
        cupCounterLabel.text = cupCounter.toString
        mugCounterLabel.text = mugCounter.toString
        bottleCounterLabel.text = bottleCounter.toString
        
        consumedAmount = (sipVolume * sipCounter) + (cupVolume * cupCounter) + (mugVolume * mugCounter) + (bottleVolume * bottleCounter)
        if setting_info.unit == HKUnit(fromString: "mL") {
            consumedLabel.text = consumedAmount.toString
        }
        else {
            consumedLabel.text = consumedAmount.ml_to_oz.toString
        }
    }
    
    func addWater() {
        let loggedTime = datePicker.date
        while (sipCounter>0){
            WaterLogManager.saveWaterLog("sip", loggedTime: loggedTime)
            sipCounter--
        }
        while (cupCounter>0){
            WaterLogManager.saveWaterLog("cup", loggedTime: loggedTime)
            cupCounter--
        }
        while (mugCounter>0){
            WaterLogManager.saveWaterLog("mug", loggedTime: loggedTime)
            mugCounter--
        }
        while (bottleCounter>0){
            WaterLogManager.saveWaterLog("bottle", loggedTime: loggedTime)
            bottleCounter--
        }
    }
    
}
