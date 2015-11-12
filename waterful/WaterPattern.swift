//
//  WaterPattern.swift
//  waterful
//
//  Created by 차정민 on 2015. 11. 7..
//  Copyright © 2015년 suz. All rights reserved.
//

import Foundation

// The instance has 24 sections which mean water intakes in an hour
// It is considered as a time-series which has data points of water intakes.
class WaterPattern {

    // Each data point means water intake in an hour
    var dataPoints: [Double]
    var startDate: NSDate?

    init() {
        dataPoints = [Double](count: 24, repeatedValue: 0.0)
    }

    // startDate: start date in the day
    // waterLogs: WaterLog instances in the day
    func composeDataPoints(startDate: NSDate, waterLogs: [WaterLog]) {
        self.startDate = startDate

        // for every hour section
        for hour in 0...23 {
            var totalAmount: Double = 0

            let sectStartDate = startDate.dateByAddingTimeInterval(Double(3_600 * hour))
            let sectEndDate = sectStartDate.dateByAddingTimeInterval(Double(3_600))

            // for WaterLog instance in this hour section
            for elem in waterLogs {
                // Case: sectStartDate < elem.loggedTime < sectEndDate
                if elem.loggedTime?.compare(sectStartDate) == NSComparisonResult.OrderedDescending &&
                    elem.loggedTime?.compare(sectEndDate) == NSComparisonResult.OrderedAscending {
                        totalAmount += Double(elem.amount!)
                }
            }
            dataPoints[hour] = totalAmount
//            print("hour: \(hour): total amount: \(totalAmount)")
        }
    }

    func getDataPoint(index: Int) -> Double {
        if index < dataPoints.count {
            return dataPoints[index]
        } else {
            return 0.0
        }
    }
}
