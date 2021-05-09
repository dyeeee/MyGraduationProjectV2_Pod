//
//  LearningWordViewModel.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/20.
//

import SwiftUI
import Foundation
import CoreData
import LeanCloud

class LearnWordViewModel: ObservableObject{
    @Published var allWordsToLearnList:[LearningWordItem] = []
    @Published var learningWordList:[LearningWordItem] = []
    @Published var knownWordList:[LearningWordItem] = []
    @Published var unlearnedWordList:[LearningWordItem] = []
    
    @Published var todayNewWordList:[LearningWordItem] = []
    @Published var todayReviewWordList:[LearningWordItem] = []
    
//    随机小测的列表
    @Published var randomTestWordList:[LearningWordItem] = []
    
    
    @Published var todayAllCount:Int = 1
    @Published var todayNewCount:Int = 0   //用户设定每日新词数量
    @Published var todayReviewCount:Int = 0
    
    @AppStorage("UD_learningBook") var UD_learningBook = ""
    
    @AppStorage("UD_allWordNum") var UD_allWordNum = 0 //单词总量，存在UD里
    @AppStorage("UD_unlearnedWordNum") var UD_unlearnedWordNum = 0 //未学习的总量，存在UD里
    @AppStorage("UD_learningWordNum") var UD_learningWordNum = 0 //学习中的总量，存在UD里
    @AppStorage("UD_knownWordNum") var UD_knownWordNum = 0 //已掌握的总量，存在UD里
    @AppStorage("UD_Cloud_learningBook") var UD_Cloud_learningBook = ""
    
    @AppStorage("UD_newWordNum") var UD_newWordNum = 10 //用户设定每日新词数量，存在UD里
    @AppStorage("UD_learnDayCount") var UD_learnDayCount = 1
    
    @AppStorage("UD_isLastLearnDone") var UD_isLastLearnDone = false
    
    @Published var wordStatusCount:[Double] = [1,1,1]
    
    @Published var isSyncing = false
    
    @Published var isLoading = false
    
    init() {
        getAllItems()
        getKnownWordItems()
        getLearningWordItems()
        getUnlearnedWordItems()
        getDataStats()
        
        //初始化今天要学习的单词列表
        getTodayList(newWordNum:self.UD_newWordNum,learnDayCount:self.UD_learnDayCount)
    }
    
    func getDataStats()  {
        wordStatusCount = [Double(UD_unlearnedWordNum),Double(UD_knownWordNum),Double(UD_learningWordNum)]
        //print("状态统计数据: \(wordStatusCount)")
        //return [learningWordNum,knownWordNum,unlearnedWordNum]
    }
    
    //今天要学习的单词
    func getTodayList(newWordNum:Int,learnDayCount:Int,byOnAppear:Bool = false) {
        print("学习的第\(UD_learnDayCount)天")
        getTodayNewWordItems(num:newWordNum,learnDayCount:learnDayCount)
        self.todayNewCount = todayNewWordList.count
        
        //getTodayReviewWordItems(learnDayCount: learnDayCount)
        //仅获取一个数量，真正把数据加载到视图中再nextCard_Learn中执行
        let fetchRequest: NSFetchRequest<LearningWordItem> = LearningWordItem.fetchRequest()
        let pre =  NSPredicate(format: "nextReviewDay == %@", "\(learnDayCount)") // pre会改为下次复习时间为今天的单词
        fetchRequest.predicate = pre
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            self.todayReviewCount = try viewContext.fetch(fetchRequest).count + newWordNum
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
        
        //程序启动时已经执行了一次，显示的新词、复习的词都是已经算好的
        if  byOnAppear {
            for item in todayNewWordList{
                item.nextReviewDay = Int16(learnDayCount) //补充把下次复习时间添加为今天,这样加载复习单词的时候就能加载到
            }
            saveToPersistentStore()
        }
        
        self.todayAllCount = self.todayNewCount + self.todayReviewCount
        print("今日总量：\(todayAllCount)个，今日新词：\(todayNewCount)个，今日复习：\(todayReviewCount)个")
    }
    
    func getTodayNewWordItems(num:Int,learnDayCount:Int) {
        let fetchRequest: NSFetchRequest<LearningWordItem> = LearningWordItem.fetchRequest()
        let sort = NSSortDescriptor(key: "wordContent", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        let pre =  NSPredicate(format: "wordStatus == %@", "unlearned")
        fetchRequest.fetchLimit = num
        fetchRequest.predicate = pre
        fetchRequest.sortDescriptors = [sort]
        
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            //获取所有的Item
            todayNewWordList = try viewContext.fetch(fetchRequest)
            //            for item in todayNewWordList{
            //                item.nextReviewDay = Int16(learnDayCount) //补充把下次复习时间添加为今天
            //            }
            //            saveToPersistentStore()
            //先执行这个函数获取要新学的，再执行要复习的
            print("新词加载完成,\(todayNewCount)个")
            showItems(list: todayNewWordList)
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
    }
    
    func getTodayReviewWordItems(learnDayCount:Int) {
        let fetchRequest: NSFetchRequest<LearningWordItem> = LearningWordItem.fetchRequest()
        let sort = NSSortDescriptor(key: "wordContent", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        let pre =  NSPredicate(format: "nextReviewDay == %@", "\(learnDayCount)")
//        let pre2 =  NSPredicate(format: "wordStatus != known")
//
//        let combinePre = NSCompoundPredicate(type: .and, subpredicates: [pre1, pre2])

        //fetchRequest.fetchLimit = 6
        fetchRequest.predicate = pre
        fetchRequest.sortDescriptors = [sort]
        
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            //获取所有的Item
            todayReviewWordList = try viewContext.fetch(fetchRequest)
            for item in todayReviewWordList {
                item.todayReviewCount = 0
            }
            print("复习的词加载完成")
            showItems(list: todayReviewWordList)
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
    }
    
    func getWordTestWordItems(num:Int = 5){

        let viewContext = PersistenceController.shared.container.viewContext

        let count = learningWordList.count
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LearningWordItem")
        let pre =  NSPredicate(format: "wordStatus == %@", "learning")
        
        //fetchRequest.fetchLimit = 50
        request.predicate = pre
        request.fetchLimit = num
        request.fetchOffset = Int(arc4random_uniform(UInt32(count)))
        do {
            //获取所有的Item
            randomTestWordList = try viewContext.fetch(request) as! [LearningWordItem]
            for item in randomTestWordList {
                item.todayReviewCount = 0
            }
            print("测试的词加载完成")
            //showItems(list: todayReviewWordList)
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }



    }
    
    //显示单词列表
    func getAllItems() {
        let fetchRequest: NSFetchRequest<LearningWordItem> = LearningWordItem.fetchRequest()
        let sort = NSSortDescriptor(key: "wordContent", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        
        //fetchRequest.fetchLimit = 50
        //fetchRequest.predicate = pre
        fetchRequest.sortDescriptors = [sort]
        
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            //获取所有的Item
            allWordsToLearnList = try viewContext.fetch(fetchRequest)
            UD_allWordNum = allWordsToLearnList.count
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
    }
    
    //显示单词列表
    func getLearningWordItems() {
        let fetchRequest: NSFetchRequest<LearningWordItem> = LearningWordItem.fetchRequest()
        let sort = NSSortDescriptor(key: "wordContent", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        let pre =  NSPredicate(format: "wordStatus == %@", "learning")
        
        //fetchRequest.fetchLimit = 50
        fetchRequest.predicate = pre
        fetchRequest.sortDescriptors = [sort]
        
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            learningWordList = try viewContext.fetch(fetchRequest)
            UD_learningWordNum = learningWordList.count
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
    }
    
    //显示单词列表
    func getKnownWordItems() {
        let fetchRequest: NSFetchRequest<LearningWordItem> = LearningWordItem.fetchRequest()
        let sort = NSSortDescriptor(key: "wordContent", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        let pre =  NSPredicate(format: "wordStatus == %@", "known")
        
        //fetchRequest.fetchLimit = 50
        fetchRequest.predicate = pre
        fetchRequest.sortDescriptors = [sort]
        
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            knownWordList = try viewContext.fetch(fetchRequest)
            UD_knownWordNum = knownWordList.count
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
    }
    
    //显示单词列表
    func getUnlearnedWordItems() {
        let fetchRequest: NSFetchRequest<LearningWordItem> = LearningWordItem.fetchRequest()
        let sort = NSSortDescriptor(key: "wordContent", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        let pre =  NSPredicate(format: "wordStatus == %@", "unlearned")
        
        //fetchRequest.fetchLimit = 50
        fetchRequest.predicate = pre
        fetchRequest.sortDescriptors = [sort]
        
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            unlearnedWordList = try viewContext.fetch(fetchRequest)
            UD_unlearnedWordNum = unlearnedWordList.count
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
    }
    
    //判断对象是否存在
    func isExist(id:Int32) -> Bool {
        let fetchRequest: NSFetchRequest<LearningWordItem> = LearningWordItem.fetchRequest()
        let viewContext = PersistenceController.shared.container.viewContext
        let pre =  NSPredicate(format: "wordID == %@", "\(id)")
        fetchRequest.predicate = pre
        var tmpList:[LearningWordItem] = []
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
    
    
    //查找对应id的对象
    func searchItemByID(id:Int32) -> LearningWordItem {
        let fetchRequest: NSFetchRequest<LearningWordItem> = LearningWordItem.fetchRequest()
        
        let pre =  NSPredicate(format: "wordID == %@", "\(id)")
        fetchRequest.predicate = pre
        let viewContext = PersistenceController.shared.container.viewContext
        
        var testList:[LearningWordItem] = []
        
        do {
            testList = try viewContext.fetch(fetchRequest)
            if testList.count > 0 {
                return testList[0]  //id唯一
            }
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
        //print(testList)
        return LearningWordItem(context: viewContext)
    }
    
    //选择单词书
    func selectLearnBook(bookName:String = "cet4",isKeep:Bool = true){
        isLoading = true
        //如果需要保留已掌握的单词(第一次的时候BookChangeVIew页面不提示=不保留（isKeep=false）)
        //1. 先获取当前已掌握的单词
        var knownLearningWordIDList:[Int32] = []
        
        if isKeep{
            var knownLearningWordList:[LearningWordItem] = []
            let fetchRequest: NSFetchRequest<LearningWordItem> = LearningWordItem.fetchRequest()
            let sort = NSSortDescriptor(key: "wordContent", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
            let pre =  NSPredicate(format: "wordStatus == %@", "known")
            
            fetchRequest.predicate = pre
            fetchRequest.sortDescriptors = [sort]
            
            let viewContext = PersistenceController.shared.container.viewContext
            do {
                knownLearningWordList = try viewContext.fetch(fetchRequest)
            } catch {
                NSLog("Error fetching tasks: \(error)")
            }
            print("原有已掌握的单词个数: \(knownLearningWordList.count)")
            for item in knownLearningWordList {
                knownLearningWordIDList.append(item.wordID)
               // print("已掌握的单词:\(item.wordID),\(item.wordContent)")
            }
        }
            
        //1.5 删除当前单词书
        deleteAll()

        
        //2. 从CoreData中加载单词
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest_WordItem: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        let sort = NSSortDescriptor(key: "wordContent", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        let pre =  NSPredicate(format: "wordTags contains %@", "\(bookName)")
        
        var tmpList:[WordItem] = []
        
        //用于测试限制数量
        fetchRequest_WordItem.fetchLimit = 500
        fetchRequest_WordItem.predicate = pre //从完整列表中选取对应标签的
        fetchRequest_WordItem.sortDescriptors = [sort]
        
        //不在后台加载
        //container.performBackgroundTask() { (context) in
            do {
                //获取所有的Item
                tmpList = try context.fetch(fetchRequest_WordItem)
                print("获取到CoreData数据，(标签为\(bookName)的单词\(tmpList.count)个)")
            } catch {
                NSLog("Error fetching tasks: \(error)")
            }

            for item in tmpList {
                let learningWord = LearningWordItem(context: context)
                learningWord.wordID = item.wordID
                learningWord.wordContent = item.wordContent
                
                learningWord.isSynced = true
                learningWord.wordStatus = "unlearned"
                learningWord.reviewTimes = 0
                learningWord.nextReviewDay = 0
                
                //关联单词对象
                learningWord.sourceWord = item
            }
            
            do {
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                try context.save()
            }
            catch {
                fatalError("Failure to save context: \(error)")
            }
        //}
        //从CoreData来的先保存
        saveToPersistentStore()
        
        //3. 保留的话遍历单词并修改对应的learn单词
        if isKeep {
            //都是已掌握的单词
            for id in knownLearningWordIDList {
                let learningWordItem = searchItemByID(id: id) //获取到对应的learningWordItem
                guard learningWordItem.wordContent != nil else {
                    context.delete(learningWordItem)
                    continue
                }
                learningWordItem.wordStatus = "known"
                print("已掌握的单词ID:\(id)")
            }
        }else{
            knownLearningWordIDList = []
            let user = LCApplication.default.currentUser?.username?.stringValue ?? "Anonymous"
            let query = LCQuery(className: "LearningWordItem")
            query.whereKey("user", .equalTo("\(user)"))
            _ = query.find { result in
                switch result {
                case .success(objects: let result_list):
                    // result_list 是包含满足条件的 Student 对象的数组
                    // 批量删除
                    _ = LCObject.delete(result_list, completion: { (result) in
                        switch result {
                        case .success:
                            print("删除所有学习的单词成功")
                            break
                        case .failure(error: let error):
                            print(error)
                        }
                    })
                    break
                case .failure(error: let error):
                    print(error)
                }
            }
        }
        
        //4.再次完成保存并刷新列表
        print("单词书处理完成")
        saveToPersistentStore()
        //在主队列异步加载一次
        DispatchQueue.main.async {
            self.getAllItems()
            self.getKnownWordItems()
            self.getLearningWordItems()
            self.getUnlearnedWordItems()
            self.getDataStats()
            self.getTodayList(newWordNum:self.UD_newWordNum,learnDayCount:self.UD_learnDayCount)
            print("单词书加载完成")
            self.isLoading = false
        }
    }
    
    //从CoreData加载单词
    func preloadLearningWordFromCoreData(bookName:String = "cet4") {
        deleteAll()
        let container = PersistenceController.shared.container
        //        let csvTool = CSVTools()
        //        var data = csvTool.readDataFromCSV(fileName: "IELTS_Words_wordonly", fileType: "csv")
        //        data = csvTool.cleanRows(file: data ?? "d")
        //        let csvRows = csvTool.csv(data: data ?? "d")
        let fetchRequest: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        let pre =  NSPredicate(format: "wordTags contains %@", "\(bookName)")
        let sort = NSSortDescriptor(key: "wordContent", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:)))
        var tmpList:[WordItem] = []
        
        //用于测试
        fetchRequest.fetchLimit = 500
        fetchRequest.predicate = pre
        fetchRequest.sortDescriptors = [sort]
        container.performBackgroundTask() { (context) in
            do {
                //获取所有的Item
                tmpList = try context.fetch(fetchRequest)
                print("获取到CoreData数据")
            } catch {
                NSLog("Error fetching tasks: \(error)")
            }
            for item in tmpList {
                let learningWord = LearningWordItem(context: context)
                learningWord.wordID = item.wordID
                learningWord.wordContent = item.wordContent
                
                learningWord.isSynced = true
                learningWord.wordStatus = "unlearned"
                learningWord.reviewTimes = 0
                learningWord.nextReviewDay = 0
                
                //关联单词对象
                learningWord.sourceWord = item
            }
            
            do {
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                try context.save()
                print("后台加载完成")
                //在主队列异步加载一次
                DispatchQueue.main.async {
                    self.getAllItems()
                    self.getKnownWordItems()
                    self.getLearningWordItems()
                    self.getUnlearnedWordItems()
                    self.getDataStats()
                    self.getTodayList(newWordNum:self.UD_newWordNum,learnDayCount:self.UD_learnDayCount)
                    print("从CoreData获取数据完成")
                }
            }
            catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    //从CSV家在单词（弃用）
    func preloadLearningWordFromCSV() {
        let container = PersistenceController.shared.container
        let csvTool = CSVTools()
        
        var data = csvTool.readDataFromCSV(fileName: "IELTS_Words_wordonly", fileType: "csv")
        data = csvTool.cleanRows(file: data ?? "d")
        let csvRows = csvTool.csv(data: data ?? "d")
        let fetchRequest: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        var testList:[WordItem] = []
        
        container.performBackgroundTask() { (context) in
            for i in 1 ..< 401 {  //有标题就从1开始，测试400个
                let word = LearningWordItem(context: context)
                var id = csvRows[i][0]
                id.removeFirst()
                word.wordID =  Int32(id) ?? 0// 去除最开始的引号
                var content = csvRows[i][1]
                content.removeLast()
                word.wordContent = content
                //word.wordStatus = "unlearned"
                
                word.isSynced = true
                //print("doing \(word.wordID)")  //仅测试用例
                if i < 101{
                    word.wordStatus = "known"
                }
                //                else if i < 201{
                //                    word.wordStatus = "known"
                //                }
                else{
                    word.wordStatus = "unlearned"
                }
                word.reviewTimes = 0
                word.nextReviewDay = 0
                
                //关联单词对象
                let pre =  NSPredicate(format: "wordID == %@", "\(id)")
                fetchRequest.predicate = pre
                
                do {
                    //print(id)
                    testList = try context.fetch(fetchRequest)
                    //print(testList)
                    if testList.count > 0 {
                        word.sourceWord = testList[0]  //id唯一
                        //                        print("get\(i)")
                    }
                } catch {
                    NSLog("Error fetching tasks: \(error)")
                }
                
                
            }
            do {
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                try context.save()
                print("后台加载完成")
                //在主队列异步加载一次
                DispatchQueue.main.async {
                    self.getAllItems()
                    self.getKnownWordItems()
                    self.getLearningWordItems()
                    self.getUnlearnedWordItems()
                    self.getDataStats()
                    self.getTodayList(newWordNum:self.UD_newWordNum,learnDayCount:self.UD_learnDayCount)
                    print("重新获取数据完成")
                }
            }
            catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    func deleteAll()  {
        let viewContext = PersistenceController.shared.container.viewContext
        let allItems = NSFetchRequest<NSFetchRequestResult>(entityName: "LearningWordItem")
        let delAllRequest = NSBatchDeleteRequest(fetchRequest: allItems)
        do {
            try viewContext.execute(delAllRequest)
            try viewContext.save()
            print("删除全部数据并保存")
            UD_learnDayCount = 1
            saveToPersistentStoreThenRefresh()
        }
        catch { print(error) }
    }
    
    //保存
    func saveToPersistentStore() {
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
            //getAllItems()
            print("完成保存")
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    //保存
    func saveToPersistentStoreThenRefresh() {
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
            self.getAllItems()
            self.getKnownWordItems()
            self.getLearningWordItems()
            self.getUnlearnedWordItems()
            self.getDataStats()
            self.getTodayList(newWordNum:self.UD_newWordNum,learnDayCount:self.UD_learnDayCount)
            print("完成保存并给对应数据列赋值")
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    
    func nextCard_Learn(item:LearningWordItem,wordStatus:String = "learning") {
        self.todayNewWordList.remove(at: 0)
        print("新词\(item.wordContent ?? "noContent")学习完成")
        item.wordStatus = wordStatus
        item.isSynced = false  //需要同步
        saveToPersistentStore()
        self.showItems(list:self.todayNewWordList)
        
        //最后再来加载复习的单词页面，优化性能表现
        //复习的词也可以分批加载处理，后续再优化（先获取完整列表，再分批载入视图中）
        if todayNewWordList.count == 1 {
            DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.1) { [self] in
                self.getTodayReviewWordItems(learnDayCount: self.UD_learnDayCount)
            }
        }
    }
    
    func nextCard_Review(item:LearningWordItem) {
        //移除这个单词
        self.todayReviewWordList.remove(at: 0)
        item.isSynced = false
        //todayReviewCount 记录每次学习是否认识
        if item.todayReviewCount == 2{
            item.reviewTimes = item.reviewTimes + 1
            //艾宾浩斯曲线设置学习日期
            switch item.reviewTimes {
            case 1:
                item.nextReviewDay = Int16(UD_learnDayCount + 1)
            case 2:
                item.nextReviewDay = Int16(UD_learnDayCount + 2)
            case 3:
                item.nextReviewDay = Int16(UD_learnDayCount + 4)
            case 4:
                item.nextReviewDay = Int16(UD_learnDayCount + 7)
            case 5:
                item.nextReviewDay = Int16(UD_learnDayCount + 15)
            default:
                item.nextReviewDay = -1
                item.wordStatus = "known"
            }
        }else{
            // 没有完成两次认识，就继续添加到队列中
            self.todayReviewWordList.append(item)
            self.showItems(list:self.todayReviewWordList)
        }
        saveToPersistentStore()
        print("\(item.wordContent ?? "noContent")复习")
        //self.showItems(list:self.todayReviewWordList)
    }
    
    func nextCard_Test(item:LearningWordItem) {
        //移除这个单词
        self.randomTestWordList.remove(at: 0)
        //todayReviewCount 记录每次学习是否认识
        if item.todayReviewCount == 2{
            print("测试完成")
        }else{
            // 没有完成两次认识，就继续添加到队列中
            self.randomTestWordList.append(item)
            self.showItems(list:self.todayReviewWordList)
        }
        saveToPersistentStore()
        print("\(item.wordContent ?? "noContent")复习")
        //self.showItems(list:self.todayReviewWordList)
    }
    
    func showItems(list:[LearningWordItem]) {
        var tmp:[String] = []
        var tmp2:[Int16] = []
        for item in list {
            tmp.append(item.wordContent ?? "null")
            tmp2.append(item.nextReviewDay)
        }
        print(tmp)
        //下次复习时间
        //print(tmp2)
    }
    
    func uploadToCloud() {
        self.isSyncing = true //同步开始
        print("开始同步")
        
        // 获取用户名
        let user = LCApplication.default.currentUser?.username?.stringValue ?? "Anonymous"
        
        //获取未同步的数据
        var dataToUpload:[LearningWordItem] = []
        let fetchRequest: NSFetchRequest<LearningWordItem> = LearningWordItem.fetchRequest()
        
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
            
            let query = LCQuery(className: "LearningWordItem")
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
                            let updateItem = LCObject(className: "LearningWordItem", objectId: "\(wordItem_lean.objectId?.value ?? "0")")
                            try updateItem.set("reviewTimes", value: LCNumber(integerLiteral: Int(wordItem.reviewTimes)))
                            try updateItem.set("nextReviewDay", value: LCNumber(integerLiteral: Int(wordItem.reviewTimes)))
                            try updateItem.set("wordStatus", value: LCString(wordItem.wordStatus ?? "unlearned"))
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
                    let wordItem_lean = LCObject(className: "LearningWordItem")
                    
                    try wordItem_lean.set("wordID", value: LCNumber(integerLiteral: Int(wordItem.wordID)))
                    try wordItem_lean.set("wordContent", value: LCString(wordItem.wordContent ?? "noContent"))
                    try wordItem_lean.set("reviewTimes", value: LCNumber(integerLiteral: Int(wordItem.reviewTimes)))
                    try wordItem_lean.set("nextReviewDay", value: LCNumber(integerLiteral: Int(wordItem.reviewTimes)))
                    try wordItem_lean.set("wordStatus", value: LCString(wordItem.wordStatus ?? "unlearned"))
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
        
        //保存CoreData
        saveToPersistentStore()
    }
    
    func downloadFromCloud() {
        self.isSyncing = true
        
        if allWordsToLearnList.count == 0{
            DispatchQueue.main.async {
                self.preloadLearningWordFromCoreData(bookName: bookName2Tag(book: self.UD_Cloud_learningBook))
            }
        }
        
        let viewContext = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<LearningWordItem> = LearningWordItem.fetchRequest()
        var tmpList:[LearningWordItem] = []
        
        let user = LCApplication.default.currentUser?.username?.stringValue ?? "Anonymous"
        let query = LCQuery(className: "LearningWordItem")
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
                            print(tmpList[0].wordContent ?? "noContent")
                            tmpList[0].reviewTimes = Int16(wordItem_cloud.get("reviewTimes")?.intValue ?? 0)
                            tmpList[0].nextReviewDay = Int16(wordItem_cloud.get("nextReviewDay")?.intValue ?? 0)
                            tmpList[0].wordStatus = wordItem_cloud.get("wordStatus")?.stringValue
                            tmpList[0].isSynced = true
                            
                            //云端状态
                            try wordItem_cloud.set("isDownloaded", value: LCBool(true))
                            objects.append(wordItem_cloud)
                        }
                    } catch {
                        NSLog("Error fetching tasks: \(error)")
                    }
                }
                self.saveToPersistentStoreThenRefresh()
                
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
