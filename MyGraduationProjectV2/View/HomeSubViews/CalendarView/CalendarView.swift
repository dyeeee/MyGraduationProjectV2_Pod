//
//  CalendarView.swift
//  CalSwiftUI
//
//  Created by Adam Kes on 11/13/19.
//  Copyright © 2019 KesDev. All rights reserved.
//

import SwiftUI

@available(OSX 10.15, *)
@available(iOS 13.0, *)
public struct CalendarView: View {


    @State var startDate: Date = Date()
    @State var monthsToDisplay: Int = 2
    @State var selectableDays = true
	
    @State var dateString = "20210116"


    public var body: some View {
        VStack {
            VStack {
                HStack{
                    TextField("yyyyMMdd", text: $dateString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        DayContentViewModel().createItem(dateString: dateString)
                    }, label: {
                        Text("Add")
                    })
                }
                WeekdaysView()
            }
            ScrollView {
                    ForEach(0..<self.monthsToDisplay) {
                        num in
                        MonthView(dayContentVM: DayContentViewModel(), month: Month(startDate: self.nextMonth(currentMonth: self.startDate, add: num), selectableDays: self.selectableDays))
                    }

            }
        }
    }

    func nextMonth(currentMonth: Date, add: Int) -> Date {
        var components = DateComponents()
        components.month = add
        let next = Calendar.current.date(byAdding: components, to: currentMonth)!
        return next
    }
    
    func nextMonthString(currentMonth: Date, add: Int) -> String {
        var components = DateComponents()
        components.month = add
        let next = Calendar.current.date(byAdding: components, to: currentMonth)!
        return next.dateToString(format: "yyyyMM")
    }


}

@available(OSX 10.15, *)
@available(iOS 13.0, *)
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
