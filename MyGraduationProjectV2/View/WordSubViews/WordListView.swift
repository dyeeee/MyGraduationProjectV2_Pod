//
//  WordListView.swift
//  MyVocabularyBook
//
//  Created by YES on 2020/11/24.
//

import SwiftUI


enum WordListType {
    case searchResult
    case notebook
    case history
    case all
}

//通用的单词列表界面
struct WordListView: View {
    @StateObject var wordVM: WordViewModel
    @State private var searchText = ""
    @State var dataType: WordListType = .all
    
    //延时查询优化性能表现
    @State var timeRemaining = 10
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var searching = false
    
    @AppStorage("UD_searchHistoryCount") var UD_searchHistoryCount = 0
    
    
    var body: some View {
        //        NavigationView{
        List{
            //            if(dataType == .searchResult){
            Section(header: Text("查询")){
                HStack {
                    TextField("", text: $searchText)
//                        .onChange(of: searchText, perform: { value in
//                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
//                                self.wordVM.searchItems(begins: self.searchText)
//                            }
//                        })
                        .onChange(of: searchText, perform: { _ in
                            //每次更改都重置计时器，直到停止输入一秒后才执行搜索操作
                            timeRemaining = 1
                            startTimer()
                        })
                    Button(action: {
                        self.wordVM.searchItems(begins: self.searchText)
                    }, label: {
                        Image(systemName:"magnifyingglass")
                    })
                }
            }
            //            }
            
            if (self.wordVM.getItems(self.dataType).count != 0 && self.searchText != "") {
            Section(header: Text("\(headerText(self.dataType))")) {
                ForEach(self.wordVM.getItems(self.dataType),id:\.self){
                    item in
                    NavigationLink(
                        destination: WordDetailView(wordItem:item,wordVM:wordVM,wordNote: item.wordNote ?? "nullTag")
                            .onAppear(perform: {
                                item.latestSearchDate = Date()
                                item.searchCount = item.searchCount + 1
                                item.isSynced = false
                                UD_searchHistoryCount = UD_searchHistoryCount + 1
                            })
                    )
                    {
                        VStack(alignment:.leading){
                            Text(item.wordContent ?? "noContent")
                                .font(.title3)
                            
                            Text(dealTrans(item.translation ?? "noTranslation").replacingOccurrences(of: "\n", with: "; "))
                                .font(.footnote)
                                .foregroundColor(Color(.systemGray))
                                .lineLimit(1)
                        }
                    }
                }
            }
            }
            
            Section(header: Text("查询历史")) {
                ForEach(self.wordVM.getItems(.history),id:\.self){
                    item in
                    NavigationLink(
                        destination:
                            WordDetailView(wordItem:item,wordVM:wordVM,wordNote: item.wordNote ?? "nullTag")
                            .onAppear(perform: {
                                item.latestSearchDate = Date()
                                item.searchCount = item.searchCount + 1
                                item.isSynced = false
                                UD_searchHistoryCount = UD_searchHistoryCount + 1
                                
//                                print("历史记录数量\(UD_searchHistoryCount)")
                            })
                    )
                    {
                        VStack(alignment:.leading){
                            Text(item.wordContent ?? "noContent")
                                .font(.title3)
                            
                            Text(dealTrans(item.translation ?? "noTranslation").replacingOccurrences(of: "\n", with: "; "))
                                .font(.footnote)
                                .foregroundColor(Color(.systemGray))
                                .lineLimit(1)
                        }
                    }
                }
            }
            
        }
        .listStyle(InsetGroupedListStyle())
        //        .environment(\.horizontalSizeClass, .regular)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
            if self.timeRemaining == 0 && self.searchText != ""{
                //执行搜索操作
                searching.toggle()
                self.wordVM.searchItems(begins: self.searchText)
                stopTimer()
            }
        }
        .onAppear() {
            //挂起计时器
            self.stopTimer()
        }
    }
    
    func stopTimer() {
        self.timer.upstream.connect().cancel()
    }
    
    func startTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    func headerText(_ dataType:WordListType) -> String {
        if self.dataType == .searchResult {
            return "Result"
        }else if self.dataType == .history {
            return "History"
        }else
        {return "test"}
    }
    
    func showHistory(_ wordList: [WordItem]) -> Bool {
        if wordList.count == 0 {
            return true
        }
        else
        {
            return false
        }
    }
}

struct WordListView_Previews: PreviewProvider {
    static var previews: some View {
        WordListView(wordVM: WordViewModel(),dataType: .searchResult)
    }
}

