//
//  LearningWordListVIew.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/20.
//

import SwiftUI

struct LearningWordListVIew: View {
    @StateObject var learnWordVM: LearnWordViewModel
    @StateObject var wordVM: WordViewModel
    
    @State var noteTypeIndex = 0
    let alphaList = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    var body: some View {
        //NavigationView{
        ScrollViewReader { reader in
            VStack(spacing:0) {
                
                Picker(selection: self.$noteTypeIndex, label: Text("Picker"), content:
                        {
                            Text("学习中").tag(0)
                            Text("未学习").tag(1)
                            Text("已掌握").tag(2)
                            Text("全部单词").tag(3)
                        })
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(5)
                    .padding([.top,.bottom],5)
                    .background(Color(.systemGray6))
                
                
                
                TabView(selection: self.$noteTypeIndex){
                    
                    VStack {
                        //定位到对应id的字母按钮
                        //                            HStack {
                        //                                Image(systemName: "scroll.fill")
                        //                                    HStack(spacing:2.5){
                        //                                            ForEach(self.alphaList,id:\.self){
                        //                                                char in
                        //                                                Button(action: {
                        //                                                    withAnimation{
                        //                                                        reader.scrollTo(char.uppercased())
                        //                                                    }
                        //                                                }, label: {
                        //                                                    FilterLabel(text:char)
                        //                                                })
                        //                                        }
                        //                                        Spacer()
                        //                                    }
                        //                            }
                        //                            .padding(.leading,10)
                        //                            .foregroundColor(Color("WordLevelsColor"))
                        //                            .padding(.bottom,-5)
                        //                            .padding(.top,2)
                        //                            //Text("test")
                        
                        
                        List {
                            Section(header: Text("单词数量：\(self.learnWordVM.learningWordList.count)"), footer: Text("每日学习后更新")){
                                
                                ForEach(self.learnWordVM.learningWordList,id:\.self){
                                    word in
                                    NavigationLink(
                                        destination: WordDetailView(wordItem:self.wordVM.searchItemByID(id: word.wordID),wordVM:wordVM,wordNote: word.sourceWord?.wordNote ?? "nullTag")
                                        //                                            .onAppear(perform: {
                                        //                                                item.latestSearchDate = Date()
                                        //                                                item.historyCount = item.historyCount + 1
                                        //                                            })
                                    )
                                    {
                                        VStack(alignment:.leading){
                                            HStack {
                                                Text(word.wordContent ?? "noContent")
                                                    .font(.title3)
                                                
                                                Text("复习次数: \(word.reviewTimes)").font(.caption)
                                                
                                                Text("下次出现时间: \(word.nextReviewDay)")
                                                    .font(.caption)
                                            }
                                            //                                            Text(dealTrans(word.sourceWord?.translation ?? "noTranslation").replacingOccurrences(of: "\n", with: "; "))
                                            //                                                .font(.footnote)
                                            //                                                .foregroundColor(Color(.systemGray))
                                            //                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                            
                        }
                        .listStyle(InsetGroupedListStyle())
                    }.tag(0)
                    
                    VStack {
                        //定位到对应id的字母按钮
                        //                            HStack {
                        //                                Image(systemName: "scroll.fill")
                        //                                    HStack(spacing:2.5){
                        //                                            ForEach(self.alphaList,id:\.self){
                        //                                                char in
                        //                                                Button(action: {
                        //                                                    withAnimation{
                        //                                                        reader.scrollTo(char.uppercased())
                        //                                                    }
                        //                                                }, label: {
                        //                                                    FilterLabel(text:char)
                        //                                                })
                        //                                        }
                        //                                        Spacer()
                        //                                    }
                        //                            }
                        //                            .padding(.leading,10)
                        //                            .foregroundColor(Color("WordLevelsColor"))
                        //                            .padding(.bottom,-5)
                        //                            .padding(.top,2)
                        //                            //Text("test")
                        
                        
                        List {
                            Section(header: Text("单词数量：\(self.learnWordVM.unlearnedWordList.count)"), footer: Text("每日学习后更新")){
                                ForEach(self.learnWordVM.unlearnedWordList,id:\.self){
                                    word in
                                    NavigationLink(
                                        destination: WordDetailView(wordItem:self.wordVM.searchItemByID(id: word.wordID),wordVM:wordVM,wordNote: word.sourceWord?.wordNote ?? "nullTag")
                                        //                                            .onAppear(perform: {
                                        //                                                item.latestSearchDate = Date()
                                        //                                                item.historyCount = item.historyCount + 1
                                        //                                            })
                                    )
                                    {
                                        VStack(alignment:.leading){
                                            HStack {
                                                Button(action:{
                                                    word.wordStatus = "known"
                                                    learnWordVM.saveToPersistentStore()
                                                    learnWordVM.getKnownWordItems()
                                                    learnWordVM.getUnlearnedWordItems()
                                                    learnWordVM.getDataStats()
                                                },label:{
                                                    VStack {
                                                        Text("已掌握")
                                                            .font(.caption2)
                                                            .padding(2)
                                                            .padding([.top,.bottom],1)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 2.0)
                                                                    .stroke())
                                                    }.foregroundColor(Color("CalendarOnColor"))
                                                }).buttonStyle(PlainButtonStyle())
                                                Text(word.wordContent ?? "noContent")
                                                    .font(.title3)
                                            }
                                            
                                            
                                            //                                            Text(dealTrans(word.sourceWord?.translation ?? "noTranslation").replacingOccurrences(of: "\n", with: "; "))
                                            //                                                .font(.footnote)
                                            //                                                .foregroundColor(Color(.systemGray))
                                            //                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }.tag(1)
                    
                    VStack {
                        
                        List {
                            Section(header: Text("单词数量：\(self.learnWordVM.knownWordList.count)"), footer: Text("每日学习后更新")){
                                ForEach(self.learnWordVM.knownWordList,id:\.self){
                                    word in
                                    NavigationLink(
                                        destination: WordDetailView(wordItem:self.wordVM.searchItemByID(id: word.wordID),wordVM:wordVM,wordNote: word.sourceWord?.wordNote ?? "nullTag")
                                        //                                            .onAppear(perform: {
                                        //                                                item.latestSearchDate = Date()
                                        //                                                item.historyCount = item.historyCount + 1
                                        //                                            })
                                    )
                                    {
                                        VStack(alignment:.leading){
                                            HStack {
                                                Button(action:{
                                                    word.wordStatus = "unlearned"
                                                    learnWordVM.saveToPersistentStore()
                                                    learnWordVM.getKnownWordItems()
                                                    learnWordVM.getUnlearnedWordItems()
                                                    learnWordVM.getDataStats()
                                                },label:{
                                                    VStack {
                                                        Text("重新学习")
                                                            .font(.caption2)
                                                            .padding(2)
                                                            .padding([.top,.bottom],1)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 2.0)
                                                                    .stroke())
                                                    }.foregroundColor(Color("WordLevelsColor"))
                                                }).buttonStyle(PlainButtonStyle())
                                                Text(word.wordContent ?? "noContent")
                                                    .font(.title3)
                                            }
                                            //                                            Text(dealTrans(word.sourceWord?.translation ?? "noTranslation").replacingOccurrences(of: "\n", with: "; "))
                                            //                                                .font(.footnote)
                                            //                                                .foregroundColor(Color(.systemGray))
                                            //                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }.tag(2)
                    
                    VStack {
                        
                        List {
                            Section(header: Text("单词数量：\(self.learnWordVM.allWordsToLearnList.count)")){
                                ForEach(self.learnWordVM.allWordsToLearnList,id:\.self){
                                    word in
                                    NavigationLink(
                                        destination: WordDetailView(wordItem:self.wordVM.searchItemByID(id: word.wordID),wordVM:wordVM,wordNote: word.sourceWord?.wordNote ?? "nullTag")
                                        //                                            .onAppear(perform: {
                                        //                                                item.latestSearchDate = Date()
                                        //                                                item.historyCount = item.historyCount + 1
                                        //                                            })
                                    )
                                    {
                                        VStack(alignment:.leading){
                                            HStack {
                                                Text(word.wordContent ?? "noContent")
                                                    .font(.title3)
                                                Text("复习次数: \(word.reviewTimes)").font(.caption)
                                                
                                                Text("下次出现时间: \(word.nextReviewDay)")
                                                    .font(.caption)
                                            }
                                            //                                            Text(dealTrans(word.sourceWord?.translation ?? "noTranslation").replacingOccurrences(of: "\n", with: "; "))
                                            //                                                .font(.footnote)
                                            //                                                .foregroundColor(Color(.systemGray))
                                            //                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }.tag(3)
                    
                    
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
            }
            .showTabBar()
            .navigationTitle("学习中的单词列表")
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { // <3>
                    Menu{
                        Button(action: {
                            self.learnWordVM.deleteAll()
                        }) {
                            Text("DeleteAll")
                        }
                        Button(action: {
                            self.learnWordVM.preloadLearningWordFromCSV()
                        }) {
                            Label("从CSV加载", systemImage: "tablecells.fill")
                        }
                        Button(action: {
                            self.learnWordVM.preloadLearningWordFromCoreData(bookName:"cet4")
                        }) {
                            Label("从CoreData加载", systemImage: "homepod.fill")
                        }
                        Button(action: {
                            self.learnWordVM.getUnlearnedWordItems()
                            self.learnWordVM.getKnownWordItems()
                            self.learnWordVM.getLearningWordItems()
                        }) {
                            Label("刷新", systemImage: "arrow.2.squarepath")
                        }
                        Button(action: {
                            self.learnWordVM.uploadToCloud()
                        }) {
                            Label("上传", systemImage: "icloud.and.arrow.up")
                        }
                        Button(action: {
                            self.learnWordVM.downloadFromCloud()
                        }) {
                            Label("下载", systemImage: "icloud.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    
                }
            }
        }
    }
    //}
}

struct LearningWordListVIew_Previews: PreviewProvider {
    static var previews: some View {
        LearningWordListVIew(learnWordVM: LearnWordViewModel(), wordVM: WordViewModel())
    }
}
