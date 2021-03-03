//
//  ToDoViewModel.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/20.
//

import Foundation
import CoreData
import Combine
import UIKit

class ToDoViewModel: ObservableObject {
    
    // ToDoItem的数组
    @Published var ToDoItemList: [ToDoItem] = []
    @Published var UndoneToDoItemList: [ToDoItem] = []
    
    //初始化时就把所有数据显先读到DataStore中
    init() {
        getAllToDoItems()
        getUndoneToDoItems()
    }
    
    //读取
    func getAllToDoItems() {
        let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        let viewContext = PersistenceController.shared.container.viewContext
        //let sort1 = NSSortDescriptor(key: "done", ascending: true)
        let sort2 = NSSortDescriptor(key: "createDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sort2]
        do {
            //获取所有的ToDoItem
            ToDoItemList = try viewContext.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
            
        }
    }
    
    //读取
    func getUndoneToDoItems() {
        let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        let viewContext = PersistenceController.shared.container.viewContext
        let pre =  NSPredicate(format: "done == false")
        let sort = NSSortDescriptor(key: "createDate", ascending: false)
        fetchRequest.predicate = pre
        fetchRequest.sortDescriptors = [sort]
        do {
            //获取所有的ToDoItem
            //ToDoItemList = try viewContext.fetch(fetchRequest)
            UndoneToDoItemList = try viewContext.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
            
        }
    }
    
    //保存
    func saveToPersistentStore() {
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
            getAllToDoItems()
            getUndoneToDoItems()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    
    
    //查询
    func searchToDoItems(contain:String) {
        let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        //ToDoItem.fetchRequest() 就是 NSFetchRequest<ToDoItem>(entityName: "ToDoItem"）
        let pre =  NSPredicate(format: "todoContent contains[c] %@", "\(contain)")
        let sort = NSSortDescriptor(key: "createDate", ascending: false)
        fetchRequest.predicate = pre
        fetchRequest.sortDescriptors = [sort]
        let viewContext = PersistenceController.shared.container.viewContext
        
        do {
            ToDoItemList = try viewContext.fetch(fetchRequest)
            
        } catch {
            NSLog("Error fetching tasks: \(error)")
            
        }
    }
    
    
    //创建
    func createToDoItem(content: String) {
        let container = PersistenceController.shared.container
        let viewContext = container.viewContext
        let todoItem = ToDoItem(context: viewContext)
        
        todoItem.todoID = UUID()
        todoItem.todoContent = content
        todoItem.createDate = Date()
        todoItem.createDateString = Date().dateToString(format: "yyyyMMddHHmm")
        todoItem.done = false
        saveToPersistentStore()
    }
    
    func createTest() {
        
        let container = PersistenceController.shared.container
        let viewContext = container.viewContext
        
        for i in 0..<5{
            let todoItem = ToDoItem(context: viewContext)
            todoItem.todoID = UUID()
            todoItem.todoContent = "content \(i)"
            todoItem.createDate = Date()
            todoItem.createDateString = Date().dateToString(format: "yyyyMMddHHmm")
            todoItem.done = false
        }
        
        saveToPersistentStore()
        
    }
    
    //    //创建,传参后直接保存
    //    func createToDoItem(content: String, done:Bool, createdAt: Date) {
    //        _ = ToDoItem(createdAt:createdAt, content: content, done: done)
    //        saveToPersistentStore()
    //    }
    
    //更新， 传入一个ToDoItem实例对象
    func updateToDoItem(ToDoItemInstance: ToDoItem, content: String) {
        ToDoItemInstance.todoContent = content
        saveToPersistentStore()
    }
    
    //更新， 传入一个ToDoItem实例对象
    func updateToDoItem(ToDoItemInstance: ToDoItem, done:Bool) {
        ToDoItemInstance.done = done
        saveToPersistentStore()
    }
    
    //删除，直接删除对象
    func deleteToDoItem(ToDoItemInstance: ToDoItem) {
        let container = PersistenceController.shared.container
        let viewContext = container.viewContext
        viewContext.delete(ToDoItemInstance)
        saveToPersistentStore()
    }
    
    //删除，根据索引删除
    func deleteToDoItem(at indexSet: IndexSet) {
        guard let index = Array(indexSet).first else { return }
        //找到索引后定义对象
        let ToDoItem = self.ToDoItemList[index]
        
        deleteToDoItem(ToDoItemInstance: ToDoItem)
    }
    
    //删除全部
    func deleteAllToDoItem() {
        for toDoItem in self.ToDoItemList {
            deleteToDoItem(ToDoItemInstance: toDoItem)
        }
    }
    
    //删除全部已完成的待办事项
    func deleteAllDoneItem() {
        let container = PersistenceController.shared.container
        let viewContext = container.viewContext
        for toDoItem in self.ToDoItemList {
            if toDoItem.done == true{
                viewContext.delete(toDoItem)
            }else{
                continue
            }
        }
        
        saveToPersistentStore()
    }
}
