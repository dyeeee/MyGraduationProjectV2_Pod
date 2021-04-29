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
import LeanCloud

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
        print(ToDoItemList)
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
    
    func uploadToCloud() {
        print("开始同步ToDo")
        
        // 获取用户名
        let user = LCApplication.default.currentUser?.username?.stringValue ?? "Anonymous"
        
        //获取未同步的数据
        var dataToUpload:[ToDoItem] = []
        let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
//        let pre =  NSPredicate(format: "isSynced == false")
//        fetchRequest.predicate = pre
        
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            dataToUpload = try viewContext.fetch(fetchRequest)
            print("获取到未同步的数据")
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
        //查找当前的并删除
        let query = LCQuery(className: "TodoItem")
        query.whereKey("user", .equalTo("\(user)"))
        _ = query.find { result in
            switch result {
            case .success(objects: let result_list):
                // result_list 是包含满足条件的 Student 对象的数组
                // 批量删除
                _ = LCObject.delete(result_list, completion: { (result) in
                    switch result {
                    case .success:
                        print("删除成功")
                        break
                    case .failure(error: let error):
                        print(error)
                    }
                })
                break
            case .failure(error: let error):
                print(error)
                print("不需要删除")
            }
        }
        
        // 创建一个保存所有 LCObject 的数组
        var objects: [LCObject] = []
        for todo in dataToUpload {
            do {
                let Item_lean = LCObject(className: "TodoItem")
                
                try Item_lean.set("todoID", value: LCString(todo.todoID?.uuidString ?? "noContent"))
                try Item_lean.set("todoContent", value: LCString(todo.todoContent ?? "noContent"))
                try Item_lean.set("createDateString", value: LCString(todo.createDateString ?? "noDate"))
                try Item_lean.set("done", value: LCBool(todo.done))

                try Item_lean.set("user", value: LCString(user))
                
                objects.append(Item_lean)  //需要更新的对象传入数组

            }catch {
                print("建立新对象失败: \(error)")
            }
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
        // 保存数组
        _ = LCObject.save(objects, completion: { (result) in
            switch result {
            case .success:
                print("todo保存到云端完成")
                break
            case .failure(error: let error):
                print("todo保存到云端失败: \(error)")
            }
        })}
        
    }
    
    func downloadFromCloud() {
        for toDoItem in self.ToDoItemList {
            deleteToDoItem(ToDoItemInstance: toDoItem)
        }
        getAllToDoItems()
        
        let user = LCApplication.default.currentUser?.username?.stringValue ?? "Anonymous"
        let container = PersistenceController.shared.container
        let viewContext = container.viewContext
        
        let query = LCQuery(className: "TodoItem")
        query.whereKey("user", .equalTo("\(user)"))
        _ = query.find { result in
            switch result {
            case .success(objects: let result_list):
                for Item_lean in result_list {
                    let todoItem = ToDoItem(context: viewContext)
                    todoItem.todoID = UUID()
                    todoItem.todoContent = Item_lean.get("todoContent")?.stringValue
                    let createDateString = Item_lean.get("createDateString")?.stringValue
                    todoItem.createDateString = createDateString
                    let tmpDone:Bool = Item_lean.get("done")?.boolValue ?? false
                    todoItem.done = tmpDone
                    todoItem.createDate = createDateString?.stringToDate(format:"yyyyMMddHHmm")
                    print(todoItem.done)
                }
                
                break
            case .failure(error: let error):
                print(error)
            }
        }
        print("下载todo完成")
        saveToPersistentStore()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
            self.getAllToDoItems()
            self.saveToPersistentStore()
        }
    }
    
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
