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
    @IBOutlet var mainImage: WKInterfaceImage!
    @IBAction func button1Pressed() {
        sendAmount(40)
        // log 40
    }
    @IBAction func button2Pressed() {
        sendAmount(120)
        // log 120
    }
    @IBAction func button3Pressed() {
        sendAmount(400)
        // log 400
    }
    @IBAction func button4Pressed() {
        sendAmount(500)
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

}
