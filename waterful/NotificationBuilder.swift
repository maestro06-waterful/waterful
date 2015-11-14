//
//  NotificationBuilder.swift
//  waterful
//
//  Created by HONGYOONSEOK on 2015. 11. 2..
//  Copyright © 2015년 suz. All rights reserved.
//

import Foundation
import UIKit


class NotiBuilder{
    private let smartNoti = [
        "SN_MOR":  [
            "좋은 아침이예요~ 하루의 시작을 한 잔의 물과 함께 시작하는 건 어떨까요?",
            "%@ 님, 안녕하세요! 오늘도 즐거운 하루 되세요~",
            "%@ 님, 안녕하세요. 오늘 하루도 Waterful과 함께 즐겁고 활기찬 하루 되세요.",
            "아침에 물 한잔은 보약이라고 하잖아요! 오늘 하루 시작은 물과 함께 시작하세요~",
            "아침에 물을 마시면, 자는 동안에 쌓인 노폐물이 청소된데요, 그럼 가벼운 하루가 될 수 있지 안을까요?",
            "아침에 일어나서 물을 마시는 습관이 살이 빠지게 해준다네요. 오늘부터 Waterful과 함께 물 마셔요!",
            "기분 좋은 아침이네요^^. 좋은 사람들과 좋은 음식드시고 좋은 일만 가득 생기는 좋은 하루가 되기를 바랄게요!"
        ],
        "SN_MOR_HOT" :  [
            "오늘은 날씨가 40도 이상이네요. 더운 날 일 수록 물을 많이 마실 필요가 있어요!~"
        ],
        "SN_WORK" :     [
            "운동을 열심히 하셨군요! 운동 후 개운하게 물 한 잔 마시는 것은 어떨까요?"
        ],
        "RN_REMIND" :   [
            "어제 %d시에 물을 드셨군요. 그런데 오늘은 드시지 않으셨어요. 혹시 잊으신거면 얼른 기록해주세요"
        ],
        "AN_TODAY" : [
            "오늘은 어제보다 00만큼 물을 덜 마셨고, 1주일 통계보다 00 만큼 마시지 못했군요. 자기 전 까지 00 만큼 물을 마셔보는건 어떤가요?"
        ],
        "AN_WEEK" : [
            "지난 주, 총 %d 번 물 마시기 운동을 성취하였네요. 이번주는 일주일 내내 성공을 위해 노력해봐요!",
            "지난 주, 총 %d 번 물 마시기 운동을 성취하였네요. 이번주는 일주일 내내 성공을 위해 노력해봐요!"
        ]
        
    ]

    
    private let notiTitles = ["SN" : "개인화 자동 알람", "RN" : "기록을 위한 알람" , "AN": "오늘의 성취도 알람"]
    
    
    enum NotiType : String {
        case SMART_NOTI = "SN"
        case RECORD_NOTI = "RN"
        case ARCHIEVE_NOTI = "AN"
    }
    
    
    func buildLocalNotification(notiType : NotiType, notiDetail : String?, fireTime : NSDate) -> UILocalNotification{
        
        let localNotification = UILocalNotification()
        
        if let key = notiDetail {

            
            localNotification.alertTitle = notiType.rawValue
//            localNotification.alertBody = smartNoti[notiKey]
            localNotification.alertBody = getRandomContents(notiType, notiKey: key)
//            localNotification.alertAction = "ShowDetails"

            localNotification.fireDate = fireTime
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.soundName = UILocalNotificationDefaultSoundName // Use the default notification tone/ specify a file in the application bundle
            localNotification.applicationIconBadgeNumber = 1 // Badge number to set on the application Icon.
            
            localNotification.category = NotiManager.NotiCategory.WATERLOG.rawValue  // Category to use the specified actions

        }
        
        return localNotification
    }
    
    private func getRandomContents(notiType : NotiType, notiKey : String) -> String {
        let notiBodyKey : String = notiType.rawValue + "_" + notiKey
        
        let bodyContentArr : Array<String> = smartNoti[notiBodyKey]!
        
        let randomValue: UInt32 = arc4random_uniform(UInt32(bodyContentArr.count))
        
        if(notiType == .ARCHIEVE_NOTI || notiType == .RECORD_NOTI || notiType == .SMART_NOTI){
            let contentString = NSLocalizedString(bodyContentArr[Int(randomValue)], comment: "Smart Notification Localization")
            //            String(format: <#T##String#>, arguments: <#T##[CVarArgType]#>)
            return String(format : contentString, arguments : ["홍윤석"])
        }
        else if(notiType == .ARCHIEVE_NOTI ){
            let contentString = NSLocalizedString(bodyContentArr[Int(randomValue)], comment: "Archieve Notification Localization")
            return String(format : contentString, argument : [10])
        }
        else if(notiType == .RECORD_NOTI){
            //            return bodyContentArr[Int(randomValue)]
            let contentString = NSLocalizedString(bodyContentArr[Int(randomValue)], comment: "Record Notification Localization")
            return String(format : contentString, argument : [10])
        }
        
        return ""
    }
    
    func buildMutableUserNotificationAction() -> (log1NotiAction : UIMutableUserNotificationAction, log2NotiAction : UIMutableUserNotificationAction, snoozeNotiAction : UIMutableUserNotificationAction)?{
        
        let notiActionWaterLog1 = UIMutableUserNotificationAction()
        notiActionWaterLog1.identifier = NotiManager.notiActionIdentifier.WaterLog1.rawValue
        notiActionWaterLog1.title = "종이컵 한 잔"
        notiActionWaterLog1.activationMode = UIUserNotificationActivationMode.Background
        notiActionWaterLog1.destructive = false; // 빨간 버튼
        notiActionWaterLog1.authenticationRequired = false
        
        let notiActionWaterLog2 = UIMutableUserNotificationAction()
        notiActionWaterLog2.identifier = NotiManager.notiActionIdentifier.WaterLog2.rawValue
        notiActionWaterLog2.title = "페트병 하나"
        notiActionWaterLog2.activationMode = UIUserNotificationActivationMode.Background
        notiActionWaterLog2.destructive = false; // 빨간 버튼
        notiActionWaterLog2.authenticationRequired = false
        
        
        let reminderActionSnooze = UIMutableUserNotificationAction()
        reminderActionSnooze.identifier = NotiManager.notiActionIdentifier.Snooze.rawValue
        reminderActionSnooze.title = "Snooze"
        reminderActionSnooze.activationMode = UIUserNotificationActivationMode.Background
        reminderActionSnooze.destructive = true
        reminderActionSnooze.authenticationRequired = false
        
        return (notiActionWaterLog1, notiActionWaterLog2, reminderActionSnooze)
    }
    
    
}