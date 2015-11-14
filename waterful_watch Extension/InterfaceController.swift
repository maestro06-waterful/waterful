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
    
    override func didAppear() {
        getStatus()
        getContainer()
        updateView()

    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func sendAmount(container: String){
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        let applicationDict = ["container" : container]
        do {
            try WCSession.defaultSession().updateApplicationContext(applicationDict)

        } catch {
            print("error")
        }
    }
    
    func getStatus() {
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        if WCSession.defaultSession().reachable == true {
            
            let request :[ String : AnyObject ] = ["command" : "fetchStatus"]
            let session = WCSession.defaultSession()
            
            session.sendMessage(request, replyHandler: { response in
                
                let res = response
                self.consumed = res["consumed"] as! Double
                self.goal = res["goal"] as! Double
                self.updateView()
                
                }, errorHandler: { error in
                    print("error: \(error)")
            })
        }
        
    }
    
    func getContainer() {
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        if WCSession.defaultSession().reachable == true {
            
            let request :[ String : AnyObject ] = ["command" : "fetchContainer"]
            let session = WCSession.defaultSession()
            
            session.sendMessage(request, replyHandler: { response in
                
                let res = response
                self.sipVolume = res["sipVolume"] as! Double
                self.cupVolume = res["cupVolume"] as! Double
                self.mugVolume = res["mugVolume"] as! Double
                self.bottleVolume = res["bottleVolume"] as! Double
                self.updateView()
                
                }, errorHandler: { error in
                    print("error: \(error)")
            })
        }
        
    }
    
    func undoLastWaterLog() {
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        if WCSession.defaultSession().reachable == true {
            
            let request = ["command" : "undo"]
            let session = WCSession.defaultSession()
            
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
        
        consumedLabel.setText(String(format:"%0.f", consumed))
        goalLabel.setText(String(format:"%0.f", goal))
        
        button1.setTitle(String(format:"%0.0f", sipVolume) + "ml")
        button2.setTitle(String(format:"%0.0f", cupVolume) + "ml")
        button3.setTitle(String(format:"%0.0f", mugVolume) + "ml")
        button4.setTitle(String(format:"%0.0f", bottleVolume) + "ml")
        
    }
    
    
}
