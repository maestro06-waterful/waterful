//
//  ExtensionDelegate.swift
//  waterful_watch Extension
//
//  Created by suz on 10/9/15.
//  Copyright © 2015 suz. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}


extension Double {
    var ml_to_oz : Double { return self * 0.033814 } // from ml to oz
    var oz_to_ml : Double { return self / 0.033814 } // from oz to ml
    var toString : String {
        // if 1.01 -> return 1.
        // if 1.11 -> return 1.1
        if floor(self) == (floor(10*self))/10 {
            return String(format: "%0.f", self)
        }
        else {
            return String(format: "%0.1f", self)
        }
    }
}
