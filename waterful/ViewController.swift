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

class ViewController: UIViewController, WCSessionDelegate {
    var consumedWater : Double = Double()
    var goalWater : Double = Double()
    
    // managed object context to control core data framework
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // session with watch
    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil

    // Setting object from core data framework
    var setting_info : Setting! = nil

    @IBOutlet var mainView: UIView!

    @IBOutlet weak var consumed: UILabel!
    @IBOutlet weak var goal: UILabel!
    @IBOutlet weak var consumedUnit: UILabel!
    @IBOutlet weak var goalUnit: UILabel!
    @IBOutlet weak var cl_consumed: UILabel!
    @IBOutlet weak var cl_left: UILabel!
    
    @IBOutlet weak var waterImageView: UIImageView!
    
    @IBOutlet weak var unitLeft: UILabel!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var shortcut: UIButton!
    
    @IBOutlet weak var sipLabel: UILabel!
    @IBOutlet weak var cupLabel: UILabel!
    @IBOutlet weak var mugLabel: UILabel!
    @IBOutlet weak var bottleLabel: UILabel!
    
    @IBAction func shortcutPressed(sender: AnyObject) {
        if let lastWaterLog = WaterLogManager.getLastWaterLog() {
            WaterLogManager.saveWaterLog(lastWaterLog.container!)
            self.updateViewForWater()
        }
    }

    @IBAction func button1Pressed(sender: AnyObject) {
        WaterLogManager.saveWaterLog("sip")
        self.updateViewForWater()
    }
    
    @IBAction func button2Pressed(sender: AnyObject) {
        WaterLogManager.saveWaterLog("cup")
        self.updateViewForWater()
    }
    
    @IBAction func button3Pressed(sender: AnyObject) {
        WaterLogManager.saveWaterLog("mug")
        self.updateViewForWater()
    }
    
    @IBAction func button4Pressed(sender: AnyObject) {
        WaterLogManager.saveWaterLog("bottle")
        self.updateViewForWater()
    }
    
    @IBAction func undoPressed(sender: AnyObject) {
        WaterLogManager.undoLastWaterLog()
        self.updateViewForWater()
    }
    @IBAction func cl_pressed(sender: AnyObject) {
        if consumedWater < goalWater {
            if cl_consumed.hidden == true {
                cl_consumed.hidden = false
                cl_left.hidden = true
            }
            else if cl_consumed.hidden == false {
                cl_consumed.hidden = true
                cl_left.hidden = false
            }
            
            if cl_consumed.hidden == false {
                consumed.text = consumedWater.toString
            }
            else {
                consumed.text = (goalWater - consumedWater).toString
            }
        }

    }

    override func viewWillAppear(animated: Bool) {
        // Setting up informatinos about water
        self.updateViewForSetting()
        self.updateViewForWater()
        
        if setting_info.unit == HKUnit(fromString: "mL"){
            sipLabel.text = (setting_info.sipVolume?.doubleValue.toString)! + (setting_info.unit?.description)!
            cupLabel.text = (setting_info.cupVolume?.doubleValue.toString)! + (setting_info.unit?.description)!
            mugLabel.text = (setting_info.mugVolume?.doubleValue.toString)! + (setting_info.unit?.description)!
            bottleLabel.text = (setting_info.bottleVolume?.doubleValue.toString)! + (setting_info.unit?.description)!
        }
        else if setting_info.unit == HKUnit(fromString: "oz"){
            sipLabel.text = (setting_info.sipVolume?.doubleValue.ml_to_oz.toString)! + (setting_info.unit?.description)!
            cupLabel.text = (setting_info.cupVolume?.doubleValue.ml_to_oz.toString)! + (setting_info.unit?.description)!
            mugLabel.text = (setting_info.mugVolume?.doubleValue.ml_to_oz.toString)! + (setting_info.unit?.description)!
            bottleLabel.text = (setting_info.bottleVolume?.doubleValue.ml_to_oz.toString)! + (setting_info.unit?.description)!
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureWCSession()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        configureWCSession()
    }
    
    override func viewDidLoad() {
        cl_left.hidden = true
        
        //create watch session
        configureWCSession()
        
        // navigation controller
        let logo : UIImage = UIImage(named: "logo")!
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 25))
        logoView.contentMode = .ScaleAspectFit
        logoView.image = logo
        self.navigationItem.titleView = logoView
        
        // make gradient background
        let gl : CAGradientLayer = CAGradientLayer()
        gl.colors = [UIColor(white: 0.95, alpha: 1).CGColor, UIColor(white: 0.9, alpha: 1).CGColor]
        gl.locations = [0.5,1.0]
        gl.frame = mainView.bounds
        self.view.layer.insertSublayer(gl, atIndex: 0)
        
        // make water image view circular.
        let themeColor : UIColor = UIColor(patternImage: UIImage(named: "themeColor")!)
        waterImageView.layer.masksToBounds = false
        waterImageView.layer.cornerRadius = waterImageView.frame.height/2
        waterImageView.clipsToBounds = true
        
        waterImageView.layer.borderWidth = 1
        waterImageView.layer.borderColor = themeColor.CGColor

        
        // make shortcut button circular.
        shortcut.layer.cornerRadius = shortcut.imageView!.frame.height/2
        shortcut.clipsToBounds = true
        shortcut.contentMode = UIViewContentMode.Center

        
        let buttons : [UIButton] = [button1, button2, button3, button4]
        for button in buttons {
            button.contentMode = .ScaleAspectFit
            button.layer.cornerRadius = button.frame.height/2
            button.backgroundColor = themeColor
        }

        setting_info = Setting.getSetting()
        // first time user.
        if (setting_info == nil){
            setting_info = Setting.initialSetting()
            

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

    // update this view in response to change of setting.
    func updateViewForSetting() {

        setting_info = Setting.getSetting()

        if setting_info.unit == HKUnit(fromString: "mL"){
            goal.text = setting_info.goal?.doubleValue.toString
        }
        else if setting_info.unit == HKUnit(fromString: "oz"){
            goal.text = setting_info.goal?.doubleValue.ml_to_oz.toString
        }
        
        goalUnit.text = setting_info.unit?.description
        consumedUnit.text = setting_info.unit?.description
    }

    // update this view in response to change of water logs
    func updateViewForWater() {

        consumedWater = WaterLogManager.getTodayConsumption()
        goalWater = (setting_info.goal?.doubleValue)!
        if setting_info.unit == HKUnit(fromString: "oz") {
            consumedWater = consumedWater.ml_to_oz
            goalWater = goalWater.ml_to_oz
        }
        
        consumed.text = consumedWater.toString
        
        let progressPercentage = consumedWater / goalWater
        let lastWaterLog : WaterLog! = WaterLogManager.getLastWaterLog()
        let waterLeft : Double = goalWater - consumedWater

        // show image of last unit.
        if lastWaterLog != nil {
            let lastContainer = lastWaterLog.container
            var lastContainerVolume : Double = Double()
            if (setting_info.unit == HKUnit(fromString: "mL")){
                lastContainerVolume = WaterLogManager.getVolume(lastContainer!)
            }
            else if (setting_info.unit == HKUnit(fromString: "oz")){
                lastContainerVolume = WaterLogManager.getVolume(lastContainer!).ml_to_oz
            }
            
            let lastUnitImage = UIImage(named: lastContainer! + "_shortcut")
            shortcut.setBackgroundImage(lastUnitImage, forState: .Normal)
            // show how much drinks you have to drink with the unit.
            
            if waterLeft > 0 {
                unitLeft.text = "X " + (waterLeft / lastContainerVolume).toString + " left"
            }
            else {
                unitLeft.text = nil
            }
        }
        else {
            shortcut.setBackgroundImage(nil, forState: .Normal)
            unitLeft.text = nil
        }
        if waterLeft < 0 {
            cl_consumed.hidden = false
            cl_left.hidden = true
        }
        if cl_consumed.hidden == false {
            consumed.text = consumedWater.toString
        }
        else {
            consumed.text = (goalWater - consumedWater).toString
        }
        
        // add gradient image on shortcut button
        let gl : CAGradientLayer = CAGradientLayer()
        let border = UIColor(red: 225/255, green: 234/255, blue: 241/255, alpha: 0.8).CGColor
        let color1 = UIColor(red: 255/255, green: 248/255, blue: 166/255, alpha: 0.8).CGColor
        let color2 = UIColor(red: 105/255, green: 217/255, blue: 193/255, alpha: 0.8).CGColor
        let color3 = UIColor(red: 0/255, green: 209/255, blue: 234/255, alpha: 0.8).CGColor
        let color4 = UIColor(red: 0/255, green: 177/255, blue: 198/255, alpha: 0.8).CGColor
        
        gl.colors = [border, color1, color2, color3, color4]
        gl.locations = [0, 0.05, 0.5, 0.8, 1]
        let height = waterImageView.frame.height * CGFloat(progressPercentage)
        gl.frame = CGRect(x: 0, y: waterImageView.frame.height - height, width: waterImageView.frame.width, height: height)
        gl.name = "progressImage"
        waterImageView.layer.sublayers?.removeAll()
        waterImageView.layer.addSublayer(gl)
        
        
    }

    func blurView() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blurView.frame = mainView.bounds
        mainView.addSubview(blurView)
    }

}

extension ViewController{

    // handle watch
    private func configureWCSession() {
        session?.delegate = self;
        session?.activateSession()
    }
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let container = applicationContext["container"] as! String
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            WaterLogManager.saveWaterLog(container)
            self.updateViewForWater()
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        let currentSetting = Setting.getSetting()
        switch message["command"] as! String {
            
        case "undo" :
            WaterLogManager.undoLastWaterLog()
            self.updateViewForWater()
            let setting = Setting.getSetting()
            if setting!.unit == HKUnit(fromString: "mL"){
                replyHandler(["consumed": WaterLogManager.getTodayConsumption()])
            }
            else {
                replyHandler(["consumed": WaterLogManager.getTodayConsumption().ml_to_oz])
            }
            
        case "fetchStatus" :
            let setting = Setting.getSetting()
            var consumed : Double = Double()
            var goal : Double = Double()
            
            if setting!.unit == HKUnit(fromString: "mL"){
                consumed = WaterLogManager.getTodayConsumption()
                goal = (setting!.goal?.doubleValue)!
            }
            else {
                consumed = WaterLogManager.getTodayConsumption().ml_to_oz
                goal = (setting!.goal?.doubleValue.ml_to_oz)!
            }
            
            replyHandler(["consumed" : consumed, "goal": goal])
            
        case "fetchContainer" :
            let setting = currentSetting!
            let sip = setting.sipVolume
            let cup = setting.cupVolume
            let mug = setting.mugVolume
            let bottle = setting.bottleVolume
            let unit = setting.unit?.description
            replyHandler(["sipVolume" : sip!, "cupVolume": cup!, "mugVolume" : mug!, "bottleVolume" : bottle!, "unit" : unit!])
            
        default:
            break
        }
    }
}
