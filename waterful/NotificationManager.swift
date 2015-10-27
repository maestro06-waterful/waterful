//
//  NotificationManager.swift
//  waterful
//
//  Created by HONGYOONSEOK on 2015. 10. 27..
//  Copyright © 2015년 suz. All rights reserved.
//

import Foundation
import UIKit

class NotiInfo {

    enum notiActionCategoryId : String {
        case SIMPLE = "Simple"
        case WATERLOG = "waterlogCategory"
    }
    
    var title :String = ""
    var details: String = ""
    var time : NSDate?
    
    init(){
        
    }
    
}

class NotiManager {
    
    static var sharedInstance : NotiManager? = NotiManager()
    
//    func getNewInstance () -> NotiManager{
//        return NotiManager()
//    }
    
    init(){
        
    }
    
    var notiList: Array<NotiInfo> = []
    
    enum notiActionIdentifier :String{
        case WaterLog1 = "waterlog1"
        case WaterLog2 = "waterLog2"
        case Snooze = "snooze"
    }
    
    func registerForActionableNotification() {
        registerForActionableNotificationWaterLog()
//        registerSimapleNotification()
        
    }
    
    func registerSimapleNotification(){
        let notificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound, UIUserNotificationType.Badge] , categories: nil)
        //*NOTE*
        // Registering UIUserNotificationSettings more than once results in previous settings being overwritten.
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    private func registerForActionableNotificationWaterLog(){
        
        let notiActionWaterLog1 = UIMutableUserNotificationAction()
        notiActionWaterLog1.identifier = notiActionIdentifier.WaterLog1.rawValue
        notiActionWaterLog1.title = "종이컵 한 잔"
        notiActionWaterLog1.activationMode = UIUserNotificationActivationMode.Background
        notiActionWaterLog1.destructive = false; // 빨간 버튼
        notiActionWaterLog1.authenticationRequired = false
        
        let notiActionWaterLog2 = UIMutableUserNotificationAction()
        notiActionWaterLog2.identifier = notiActionIdentifier.WaterLog2.rawValue
        notiActionWaterLog2.title = "페트병 하나"
        notiActionWaterLog2.activationMode = UIUserNotificationActivationMode.Background
        notiActionWaterLog2.destructive = false; // 빨간 버튼
        notiActionWaterLog2.authenticationRequired = false
        
        
        let reminderActionSnooze = UIMutableUserNotificationAction()
        reminderActionSnooze.identifier = notiActionIdentifier.Snooze.rawValue
        reminderActionSnooze.title = "Snooze"
        reminderActionSnooze.activationMode = UIUserNotificationActivationMode.Background
        reminderActionSnooze.destructive = true
        reminderActionSnooze.authenticationRequired = false
        
        let waterlogCategory = UIMutableUserNotificationCategory()
        waterlogCategory.identifier = "waterlogCategory"
        
        waterlogCategory.setActions([notiActionWaterLog1, notiActionWaterLog2, reminderActionSnooze ], forContext: UIUserNotificationActionContext.Default)
        waterlogCategory.setActions([notiActionWaterLog1, notiActionWaterLog2,reminderActionSnooze], forContext: UIUserNotificationActionContext.Minimal)
        
        // Register for notification: This will prompt for the user's consent to receive notifications from this app.
        let notificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound] , categories: Set(arrayLiteral: waterlogCategory))
        //*NOTE*
        // Registering UIUserNotificationSettings more than once results in previous settings being overwritten.
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    func scheduleLocalNotification() {
        
        // Create reminder by setting a local notification
        let localNotification = UILocalNotification() // Creating an instance of the notification.
        localNotification.alertTitle = "Notification Title"
        localNotification.alertBody = "Alert body to provide more details"
        localNotification.alertAction = "ShowDetails"
//        localNotification.fireDate = NSDate().dateByAddingTimeInterval(60*5) // 5 minutes(60 sec * 5) from now
        localNotification.fireDate = NSDate().dateByAddingTimeInterval(5)
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.soundName = UILocalNotificationDefaultSoundName // Use the default notification tone/ specify a file in the application bundle
        localNotification.applicationIconBadgeNumber = 1 // Badge number to set on the application Icon.
        localNotification.category = "waterlogCategory" // Category to use the specified actions
//        localNotification.category = "reminderCategory" // Category to use the specified actions
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification) // Scheduling the notification.
    }
    
}
