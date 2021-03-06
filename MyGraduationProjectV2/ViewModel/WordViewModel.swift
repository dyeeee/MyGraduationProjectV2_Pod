//
//  WordItemController.swift
//  MyVocabularyBook
//
//  Created by YES on 2020/11/27.
//

import Foundation
import CoreData
import SwiftUI
import LeanCloud


class WordViewModel: ObservableObject{
    @Published var itemList:[WordItem] = []
    @Published var searchResultList:[WordItem] = []
    
    @Published var searchHistoryList:[WordItem] = []
    
    @Published var groupedStarLevelList:[[WordItem]] = []
    @Published var groupedABCList:[[WordItem]] = []
    
    @Published var isSyncing = false
    
    @AppStorage("UD_noteWordNum") var UD_noteWordNum = 0
    
    
    enum ListName {
        case item
        case searchResult
        case notebook
    }
    
    init() {
        getAllItems()
        getHistoryItems()
        getGroupedItems()
    }
    
    
    func getItems(_ dataType:WordListType = .all) -> [WordItem] {
        if dataType == .all {
            return self.itemList
        }
        else if dataType == .searchResult {
            return self.searchResultList
        }
        else if dataType == .history{
            return self.searchHistoryList
        }
        else{
            return self.itemList
        }
    }
    
    //获取所有单词
    func getAllItems() {
        let fetchRequest: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        let sort = NSSortDescriptor(key: "wordContent", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        
        fetchRequest.fetchLimit = 50
        //fetchRequest.predicate = pre
        fetchRequest.sortDescriptors = [sort]
        
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            //获取所有的Item
            itemList = try viewContext.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
    }
    
    //获取按星级/首字母分组的列表
    func getGroupedItems(_ by:String = "starLevel") {
        let fetchRequest: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        let starLevelFilter = "0"
        let pre =  NSPredicate(format: "starLevel > %@", starLevelFilter)
        //let sort = NSSortDescriptor(key: "wordContent", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        
        fetchRequest.fetchLimit = 50
        fetchRequest.predicate = pre
        //fetchRequest.sortDescriptors = [sort]
        let viewContext = PersistenceController.shared.container.viewContext
        
        var list:[WordItem] = []
        
        do {
            list = try viewContext.fetch(fetchRequest)
            UD_noteWordNum = list.count
        } catch {
            NSLog("Error fetching tasks: \(error)")
            
        }
        
        let groupedByStarLevel = Dictionary(grouping: list)
        { (element: WordItem)  in
            element.starLevel
        }.values.sorted(){ $0[0].starLevel > $1[0].starLevel }
        
        let groupedByABC = Dictionary(grouping: list)
        { (element: WordItem)  in
            element.wordContent!.prefix(1).uppercased()
        }.values.sorted(){ $0[0].wordContent!.prefix(1).uppercased() < $1[0].wordContent!.prefix(1).uppercased() }
        
        self.groupedStarLevelList = groupedByStarLevel
        self.groupedABCList = groupedByABC
    }
    
    //获取历史记录的单词
    func getHistoryItems() {
        let fetchRequest: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        let sort = NSSortDescriptor(key: "latestSearchDate", ascending: false,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        let pre =  NSPredicate(format: "searchCount > 0")
        fetchRequest.fetchLimit = 20
        fetchRequest.predicate = pre
        fetchRequest.sortDescriptors = [sort]
        
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            //获取所有的Item
            self.searchHistoryList = try viewContext.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
    }
    
    //清除历史记录
    func deleteAllHistory() {
        let fetchRequest: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        let pre =  NSPredicate(format: "searchCount > 0")
        fetchRequest.predicate = pre
        
        let viewContext = PersistenceController.shared.container.viewContext
        var historyWord:[WordItem] = []
        do {
            //获取所有的Item
            historyWord = try viewContext.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
        
        for item in historyWord {
            item.searchCount = 0
        }
        
        saveToPersistentStore()
        self.getHistoryItems()
    }
    
    //清除本地生词本内容
    func deleteAllNotebook() {
        let fetchRequest: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        let emptyStr = ""
        let pre1 =  NSPredicate(format: "starLevel > 0")
        let pre2 =  NSPredicate(format: "wordNote != %@",emptyStr)
        let combinePre = NSCompoundPredicate(type: .or, subpredicates: [pre1, pre2])
        fetchRequest.predicate = combinePre
        
        let viewContext = PersistenceController.shared.container.viewContext
        var tmpList:[WordItem] = []
        do {
            //获取所有的Item
            tmpList = try viewContext.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
        
        for item in tmpList {
            item.starLevel = 0
            item.wordNote = ""
        }
        UD_noteWordNum = 0
        saveToPersistentStoreAndRefresh(.notebook)
    }
    
    
    //查询
    func searchItems(begins:String) {
        let fetchRequest: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        
        //WordItem.fetchRequest() 就是 NSFetchRequest<WordItem>(entityName: "WordItem"）
        let pre =  NSPredicate(format: "wordContent BEGINSWITH[c] %@", "\(begins)")
        let pre_CH = NSPredicate(format: "translation contains %@", "\(begins)")
        let combinePre = NSCompoundPredicate(type: .or, subpredicates: [pre, pre_CH])
        
        let sort = NSSortDescriptor(key: "wordContent", ascending: true)
        
        fetchRequest.predicate = combinePre
        fetchRequest.fetchLimit = 20
        fetchRequest.sortDescriptors = [sort]
        
        let viewContext = PersistenceController.shared.container.viewContext
        
        do {
            searchResultList = try viewContext.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
            
        }
    }
    
    func searchItemByID(id:Int32) -> WordItem {
        let fetchRequest: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        //WordItem.fetchRequest() 就是 NSFetchRequest<WordItem>(entityName: "WordItem"）
        let pre =  NSPredicate(format: "wordID == %@", "\(id)")
        fetchRequest.predicate = pre
        let viewContext = PersistenceController.shared.container.viewContext
        
        var testList:[WordItem] = []
        
        do {
            testList = try viewContext.fetch(fetchRequest)
            if testList.count > 0 {
                return testList[0]  //id唯一
            }
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
        //print(testList)
        return WordItem(context: viewContext)
    }
    
    func createTestItem() {
        let container = PersistenceController.shared.container
        let viewContext = container.viewContext
        
        for i in 0..<5{
            let wordItem = WordItem(context: viewContext)
            wordItem.wordContent = "Test-\(i)"
            wordItem.translation = "测试样例-\(i)"
        }
        
        saveToPersistentStoreAndRefresh(.item)
    }
    
    func preloadFromCSV() {
        let container = PersistenceController.shared.container
        let csvTool = CSVTools()
        
        var data = csvTool.readDataFromCSV(fileName: "Common_Wrods_Small", fileType: "csv")
        data = csvTool.cleanRows(file: data ?? "d")
        let csvRows = csvTool.csv(data: data ?? "d")
        
        container.performBackgroundTask() { (context) in
            for i in 1 ..< (csvRows.count - 1) {  //有标题就从1开始
                let word = WordItem(context: context)
                var id = csvRows[i][0]
                id.removeFirst() // 去除最开始的引号
                word.wordID =  Int32(id) ?? 0
                word.wordContent = csvRows[i][1]
                word.phonetic_EN = csvRows[i][2]
                word.phonetic_US = csvRows[i][3]
                word.definition = csvRows[i][4]
                word.translation = csvRows[i][5]
                word.wordTags = csvRows[i][6]
                word.wordExchanges = csvRows[i][7]
                word.bncLevel = Int16(csvRows[i][8]) ?? 0
                word.frqLevel = Int16(csvRows[i][9]) ?? 0
                word.collinsLevel = Int16(csvRows[i][10]) ?? 0
                word.oxfordLevel = Int16(csvRows[i][11]) ?? 0
                word.exampleSentences = csvRows[i][12]
                word.wordNote = ""
                word.starLevel = 0
                word.searchCount = 0
                
                word.isSynced = true
            }
            do {
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                try context.save()
                print("后台加载完整数据完成")
                //在主队列异步加载一次
                DispatchQueue.main.async {
                    self.getAllItems()
                    print("重新获取所有数据完成")
                }
            }
            catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    func preloadFromBigCSV() {
        let container = PersistenceController.shared.container
        let csvTool = CSVTools()
        
        var data = csvTool.readDataFromCSV(fileName: "Common_Words_3Sentences", fileType: "csv")
        data = csvTool.cleanRows(file: data ?? "d")
        let csvRows = csvTool.csv(data: data ?? "d")
        
        container.performBackgroundTask() { (context) in
            for i in 1 ..< (csvRows.count - 1) {  //有标题就从1开始
                let word = WordItem(context: context)
                var id = csvRows[i][0]
                id.removeFirst() // 去除最开始的引号
                word.wordID =  Int32(id) ?? 0
                word.wordContent = csvRows[i][1]
                word.phonetic_EN = csvRows[i][2]
                word.phonetic_US = csvRows[i][3]
                word.definition = csvRows[i][4]
                word.translation = csvRows[i][5]
                word.wordTags = csvRows[i][6]
                word.wordExchanges = csvRows[i][7]
                word.bncLevel = Int16(csvRows[i][8]) ?? 0
                word.frqLevel = Int16(csvRows[i][9]) ?? 0
                word.collinsLevel = Int16(csvRows[i][10]) ?? 0
                word.oxfordLevel = Int16(csvRows[i][11]) ?? 0
                word.exampleSentences = csvRows[i][12]
                word.wordNote = ""
                word.starLevel = 0
                word.searchCount = 0
                word.isSynced = true
            }
            do {
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                try context.save()
                print("后台加载完整数据完成")
                //在主队列异步加载一次
                DispatchQueue.main.async {
                    self.getAllItems()
                    print("重新获取所有数据完成")
                }
            }
            catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    
    
    func deleteAll()  {
        let viewContext = PersistenceController.shared.container.viewContext
        let allItems = NSFetchRequest<NSFetchRequestResult>(entityName: "WordItem")
        let delAllRequest = NSBatchDeleteRequest(fetchRequest: allItems)
        do {
            try viewContext.execute(delAllRequest)
            print("删除全部数据")
            saveToPersistentStore()
        }
        catch { print(error) }
    }
    
    //更新， 传入一个Item实例对象, 修改这个实例
    func updateItem(ItemInstance: WordItem) {
        ItemInstance.wordContent = "test"
        saveToPersistentStore()
    }
    
    //保存
    func saveToPersistentStore() {
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
            //getAllItems()
            print("本地完成保存(未重新赋值)")
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    //保存并刷新列表
    func saveToPersistentStoreAndRefresh(_ listName:ListName) {
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
            //getAllItems()
            if listName == .item {
                self.getAllItems()
            }else if listName == .notebook{
                // 延迟保存优化性能，添加timer优化后可以考虑删掉
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.getGroupedItems()
                    
                }
            }else{
                self.getAllItems()
            }
            print("完成保存并重新给对应数据列表赋值")
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    func uploadToCloud() {
        self.isSyncing = true //同步开始
        print("开始同步")
        
        // 获取用户名
        let user = LCApplication.default.currentUser?.username?.stringValue ?? "Anonymous"
        
        //获取未同步的数据
        var dataToUpload:[WordItem] = []
        let fetchRequest: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        
        //WordItem.fetchRequest() 就是 NSFetchRequest<WordItem>(entityName: "WordItem"）
        let pre =  NSPredicate(format: "isSynced == false")
        let sort = NSSortDescriptor(key: "wordContent", ascending: true)
        
        fetchRequest.predicate = pre
        fetchRequest.sortDescriptors = [sort]
        
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            dataToUpload = try viewContext.fetch(fetchRequest)
            print("获取到未同步的数据")
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
        
        // 创建一个保存所有 LCObject 的数组
        var objects: [LCObject] = []
        
        for wordItem in dataToUpload {
            
            let query = LCQuery(className: "WordItem")
            query.whereKey("user", .equalTo("\(user)"))
            query.whereKey("wordID", .equalTo(LCNumber(integerLiteral: Int(wordItem.wordID))))
            
            //查询得到的话则更新，因为id唯一
            if  query.count().intValue != 0 {
                print("尝试更新Lean对象")
                _ = query.getFirst { result in
                    switch result {
                    case .success(object: let wordItem_lean):
                        print("已有该wordID的单词数据在云端")
                        //更新
                        do {
                            print(wordItem_lean.objectId?.value ?? "0")
                            let updateItem = LCObject(className: "WordItem", objectId: "\(wordItem_lean.objectId?.value ?? "0")")
                            try updateItem.set("starLevel", value: LCNumber(integerLiteral: Int(wordItem.starLevel)))
                            try updateItem.set("searchCount", value: LCNumber(integerLiteral: Int(wordItem.searchCount)))
                            try updateItem.set("wordNote", value: LCString(wordItem.wordNote ?? "noNote"))
                            try updateItem.set("isDownloaded", value: LCBool(false))
                            objects.append(updateItem)  //需要更新的对象传入数组
                            
                            print("更新中")

                        } catch {
                            print("更新失败:\(error)")
                        }
                    case .failure(error: let error):
                        print("未有该id的单词数据在云端: \(error)")
                    }
                }
            }
            else{ //查询不到则建立
                // 构建对象
                print("尝试构建Lean对象")
                do {
                    let wordItem_lean = LCObject(className: "WordItem")
                    
                    try wordItem_lean.set("wordID", value: LCNumber(integerLiteral: Int(wordItem.wordID)))
                    try wordItem_lean.set("wordContent", value: LCString(wordItem.wordContent ?? "noContent"))
                    try wordItem_lean.set("starLevel", value: LCNumber(integerLiteral: Int(wordItem.starLevel)))
                    try wordItem_lean.set("searchCount", value: LCNumber(integerLiteral: Int(wordItem.searchCount)))
                    try wordItem_lean.set("wordNote", value: LCString(wordItem.wordNote ?? "noNote"))
                    try wordItem_lean.set("isDownloaded", value: LCBool(false))
                    
                    try wordItem_lean.set("user", value: LCString(user))
                    
                    objects.append(wordItem_lean)  //需要更新的对象传入数组
                    wordItem.isSynced = true
                }catch {
                    print("建立新对象失败: \(error)")
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
        // 保存数组
        _ = LCObject.save(objects, completion: { (result) in
            switch result {
            case .success:
                print("保存到云端完成")
                self.isSyncing = false  //同步结束
                break
            case .failure(error: let error):
                print("保存到云端失败: \(error)")
            }
        })}
//        UIDevice.current.identifierForVendor?.uuidString
        //保存CoreData
        saveToPersistentStore()
        
    }
    
    func downloadFromCloud() {
        self.isSyncing = true
        
        let viewContext = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        var tmpList:[WordItem] = []
        
        let user = LCApplication.default.currentUser?.username?.stringValue ?? "Anonymous"
        let query = LCQuery(className: "WordItem")
        query.whereKey("user", .equalTo("\(user)"))
        //query.whereKey("isDownloaded", .equalTo(LCBool(false)))
        
        // 创建一个保存所有 LCObject 的数组，用来更新已下载状态
        var objects: [LCObject] = []
        _ = query.find { result in
            switch result {
            case .success(objects: let wordItems_cloud):
                // 是包含满足条件的对象的数组
                for wordItem_cloud in wordItems_cloud {
                    // 寻找id关联的单词
                    let pre =  NSPredicate(format: "wordID == %@", "\(Int32(wordItem_cloud.get("wordID")?.intValue ?? 0))")
                    fetchRequest.predicate = pre
                    
                    //保存到本地
                    do {
                        tmpList = try viewContext.fetch(fetchRequest)
                        if tmpList.count > 0 {
                            //print(tmpList[0].wordContent ?? "noContent")
                            tmpList[0].starLevel = Int16(wordItem_cloud.get("starLevel")?.intValue ?? 0)
                            tmpList[0].searchCount = Int16(wordItem_cloud.get("searchCount")?.intValue ?? 0)
                            
                            tmpList[0].wordNote = wordItem_cloud.get("wordNote")?.stringValue
                            
                            tmpList[0].isSynced = true
                            
                            //云端状态
                            try wordItem_cloud.set("isDownloaded", value: LCBool(true))
                            objects.append(wordItem_cloud)
                        }
                    } catch {
                        NSLog("Error fetching tasks: \(error)")
                    }
                }
                self.saveToPersistentStoreAndRefresh(.notebook)
                self.getHistoryItems()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5){
                // 保存数组
                _ = LCObject.save(objects, completion: { (result) in
                    switch result {
                    case .success:
                        print("保存到云端完成")
                        self.isSyncing = false  //同步结束
                        break
                    case .failure(error: let error):
                        print("保存到云端失败: \(error)")
                    }
                })}
                
                break
            case .failure(error: let error):
                print(error)
            }
        }
        
        
        
    }
}
