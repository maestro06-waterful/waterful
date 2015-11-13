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
    
    @IBOutlet var consumedLabel: WKInterfaceLabel!
    @IBOutlet var goalLabel: WKInterfaceLabel!

    @IBAction func button1Pressed() {
        sendAmount(40)
        consumed = consumed + 40
        self.updateView()
    }
    @IBAction func button2Pressed() {
        sendAmount(120)
        consumed = consumed + 120
        self.updateView()
    }
    @IBAction func button3Pressed() {
        sendAmount(400)
        consumed = consumed + 400
        self.updateView()
    }
    @IBAction func button4Pressed() {
        sendAmount(500)
        consumed = consumed + 500
        self.updateView()
        
    }
    
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    override init() {
        super.init()
        
        session?.delegate = self
        session?.activateSession()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        getStatus()
        updateView()
        
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
        session?.sendMessage(["request" : "fetchStatus"],
            replyHandler: { (response) in
                let res = response
                self.consumed = res["consumed"] as! Double
                print (String(self.consumed))
                self.goal = res["goal"] as! Double
                self.updateView()
                
            }, errorHandler: { (error) in
                NSLog("Error sending message: %@", error)
                
            }
        )
    }
    
    func updateView() {
        consumedLabel.setText(String(format:"%0.f", consumed))
        goalLabel.setText(String(format:"%0.f", goal))
    }
    
}
