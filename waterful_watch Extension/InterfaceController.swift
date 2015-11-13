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
    }
    @IBAction func button2Pressed() {
        // log 120
    }
    @IBAction func button3Pressed() {
        // log 400
    }
    @IBAction func button4Pressed() {
        // log 500
        
        
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.sendMessage(["Message":10], replyHandler: {(recvMessage : [String:AnyObject]) -> Void in
                print(String(recvMessage["TotalCount"]))
                print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
                }, errorHandler: nil)
        }

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

}
