//
//  GlanceInterfaceController.swift
//  waterful_watch Extension
//
//  Created by suz on 10/9/15.
//  Copyright © 2015 suz. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class GlanceInterfaceController: WKInterfaceController, WCSessionDelegate {

    var consumed : Double = Double()
    var goal : Double = Double()
    
    @IBOutlet var consumedLabel: WKInterfaceLabel!
    @IBOutlet var goalLabel: WKInterfaceLabel!

    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    override init() {
        super.init()
        
        session?.delegate = self
        session?.activateSession()
    }
    
    override func didAppear() {

    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        getStatus()
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func sendAmount(amount: Double){
        let applicationDict = ["amount" : amount]
        do {
            try session?.updateApplicationContext(applicationDict)
            
            
        } catch {
            print("error")
        }
    }
    
    func getStatus() {
        if WCSession.defaultSession().reachable == true{
            session?.sendMessage(["command" : "fetchStatus"],
                replyHandler: { (response) in
                    let res = response
                    self.consumed = res["consumed"] as! Double
                    self.goal = res["goal"] as! Double
                    
                    self.updateView()
                    
                }, errorHandler: { (error) in
                    NSLog("Error sending message: %@", error)
                    
                }
            )
        }
    }
    
    func updateView() {
        consumedLabel.setText(String(format:"%0.f", consumed))
        goalLabel.setText("/ " + String(format:"%0.f", goal))
    }
    
}
