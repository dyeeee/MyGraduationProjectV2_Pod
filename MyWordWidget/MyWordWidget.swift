//
//  MyWordWidget.swift
//  MyWordWidget
//
//  Created by YES on 2021/3/11.
//

import WidgetKit
import SwiftUI



struct WidgetWordEntry: TimelineEntry {
    let date: Date
    let word: WidgetWord
}


struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> WidgetWordEntry {
        WidgetWordEntry(date: Date(), word: previewData[0])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetWordEntry) -> Void) {
        let entry = WidgetWordEntry(date: Date(), word: previewData[0])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetWordEntry>) -> Void) {
        var entries: [WidgetWordEntry] = []
        
        let currentDate  = Date()
        let widgetSeed = Int.random(in: 0...5000)
        let list = WidgetWordModel(seed: widgetSeed).wordList
        
        //每给组件开始的时候获取一个seed，按照seed找5个单词出来
        for i in 0 ..< 5 {
            //测试的时候10秒刷新一次,正式使用改成hour（5个小时每个小时刷新一次）
            //从当前时间开始，+5*i*时间单位 个数据流
            let entryDate = Calendar.current.date(byAdding: .hour, value: 5*i, to: currentDate)!
            let entry = WidgetWordEntry(date: entryDate, word: list[i])

            entries.append(entry)
        }
        

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    //typealias Entry = WidgetWordEntry
    
}

struct PlaceholderView:View {
    var body: some View{
        WidgetWordView_Small(widgetWord: widgetData[0])
    }
}

struct WidgetEntryView:View {
    let entry:Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View{
        switch family {
        case .systemSmall:
            ZStack {
                WidgetWordView_Small(widgetWord: entry.word)
            }
        case .systemMedium:
            ZStack {
                WidgetWordView_Medium(widgetWord: entry.word)
            }
        default:
            ZStack {
                WidgetWordVIew_Large(widgetWord: entry.word)
            }
        }
    }
}


@main
struct MyWordWidget: Widget {
    private let kind = "MyWordWidget"
    var body: some WidgetConfiguration{
        StaticConfiguration(kind: kind, provider: Provider()){
            entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("E-Word")
        .description("添加学习卡片小组件\n随时学习新单词")
        .supportedFamilies([.systemSmall,.systemMedium,.systemLarge])

    }
    
}

//CoreData没法预览
struct MyWordWidget_Previews: PreviewProvider {
    static var previews: some View {
        let demo = WidgetWord(wordContent: "abstract", phonetic_EN: "'æbstrækt", wordTags:"gk cet4 cet6 ky toefl ielts gre",definition: "v. consider a concept without thinking of a specific example; consider abstractly or theoretically\n[v.] consider apart from a particular case or instance\n[v.] give an abstract (of)\n[a.] existing only in the mind; separated from embodiment", translation: "[a.] 抽象的, 深奥的\n[n.] 摘要, 抽象概念\n[vt.] 摘要, 提炼", exampleSentences: "Someone once told me a vivid and silly visualization can help people to understand an abstract concept. Let's see if it works.<br>曾经有人告诉我，生动而简单的可视化可以帮助人们理解抽象概念。让我们看看它是否有效。")
        
        
        return Group {
            WidgetEntryView(entry: WidgetWordEntry(date: Date(), word: demo))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetEntryView(entry: WidgetWordEntry(date: Date(), word: demo))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            WidgetEntryView(entry: WidgetWordEntry(date: Date(), word: demo))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                }
        

    }
}
