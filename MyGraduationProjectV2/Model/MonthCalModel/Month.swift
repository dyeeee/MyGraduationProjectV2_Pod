//
//  Month.swift
//  CalSwiftUI
//
//  Created by Adam Kes on 11/12/19.
//  Copyright © 2019 KesDev. All rights reserved.
//

import Foundation

@available(OSX 10.15, *)
@available(iOS 13.0, *)
struct Month {

    private let calendar = Calendar.current

    var startDate: Date
    var selectableDays: Bool = false
    var today = Date()
    
    var monthNameYear: String {
        self.monthHeader()
    }
    
    var monthDays: [Int: [Day]] {
        return self.daysArray()
    }
    
    var monthRows: Int {
        self.rows()
    }

    var monthString:String {
        startDate.dateToString(format: "yyyyMM")
    }
    

    private func monthHeader() -> String {
        let components = calendar.dateComponents([.year, .month], from: startDate)
        let currentMonth = calendar.date(from: components)!
        return currentMonth.dateToString(format: "yyyy LLLL")
    }

    private func dateToString(date: Date, format: String) -> String {
        let dateFormat = DateFormatter.init()
        dateFormat.dateFormat = format
        let dateString = dateFormat.string(from: date)
        return dateString
    }

    private func firstOfMonth() -> Date {
        let components = calendar.dateComponents([.year, .month], from: startDate)
        let firstOfMonth = calendar.date(from: components)!
        return firstOfMonth
    }

    private func lastOfMonth() -> Date {
        var components = DateComponents()
        components.month = 1
        components.day = -1
        let lastOfMonth = calendar.date(byAdding: components, to: firstOfMonth())!
        return lastOfMonth
    }

    private func dateToWeekday(date: Date) -> Int {
        /// 返回日期对应的weekday，星期天为1，星期六为7
        let components = calendar.dateComponents([.weekday], from: date)
        guard let weekday = components.weekday else {
            fatalError("Cannot convert weekday to Int")
        }
        return weekday
    }

    private func rows() -> Int {
        let columns = monthDays.count
        var rowCount = 1
        for col in 1...columns {
            if monthDays[col]!.count > rowCount
            {
                rowCount = monthDays[col]!.count
            }
        }
        return rowCount
    }

    
    private func daysArray() -> [Int: [Day]] {
        var arrayOfDays = [
            1: [Day](),
            2: [Day](),
            3: [Day](),
            4: [Day](),
            5: [Day](),
            6: [Day](),
            7: [Day]()
        ]
        let fom = firstOfMonth() //本月第一天Date
        let lom = lastOfMonth()  //本月最后一天Date
        var currentDate = fom

        while (fom <= currentDate && currentDate <= lom) {
            //循环每一天创建每个Day实例
            let weekday = dateToWeekday(date: currentDate) //第几天
            let disabled = currentDate > today ? true : false //大于today则灰色
            
            let currentDateInt = Int(currentDate.dateToString(format: "MMdyy"))!
            let todayDateInt = Int(today.dateToString(format: "MMdyy"))! //011521
            let isToday = currentDateInt == todayDateInt ? true : false
            
            let currentDay = Day(date: currentDate, today: isToday, disable: disabled, selectable: selectableDays)
            
            arrayOfDays[weekday]?.append(currentDay)

            // 填充第一天之前的空位
            if fom == currentDate {
                var startDay = weekday - 1
                while startDay > 0 {
                    arrayOfDays[startDay]?.append(Day(date: Date(timeIntervalSince1970: 0)))
                    startDay -= 1
                }
            }

            // 填充最后一天之后的空位
            if lom == currentDate {
                var endDay = weekday + 1
                while endDay <= 7 {
                    arrayOfDays[endDay]?.append(Day(date: Date(timeIntervalSince1970: 0)))
                    endDay += 1
                }
            }

            //Increment date
            var components = calendar.dateComponents([.day], from: currentDate)
            components.day = +1
            // 在currentDate上加一天
            currentDate = calendar.date(byAdding: components, to: currentDate)!
        }

        return arrayOfDays
    }


}
