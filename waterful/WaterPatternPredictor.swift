//
//  WaterPatternPredictor.swift
//  waterful
//
//  Created by 차정민 on 2015. 11. 7..
//  Copyright © 2015년 suz. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class WaterPatternPredictor {

    var waterPatterns: [WaterPattern]?

    // make water log patterns from core data framework
    func composePatterns() {

        waterPatterns = [WaterPattern]()

        for index in 1...7 {
            let (startDate, objects) = getWaterLogsInCoreData(index)
            let pattern = WaterPattern()
            pattern.composeDataPoints(startDate!, waterLogs: objects as! [WaterLog])
            waterPatterns?.append(pattern)
        }
    }

    func predictPattern() {

        // Key: index (hour),
        // Value: averaged value of water intake in the hour of 7-days
        var dataPoints = [Int: Double]()

        if let patterns = waterPatterns {

            // for every hour
            for hour in 0...23 {
                var total: Double = 0
                // for every day pattern (7 days in the week)
                for day in 0...(patterns.count-1) {
                    total += patterns[day].getDataPoint(hour)
                }
                dataPoints[hour] = total / Double(patterns.count)
            }

            let sortByValue = {
                (elem1:(key: Int, val: Double), elem2:(key: Int, val: Double))->Bool in
                if elem1.val > elem2.val {
                    return true
                } else {
                    return false
                }
            }
            let sortedDataPoints = dataPoints.sort(sortByValue)
            print("best intake: \(sortedDataPoints[0].1)")
        }
    }

    func closestMidNight() -> NSDate {

        let now = NSDate()
        let gregorian = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let weekdayComponents = gregorian!.components([.Hour, .Minute, .Second], fromDate: now)

        // hour, minute, second of current date
        let hour = weekdayComponents.hour
        let minute = weekdayComponents.minute
        let second = weekdayComponents.second

        // difference between now and latest tonight
        let diff = hour * 3600 + minute * 60 + second

        return now.dateByAddingTimeInterval(Double(-diff))
    }

    // Returns CoreData WaterLog objects in latest week
    func getWaterLogsInCoreData(daysAgo: Int) -> (startDate: NSDate?, waterLogs: [AnyObject]?) {

        let midNight = NSDate(timeIntervalSinceNow: NSTimeInterval(NSTimeZone.defaultTimeZone().secondsFromGMT))

        // Set one day to 86,400 seconds
        let day: Double = 86_400

        // managed object context instance
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        // "StepDate" entity in core data model
        let entityDescription = NSEntityDescription.entityForName("WaterLog", inManagedObjectContext: managedObjectContext)
        let request = NSFetchRequest()

        let startDay = midNight.dateByAddingTimeInterval(-day * Double(daysAgo))  // "daysAgo" days ago
        let endDay = midNight.dateByAddingTimeInterval(-day * Double(daysAgo-1))  // 1 day after start day

        let startDayPred = NSPredicate(format: "(loggedTime > %@)", startDay)
        let endDayPred = NSPredicate(format: "(loggedTime < %@)", endDay)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startDayPred, endDayPred])

        request.entity = entityDescription
        request.predicate = predicate

        // Query results to return
        var results: [AnyObject]? = nil
        do {
            results = try managedObjectContext.executeFetchRequest(request)
        } catch {
            print("Fetch Request Error.")
            return (nil, nil)
        }
        return (startDay, results)
    }
}
