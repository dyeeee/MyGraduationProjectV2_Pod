//
//  Weekdays.swift
//  CalSwiftUI
//
//  Created by Adam Kes on 11/13/19.
//  Copyright © 2019 KesDev. All rights reserved.
//

import SwiftUI

@available(OSX 10.15, *)
@available(iOS 13.0, *)
struct WeekdaysView: View {
    let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    let weekdays2 = ["Sun", "Mon", "Tue", "Wen", "Thu", "Fri", "Sat"]

    var body: some View {
        HStack {
            GridStack(rows: 1, columns: 7) { row, col in
                Text(self.weekdays[col])
                    .font(.caption)
                    .foregroundColor(Color(.systemGray))
            }
        }.foregroundColor(Color(.systemGray))
        //.padding(.bottom, 20).background(colors.weekdayBackgroundColor)
    }
}

@available(OSX 10.15, *)
@available(iOS 13.0, *)
struct WeekdaysView_Previews: PreviewProvider {
    static var previews: some View {
        WeekdaysView()
    }
}
