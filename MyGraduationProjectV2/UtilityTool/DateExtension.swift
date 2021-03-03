//
//  DateExtension.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/1.
//

import Foundation

extension Date {

    func dateToString(format: String) -> String {
        let dateFormat = DateFormatter.init()
        dateFormat.dateFormat = format
        let dateString = dateFormat.string(from: self)
        return dateString
    }
    
    func monthsBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.month], from: self, to: toDate)
        return components.month ?? 0
    }
}


extension String {

    func stringToDate(format: String) -> Date {
        let dateFormat = DateFormatter.init()
        dateFormat.dateFormat = format
        let date = dateFormat.date(from: self)!
        return date
    }

}
