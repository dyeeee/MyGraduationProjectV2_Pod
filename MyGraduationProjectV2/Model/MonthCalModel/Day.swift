//
//  Day.swift
//  CalSwiftUI
//
//  Created by Adam Kes on 11/12/19.
//  Copyright © 2019 KesDev. All rights reserved.
//

import Foundation
import SwiftUI

@available(OSX 10.15, *)
@available(iOS 13.0, *)
class Day: ObservableObject {

    @Published var isSelected = false

    var dateString:String {
        dayDate.dateToString(format: "yyyyMMdd")
    }
    
    
    //var selectableDays: Bool
    var dayDate: Date
    var dayName: String {
        dayDate.dateToString(format: "d")
    }
    var isToday = false
    var disabled = false
//    let colors = Colors()
    var textColor: Color {
        if isSelected {
            return Color(.systemRed)
        } else if isToday {
            return Color(.systemBlue)
        } else if disabled {
            return Color("CalendarOffColor")
        }
        return Color("CalendarOnColor")
    }
    var backgroundColor: Color {
        if isSelected {
            return Color(.systemGreen)
        } else {
            return Color(.clear)
        }
    }

    init(date: Date, today: Bool = false, disable: Bool = false, selectable: Bool = true) {
        dayDate = date
        isToday = today
        disabled = disable
        //selectableDays = selectable
    }

}
