//
//  MonthView.swift
//  CalSwiftUI
//
//  Created by Adam Kes on 11/12/19.
//  Copyright © 2019 KesDev. All rights reserved.
//

import SwiftUI

@available(OSX 10.15, *)
@available(iOS 13.0, *)
struct MonthView: View {
    @ObservedObject var dayContentVM:DayContentViewModel
    @State var isCurrentMonth:Bool = false
    
    var month: Month
    
    var body: some View {
        VStack(alignment:.center,spacing:3) {
            HStack {
//                Button(action: {
//                    self.dayContentVM.getAllDayContentItems()
//                }, label: {
//                    Image(systemName: "arrow.triangle.2.circlepath")
//                }).buttonStyle(BorderlessButtonStyle())
//
                
                Text("\(month.monthNameYear)")
                    .font(.custom("Baskerville", size: CGFloat(18),relativeTo: .title))
                //                    .onTapGesture {
                //                        self.dayContentViewModel.getAllItems(monthString: month.monthString)
                //                }
                Spacer()
                
            }
            //.padding(.trailing,20)

            if isCurrentMonth{
                WeekdaysView()
            }
            
            VStack {
                
                GridStack(rows: month.monthRows, columns: month.monthDays.count) {
                    row, col in
                    if self.month.monthDays[col+1]![row].dayDate == Date(timeIntervalSince1970: 0)
                    {
                        Text("").frame(width: 10, height: 10)
                    }
                    else if
                        (self.dayContentVM.dateStringList.contains( self.month.monthDays[col+1]![row].dateString))
                    { // 如果这一天是有coredata保存的内容的，显示打卡状态
                        DayCellView(day: self.month.monthDays[col+1]![row],done:true,animate:true)
                    }
                    else {
                        DayCellView(day: self.month.monthDays[col+1]![row])
                        //                            .onTapGesture{
                        //                                print("ok")
                        //                            }
                    }
                    
                }
            }
        }
        //        .onAppear(perform: {
        //            self.dayContentViewModel.getAllItems()
        //        })
        
        
    }
    
    
    
}
@available(OSX 10.15, *)
@available(iOS 13.0, *)
struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(dayContentVM: DayContentViewModel(),isCurrentMonth: true, month: Month(startDate: Date(), selectableDays: true))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
