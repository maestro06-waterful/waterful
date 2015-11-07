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
    
    private let fireTimeInterval = 600
    
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
        case TODAY = "TODAY"
    }
    
    func registerSmartNoti(notiType : SmartNotiType, fireDate : NSDate){
        notiSettingSimple()
        
        let localNotification : UILocalNotification = notiBuilder.buildLocalNotification(
            NotiBuilder.NotiType.SMART_NOTI, notiDetail: notiType.rawValue,
            fireTime: fireDate)
        
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification) // Scheduling the notification.
    }
    
    func registerRecordNoti(notiType : RecordNotiType, fireDate : NSDate){
        notiSettingActionable()
        
        let localNotification : UILocalNotification = notiBuilder.buildLocalNotification(
            NotiBuilder.NotiType.RECORD_NOTI, notiDetail: notiType.rawValue,
            fireTime: fireDate)
        
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification) // Scheduling the notification.
    }
    
    func registerArchieveNoti(notiType : ArchieveNotiType, fireDate : NSDate){
        notiSettingSimple()
        
        let localNotification : UILocalNotification = notiBuilder.buildLocalNotification(
            NotiBuilder.NotiType.ARCHIEVE_NOTI, notiDetail: notiType.rawValue,
            fireTime: fireDate)
        
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification) // Scheduling the notification.
    }
    
    func cancelNoti(fireTime : NSDate) {
        let notifications : [UILocalNotification] = getScheduledNoti(fireTime)
        for noti in notifications {
            UIApplication.sharedApplication().cancelLocalNotification(noti)
        }

    }
    
    func cancelNoti(notiType : NotiBuilder.NotiType){
        let notifications : [UILocalNotification] = getScheduledNoti(notiType)
        for noti in notifications {
            UIApplication.sharedApplication().cancelLocalNotification(noti)
        }
    }
    
    func cancelAllNoti(){
        let notifications : [UILocalNotification] = getScheduledNoti()
        if notifications.count > 0 {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
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
    
    private func notiSettingActionable(){
        
        let notiAction = notiBuilder.buildMutableUserNotificationAction()
        
        let waterlogCategory = UIMutableUserNotificationCategory()
        waterlogCategory.identifier = NotiCategory.WATERLOG.rawValue
        
        waterlogCategory.setActions([notiAction!.log1NotiAction, notiAction!.log2NotiAction, notiAction!.snoozeNotiAction ], forContext: UIUserNotificationActionContext.Default)
        waterlogCategory.setActions([notiAction!.log1NotiAction, notiAction!.snoozeNotiAction], forContext: UIUserNotificationActionContext.Minimal)
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound] , categories: Set(arrayLiteral: waterlogCategory))

        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    private func notiSettingSimple(){
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound] , categories: nil)

        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    private func getScheduledNoti() -> [UILocalNotification] {
        let app = UIApplication.sharedApplication()
        return app.scheduledLocalNotifications!
    }
    
    private func getScheduledNoti(fireTime : NSDate) -> [UILocalNotification]{
        let app = UIApplication.sharedApplication()
        let notifications = app.scheduledLocalNotifications
        
        var returnNoti : [UILocalNotification] = []
//        var currentDate : NSDate = NSDate()
        
        if let counts = notifications?.count{
            for noti in notifications!{
                let fireTimeNoti : NSDate = noti.fireDate!

                let timeValueInteval : NSTimeInterval = fireTime.timeIntervalSinceNow
                let timeNotiInterval : NSTimeInterval = fireTimeNoti.timeIntervalSinceNow
                
                let interval : Double = Double(timeValueInteval.description)!
                let interval2 : Double = Double(timeNotiInterval.description)!
                
                if abs(Int(interval - interval2)) < fireTimeInterval {
                    returnNoti.append(noti)
                }
            }
            
        }
        
        return returnNoti
        
    }
    
    private func getScheduledNoti(notiType : NotiBuilder.NotiType) -> [UILocalNotification]{
        let app = UIApplication.sharedApplication()
        let notifications = app.scheduledLocalNotifications
        
        var returnNoti : [UILocalNotification] = []
        //        var currentDate : NSDate = NSDate()
        
        if let counts = notifications?.count{
            for noti in notifications!{
                
                let title = noti.alertTitle
                print(title! + "" + notiType.rawValue)
                
                if notiType.rawValue == title {
                    returnNoti.append(noti)
                }
            }
            
        }
        
        return returnNoti
        
    }
}
