//
//  HistoryCalendarView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/18.
//

import SwiftUI

struct HistoryCalendarView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var screenWidth_sheet = UIScreen.main.bounds.width
    @State var orientation = UIDevice.current.orientation
    
    var startDate: Date {
        let dateFormat = DateFormatter.init()
        dateFormat.dateFormat = "yyyyMMdd"
        let date:Date = dateFormat.date(from: "20210501") ?? Date()
        return date
    }
    var monthsToDisplay: Int {
        let dateFormat = DateFormatter.init()
        dateFormat.dateFormat = "yyyyMMdd"
        let date:Date = dateFormat.date(from: "20210501") ?? Date()
        let months:Int = date.monthsBetweenDate(toDate: Date())+1
        return months
    }
    
    @StateObject var dayContentVM:DayContentViewModel
    
    @State var dateString = ""
    @Binding var isLoading:Bool
    
    var body: some View {
        NavigationView {
            ScrollViewReader { reader in
                VStack {
                    VStack {
                        HStack{
                            TextField("yyyyMMdd", text: $dateString)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: {
                                self.dayContentVM.createItem(dateString: dateString)
                            }, label: {
                                Text("补打卡")
                            })
//                            Button(action: {
//                                self.dayContentVM.deleteAllDayContentItem()
//                            }, label: {
//                                Text("DeleteAll")
//                            })
                        }
                        
                        if (Device.deviceType == .iPad && (orientation.isLandscape)){
                            WeekdaysView(screenWidth: .constant(UIScreen.main.bounds.width*0.6)).padding(.bottom, -10)
                        }else if (Device.deviceType == .iPad && (orientation.isPortrait)){
                            WeekdaysView(screenWidth: .constant(UIScreen.main.bounds.width*0.8)).padding(.bottom, -10)
                        }else{
                            WeekdaysView(screenWidth: .constant(screenWidth_sheet)).padding(.bottom, -10)
                        }
                    }
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(0..<self.monthsToDisplay) {
                                num in
                                
//                                MonthView(dayContentVM:self.dayContentVM, screenWidth: $screenWidth_sheet, month: Month(startDate: self.nextMonth(currentMonth: self.startDate, add: num), selectableDays: true))
//                                    .id(Int(num+1))
                                
                                if (Device.deviceType == .iPad && (orientation.isLandscape)){
                                    MonthView(dayContentVM:self.dayContentVM, screenWidth: .constant(UIScreen.main.bounds.width*0.6), month: Month(startDate: self.nextMonth(currentMonth: self.startDate, add: num), selectableDays: true))
                                        .id(Int(num+1))
                                }else if (Device.deviceType == .iPad && (orientation.isPortrait)){
                                    MonthView(dayContentVM:self.dayContentVM, screenWidth: .constant(UIScreen.main.bounds.width*0.8), month: Month(startDate: self.nextMonth(currentMonth: self.startDate, add: num), selectableDays: true))
                                        .id(Int(num+1))
                                }else{
                                    MonthView(dayContentVM:self.dayContentVM, screenWidth: $screenWidth_sheet, month: Month(startDate: self.nextMonth(currentMonth: self.startDate, add: num), selectableDays: true))
                                        .id(Int(num+1))
                                }
                            }
                        }
                        
                    }
                }.navigationBarTitle("History")
                .navigationBarTitleDisplayMode(.inline)
                .padding(.all, 20)
                .onAppear(perform: {
                    //self.dayContentViewModel.getAllItems()
                    withAnimation{
                        reader.scrollTo(self.monthsToDisplay)
                    }
                })
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu{
                            Button(action: {
                                self.dayContentVM.deleteAllDayContentItem()
                            }) {
                                Label("删除全部", systemImage: "trash.fill")
                            }
                            Button(action: {
                                self.dayContentVM.createTestItem()
                            }) {
                                Label("创建测试数据", systemImage: "plus.rectangle.on.rectangle")
                            }
                            Button(action: {
                                let tmpString = Date().dateToString(format:"yyyyMMdd")
                                self.dayContentVM.createItem(dateString: tmpString)
                            }) {
                                Label("创建当日数据", systemImage: "plus.viewfinder")
                            }
                            Button(action: {
                                
                            }) {
                                Label("上传本地数据", systemImage: "icloud.and.arrow.up")
                            }
                            Button(action: {
                                
                            }) {
                                Label("下载云端数据", systemImage: "icloud.and.arrow.down")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title3)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName:"xmark.circle")
                                .font(.title3)
                        }
                    }
                }
            }.background(Color(.systemGray6).ignoresSafeArea())
        }
        .onReceive(NotificationCenter.Publisher(center: .default, name: UIDevice.orientationDidChangeNotification)) { _ in
            if UIDevice.current.orientation != UIDeviceOrientation(rawValue: 5){
                //print("旋转") 有执行到
                self.orientation = UIDevice.current.orientation
            }
        }
        .onAppear(perform: {
            //DispatchQueue.main.async {
            //self.isLoading = false
            if UIDevice.current.orientation != UIDeviceOrientation(rawValue: 0){
                orientation = UIDevice.current.orientation
            }
            dayContentVM.isLoading = false
            print("完成历史日历页面加载")
            //            if(Device.deviceType == .iPad && (orientation.isPortrait)){
            //                print("0.8")
            //                screenWidth_sheet = screenWidth_sheet * 0.8
            //            }
            //            else if (Device.deviceType == .iPad && (orientation.isLandscape)){
            //                print("0.6")
            //                screenWidth_sheet = screenWidth_sheet * 0.6
            //            }else{
            //                print("else")
            //                screenWidth_sheet = screenWidth_sheet * 0.6
            //            }
            if(Device.deviceType == .iPad){
                screenWidth_sheet = screenWidth_sheet * 0.6
            }else if(Device.deviceType == .Mac){
                screenWidth_sheet = screenWidth_sheet * 0.3
            }
            
        })
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

struct HistoryCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryCalendarView(dayContentVM: DayContentViewModel(), isLoading: .constant(false))
    }
}
