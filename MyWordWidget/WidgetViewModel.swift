//
//  WidgetViewModel.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/3/11.
//

import Foundation
import CoreData
import SwiftUI



struct WidgetWord: Identifiable{
    let wordContent:String
    let phonetic_EN:String
    let wordTags:String
    let definition:String
    let translation:String
    
    let exampleSentences:String
    
    var id:String{
        wordContent
    }
}


let widgetData = [WidgetWordModel(seed: 0).wordList[0],WidgetWordModel(seed: 1).wordList[1],WidgetWordModel(seed: 2).wordList[2],WidgetWordModel(seed: 3).wordList[3],WidgetWordModel(seed: 4).wordList[4]]

let previewData = [WidgetWord(wordContent: "abstract", phonetic_EN: "'æbstrækt", wordTags:"gk cet4 cet6 ky toefl ielts gre",definition: "v. consider a concept without thinking of a specific example; consider abstractly or theoretically\nv. consider apart from a particular case or instance\nv. give an abstract (of)\na. existing only in the mind; separated from embodiment", translation: "a. 抽象的, 深奥的\nn. 摘要, 抽象概念\nvt. 摘要, 提炼, 使抽象化\n[计] 摘录; 摘要; 抽象", exampleSentences: "Someone once told me a vivid and silly visualization can help people to understand an abstract concept. Let's see if it works. . .<br>曾有人告诉我一个明晰而无聊的可视物能帮助人们理解抽象的理论，让我们来看看当它工作时……<br>Abstract: traditional chinese medicine, known as an ancient medical science is marked by its obscurity and difficulty in terms of theory.")]

class WidgetWordModel {
    var wordList:[WidgetWord] = []
    
    init(seed:Int) {
        getSomeWidgetWord(seed: seed)
    }
    
    func getSomeWidgetWord(seed:Int)  {
        let viewContext = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<WordItem> = WordItem.fetchRequest()
        ////        let pre =  NSPredicate(format: "starLevel > %@", starLevelFilter)
        
        //随机数（上限调整为总词库数量）
          fetchRequest.fetchOffset = seed //Int.random(in: 0...5000)
        
        fetchRequest.fetchLimit = 5
        
        var tmpList:[WordItem] = []
        do {
            //获取所有的Item
            tmpList = try viewContext.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
        }
        for item in tmpList {
            let widgetWord = WidgetWord(wordContent: item.wordContent ?? "wordContent", phonetic_EN: item.phonetic_EN ?? "phonetic_EN", wordTags: item.wordTags ?? "wordTags", definition: item.definition ?? "definition" , translation: item.translation ?? "translation" , exampleSentences: item.exampleSentences ?? "exampleSentences")
            
            wordList.append(widgetWord)
            
        }
    }
}
