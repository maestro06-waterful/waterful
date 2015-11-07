//
//  NotificationManager.swift
//  waterful
//
//  Created by HONGYOONSEOK on 2015. 10. 27..
//  Copyright © 2015년 suz. All rights reserved.
//

import Foundation
import UIKit

class NotiInfo : NSObject, NSCoding {

    enum notiActionCategoryId : String {
        case SIMPLE = "Simple"
        case WATERLOG = "waterlogCategory"
        
    }
    
    var name = ""
    var details = ""
    var time: NSDate?
    
    override init() {
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.name = aDecoder.decodeObjectForKey("nameKey") as! String
        self.details = aDecoder.decodeObjectForKey("detailsKey") as! String
        self.time = aDecoder.decodeObjectForKey("timeKey") as? NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "nameKey")
        aCoder.encodeObject(self.details, forKey: "detailsKey")
        aCoder.encodeObject(self.time, forKey: "timeKey")
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
    var notiBuilder = NotiBuilder()
    
    enum notiActionIdentifier :String{
        case WaterLog1 = "waterlog1"
        case WaterLog2 = "waterLog2"
        case Snooze = "snooze"
    }
    

    enum NotiCategory : String {
        case WATERLOG = "waterlogCategory"
    }
    
    enum SmartNotiType : String{
        case MORNING = "MOR"
        case MORNING_HOT = "MOR_HOT"
        case WORKOUT = "WORK"
    }
    
    enum RecordNotiType : String{
        case REMIND = "REMIND"
    }
    
    enum ArchieveNotiType : String{
        case TODAY = "AN_TODAY"
    }
    
    func registerSmartNoti(notiType : SmartNotiType){
        
        let localNotification : UILocalNotification = notiBuilder.buildLocalNotification(
            NotiBuilder.NotiType.SMART_NOTI, notiDetail: notiType.rawValue,
            fireTime: NSDate().dateByAddingTimeInterval(5))
        
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification) // Scheduling the notification.
    }
    
    func registerRecordNoti(notiType : RecordNotiType){
        
        let localNotification : UILocalNotification = notiBuilder.buildLocalNotification(
            NotiBuilder.NotiType.RECORD_NOTI, notiDetail: notiType.rawValue,
            fireTime: NSDate().dateByAddingTimeInterval(5))
        
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification) // Scheduling the notification.
    }
    
    func registerArchieveNoti(notiType : ArchieveNotiType){
        
        let localNotification : UILocalNotification = notiBuilder.buildLocalNotification(
            NotiBuilder.NotiType.ARCHIEVE_NOTI, notiDetail: notiType.rawValue,
            fireTime: NSDate().dateByAddingTimeInterval(5))
        
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification) // Scheduling the notification.
    }
    
    private func applicationDidEnterBackground(){
        let archivedReminderList = NSKeyedArchiver.archivedDataWithRootObject(self.notiList)
        NSUserDefaults.standardUserDefaults().setObject(archivedReminderList, forKey: "reminderList")
    }
    
    private func applicatoinWillFinishLauncing(){
        if let aList: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("reminderList") {
            let unArchivedList: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(aList as! NSData)
            self.notiList = unArchivedList as! Array
        }
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
        waterlogCategory.identifier = NotiCategory.WATERLOG.rawValue
        
        waterlogCategory.setActions([notiActionWaterLog1, notiActionWaterLog2, reminderActionSnooze ], forContext: UIUserNotificationActionContext.Default)
        waterlogCategory.setActions([notiActionWaterLog1, reminderActionSnooze], forContext: UIUserNotificationActionContext.Minimal)
        
        // Register for notification: This will prompt for the user's consent to receive notifications from this app.
        let notificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound] , categories: Set(arrayLiteral: waterlogCategory))
        //*NOTE*
        // Registering UIUserNotificationSettings more than once results in previous settings being overwritten.
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    func scheduleLocalNotification() {
        registerSmartNoti(NotiManager.SmartNotiType.MORNING)
    }
    
}
