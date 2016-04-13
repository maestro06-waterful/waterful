//
//  InterfaceController.swift
//  waterful_watch Extension
//
//  Created by suz on 10/9/15.
//  Copyright © 2015 suz. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    var consumed : Double = Double()
    var goal : Double = Double()
    
    var sipVolume : Double = Double()
    var cupVolume : Double = Double()
    var mugVolume : Double = Double()
    var bottleVolume : Double = Double()
    
    var unit : String = String()
    
    var session : WCSession = WCSession.defaultSession()
    
    @IBOutlet var consumedLabel: WKInterfaceLabel!
    @IBOutlet var goalLabel: WKInterfaceLabel!
    
    @IBAction func button1Pressed() {
        sendAmount("sip")
        consumed = consumed + sipVolume
        self.updateView()
    }
    @IBAction func button2Pressed() {
        sendAmount("cup")
        consumed = consumed + cupVolume
        self.updateView()
    }
    @IBAction func button3Pressed() {
        sendAmount("mug")
        consumed = consumed + mugVolume
        self.updateView()
    }
    @IBAction func button4Pressed() {
        sendAmount("bottle")
        consumed = consumed + bottleVolume
        self.updateView()
    }
    @IBOutlet var button1: WKInterfaceButton!
    @IBOutlet var button2: WKInterfaceButton!
    @IBOutlet var button3: WKInterfaceButton!
    @IBOutlet var button4: WKInterfaceButton!
    
    @IBAction func undoPressed() {
        undoLastWaterLog()
    }
    
    @IBAction func refreshPressed() {
        getStatus()
        getContainer()
        self.updateView()
    }
    
    override init() {
        super.init()
        self.getSession()
        getStatus()
        getContainer()
        self.updateView()
    }
    
    override func didAppear() {
        getStatus()
        getContainer()
        self.updateView()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        getStatus()
        getContainer()
        self.updateView()
    }
    
    override func didDeactivate() {
        
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func getSession() {
        if (WCSession.isSupported()) {
            self.session = WCSession.defaultSession()
            self.session.delegate = self
            self.session.activateSession()
        }
    }
    
    func sendAmount(container: String){
        let applicationDict = ["container" : container]
        do {
            try self.session.updateApplicationContext(applicationDict)
            
        } catch {
            print("error")
        }
    }
    
    func getStatus() {
        let current_consumed : Double = self.consumed
        let current_goal : Double = self.goal

        if self.session.reachable == true {
            let request :[ String : AnyObject ] = ["command" : "fetchStatus"]
            self.session.sendMessage(request, replyHandler: { response in
                let res = response
                self.consumed = res["consumed"] as! Double
                self.goal = res["goal"] as! Double
                if (current_consumed != self.consumed || current_goal != self.goal){
                    self.updateView()
                }
                self.updateView()
                }, errorHandler: { error in
                    print("error: \(error)")
            })
        }
        
    }
    
    func getContainer() {
        if self.session.reachable == true {
            let request :[ String : AnyObject ] = ["command" : "fetchContainer"]
            let session = WCSession.defaultSession()
            
            session.sendMessage(request, replyHandler: { response in
                
                let res = response
                self.unit = res["unit"] as! String
                if self.unit == "mL" {
                    self.sipVolume = res["sipVolume"] as! Double
                    self.cupVolume = res["cupVolume"] as! Double
                    self.mugVolume = res["mugVolume"] as! Double
                    self.bottleVolume = res["bottleVolume"] as! Double
                }
                    // in watch, if user wants to use "oz", store variable as oz. because watch takes soooo long
                else if self.unit == "oz" {
                    self.sipVolume = (res["sipVolume"] as! Double).ml_to_oz
                    self.cupVolume = (res["cupVolume"] as! Double).ml_to_oz
                    self.mugVolume = (res["mugVolume"] as! Double).ml_to_oz
                    self.bottleVolume = (res["bottleVolume"] as! Double).ml_to_oz
                }
                self.updateView()
                
                }, errorHandler: { error in
                    print("error: \(error)")
            })
        }
        
    }
    
    func undoLastWaterLog() {
        if self.session.reachable == true {
            let request = ["command" : "undo"]
            session.sendMessage(request, replyHandler: { response in
                let res = response
                
                self.consumed = res["consumed"] as! Double
                
                self.updateView()
                
                }, errorHandler: { error in
                    print("error: \(error)")
            })
        }
    }
    
    func updateView() {
        
        consumedLabel.setText(consumed.toString)
        goalLabel.setText(goal.toString)
        
        button1.setTitle(sipVolume.toString + unit)
        button2.setTitle(cupVolume.toString + unit)
        button3.setTitle(mugVolume.toString + unit)
        button4.setTitle(bottleVolume.toString + unit)
        
    }
    
    
}
