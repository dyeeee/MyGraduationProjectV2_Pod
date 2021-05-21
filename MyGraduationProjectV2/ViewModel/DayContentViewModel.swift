//
//  DayContentViewModel.swift
//  MyCalendar
//
//  Created by YES on 2021/1/16.
//

import Foundation
import CoreData
import SwiftUI


class DayContentViewModel: ObservableObject{
    @Published var isLoading:Bool = false
    
    @Published var dayContentItemList:[DayContentItem] = []
    @Published var currentMonthList:[DayContentItem] = []
    @Published var dateStringList:[String] = []
    
        init() {
            getAllDayContentItems()
        }
    
    func getAllDayContentItems() {
        //isLoading = true
        let fetchRequest: NSFetchRequest<DayContentItem> = DayContentItem.fetchRequest()
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            //获取所有的Item
            print("加载所有日期Item")
            self.dayContentItemList = try viewContext.fetch(fetchRequest)
            self.getDateStringList()
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
        
    }
    
    func getDateStringList(){
        print("获取日期字符串列表")
        for item in self.dayContentItemList {
            self.dateStringList.append(item.dateString ?? "")
            //print(item.dateString ?? "")
        }
    }
    
    func isExist(dateString:String) -> Bool {
        let fetchRequest: NSFetchRequest<DayContentItem> = DayContentItem.fetchRequest()
        let viewContext = PersistenceController.shared.container.viewContext
        let pre =  NSPredicate(format: "dateString == %@", "\(dateString)")
        fetchRequest.predicate = pre
        var tmpList:[DayContentItem] = []
        do {
            //获取所有的Item
            tmpList = try viewContext.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
        if tmpList.count == 0 {
            return false
        }else{
            return true
        }
    }
    
    func haveContent(dateString:String,isCurrentMonth:Bool = false) -> Bool {
        // 在全部数据中匹配
        if !isCurrentMonth {
            if self.dateStringList.contains(dateString) {
                return true
            }else{
                return false
            }
        }else {
            var resultItem:[String] = []
            for item in currentMonthList {
                resultItem.append(item.dateString ?? "")
            }
            if resultItem.contains(dateString) {
                return true
            }else{
                return false
            }
        }
    }
    
    func getCurrentMonthItems() {
        let fetchRequest: NSFetchRequest<DayContentItem> = DayContentItem.fetchRequest()
        let monthString = Date().dateToString(format: "yyyyMM")
        let pre =  NSPredicate(format: "monthString == %@", "\(monthString)")
        fetchRequest.predicate = pre
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            //获取所有的Item
            currentMonthList = try viewContext.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
        print("获取当前月的数据")
    }
    
    
    func createTestDayContentItem() {
        let container = PersistenceController.shared.container
        let viewContext = container.viewContext
        
        for i in 1..<10{
            let item = DayContentItem(context: viewContext)
            item.dateString = "2021010\(i)"
            item.monthString = "202101"
            item.isLearnDone = true
        }
        saveDayContentItemToPersistentStore()
        //保存后刷新
        getAllDayContentItems()
    }
    
    func createItem(dateString: String) {
        let monthString = dateString.prefix(6)
        let item = DayContentItem(context: PersistenceController.shared.container.viewContext)
        item.dateString = dateString
        item.monthString = String(monthString)
        item.isLearnDone = true
        saveDayContentItemToPersistentStore()
        getAllDayContentItems()
    }
    
    func createTestItem() {
        dateStringList = ["20210501","20210502","20210503",
                          "20210504","20210506","20210507",
                          "20210520","20210521"]
        
        for dateString in dateStringList {
            let monthString = dateString.prefix(6)
            let item = DayContentItem(context: PersistenceController.shared.container.viewContext)
            item.dateString = dateString
            item.monthString = String(monthString)
            item.isLearnDone = true
        }
        saveDayContentItemToPersistentStore()
        getAllDayContentItems()
    }
    
    //保存
    func saveDayContentItemToPersistentStore() {
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
            print("完成保存")
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    func deleteAllDayContentItem()  {
        let viewContext = PersistenceController.shared.container.viewContext
        let allItems = NSFetchRequest<NSFetchRequestResult>(entityName: "DayContentItem")
        let delAllRequest = NSBatchDeleteRequest(fetchRequest: allItems)
        do {
            try viewContext.execute(delAllRequest)
            dateStringList = []
            print("删除全部数据")
            saveDayContentItemToPersistentStore()
        }
        catch { print(error) }
    }
}
