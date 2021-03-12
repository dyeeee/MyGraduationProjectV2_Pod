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

let previewData = [WidgetWord(wordContent: "abstract", phonetic_EN: "'æbstrækt", wordTags:"gk cet4 cet6 ky toefl ielts gre",definition: "v. consider a concept without thinking of a specific example; consider abstractly or theoretically\n[v.] consider apart from a particular case or instance\n[v.] give an abstract (of)\n[a.] existing only in the mind; separated from embodiment", translation: "[a.] 抽象的, 深奥的\n[n.] 摘要, 抽象概念\n[vt.] 摘要, 提炼", exampleSentences: "Someone once told me a vivid and silly visualization can help people to understand an abstract concept. Let's see if it works.<br>曾经有人告诉我，生动而简单的可视化可以帮助人们理解抽象概念。让我们看看它是否有效。")]

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


func dealEN_Widget(_ en:String) -> String {
    var enString = "/"
    enString.append(en)
    enString.append("/")
    return enString
}

//a. 抽象的, 深奥的\nn. 摘要, 抽象概念\nvt. 摘要, 提炼, 使抽象化\n[计] 摘录; 摘要; 抽象

public func dealTrans_Widget(_ rawTrans:String) -> String {
    let pattern1 = "^(vt|n|a|adj|adv|v|pron|prep|num|art|conj|vi|interj|r)(\\.| )"
    let regex1 = try! Regex(pattern1)
    
    //只替换第1个匹配项
    let out1 = regex1.replacingMatches(in: rawTrans, with: "[$1.] ", count: 1)
    
    
    
    let pattern2 = "n(vt|n|a|adj|adv|v|pron|prep|num|art|conj|vi|interj|r)(\\.| )"
    let regex2 = try! Regex(pattern2)
    //替换所有匹配项
    let out2 = regex2.replacingMatches(in: out1, with: "n[$1.] ")
    
    //        //输出结果
    //        print("原始的字符串：", rawTrans)
    //        print("替换第1个匹配项：", out1)
    //        print("替换所有匹配项：", out2)
    
    let result = out2.replacingOccurrences(of: "\\n", with: "\n")
    return result
}

func getTagsList_Widget(str:String,limit:Int = 4) -> [String] {
    var tagsString = str
    tagsString = tagsString.replacingOccurrences(of: "zk", with: "中")
    tagsString = tagsString.replacingOccurrences(of: "gk", with: "高")
    tagsString = tagsString.replacingOccurrences(of: "cet4", with: "四")
    tagsString = tagsString.replacingOccurrences(of: "cet6", with: "六")
    tagsString = tagsString.replacingOccurrences(of: "ky", with: "研")
    //tagsString = tagsString.replacingOccurrences(of: "toefl", with: "TOL")
    tagsString = tagsString.uppercased()
    var tagsList:[String] = tagsString.components(separatedBy: " ")
    if tagsList.count > limit{
        tagsList = Array(tagsList.prefix(limit))
        tagsList.append("...")
    }
    return tagsList
}
