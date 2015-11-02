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
            "좋은 아침이예요~ 하루의 시작을 한 잔의 물과 함께 시작하는 건 어떨까요?2"
        ],
        "SN_MOR_HOT" :  [
            "오늘의 더운 날씨",
            "오늘은 더워... 개더워... 물 마셩...",
            "40도 이상"
        ],
        "SN_WORK" :     [
            "오늘의 더운 날씨", "오늘은 더워...", "40도 이상"
        ],
        "RN_REMIND" :          [
            "어제 00시에 물을 드셨군요. 그런데 오늘은 드시지 않으셨어요. 혹시 잊으신거면 얼른 기록해주세요"
        ],
        "AN_TODAY" : [
            "오늘은 어제보다 00만큼 물을 덜 마셨고, 1주일 통계보다 00 만큼 마시지 못했군요. 자기 전 까지 00 만큼 물을 마셔보는건 어떤가요?"
        ],
        
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

            
            localNotification.alertTitle = notiTitles[key]
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
        
        let randomVal : Int = random()
        let randomN : Int = randomVal % (bodyContentArr.count)
        
        return bodyContentArr[randomN]
    }
    
    
}