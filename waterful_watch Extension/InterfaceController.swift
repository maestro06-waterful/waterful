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


class InterfaceController: WKInterfaceController {
    @IBOutlet var mainImage: WKInterfaceImage!
    @IBAction func button1Pressed() {
        // log 40
        sendMessageWC(40, totalAmount: 100)
    }
    @IBAction func button2Pressed() {
        // log 120
        sendMessageWC(120, totalAmount: 100)
    }
    @IBAction func button3Pressed() {
        // log 400
        sendMessageWC(400, totalAmount: 100)
    }
    @IBAction func button4Pressed() {
        // log 500
        sendMessageWC(500, totalAmount: 100)


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
    
    func sendMessageWC(amount : Int, totalAmount : Int, logDate : NSDate = NSDate()){
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            
            let message = [ "TotalAmount" : totalAmount, "Amount" : amount, "LogDate" : logDate]
            

            
            if session.reachable{
                session.sendMessage( message, replyHandler: {(recvMessage : [String:AnyObject]) -> Void in
                    print(String(recvMessage["TotalAmount"]!))
//                  print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
                    }, errorHandler: nil)
            } else {
                
                do {
                    try session.updateApplicationContext(message)
                } catch {
                    print("error")
                }
                
            }
        }
    }

}
