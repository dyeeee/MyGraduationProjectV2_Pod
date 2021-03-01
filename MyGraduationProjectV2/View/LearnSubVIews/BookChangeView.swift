//
//  BookChangeView.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/2/19.
//

import SwiftUI

struct BookChangeView: View {
    @StateObject var wordVM: WordViewModel
    @StateObject var learnWordVM: LearnWordViewModel
    
    @State var firstSelect = false
    @State var keepAlert = false
    @State var isKeepKnownWords = false
    @State var isKeepKnownWords_Tag = "不保留"
    @State var changeAlert = false
    
    @AppStorage("UD_learningBook") var UD_learningBook = ""
    
    @AppStorage("UD_learningBook_tmp") var UD_learningBook_tmp = ""
    
    @State var selectedBookTag = ""
    
    var bookList:[String] = ["中考英语","高考英语","大学英语四级","大学英语六级","考研英语","雅思词汇","托福词汇","GRE词汇"]
    var bookList_Tags:[String] = ["zk","gk","cet4","cet6","ky","ielts","toefl","gre"]
    var bookDescription:[String] =
        ["中考, 初中学业水平考试（The Academic Test for the Junior High School Students）",
         "高考, 普通高等学校招生全国统一考试\n（Nationwide Unified Examination for Admissions to General Universities and Colleges）",
         "四级, 大学英语四级考试（College English Test Band 4）",
         "六级, 大学英语六级考试（College English Test Band 6）",
         "考研, 全国硕士研究生统一招生考试（Unified National Graduate Entrance Examination）",
         "IELTS, 国际英语测试系统（International English Language Testing System）",
         "TOEFL, 对非英语国家留学生的英语考试（Test of English as a Foreign Language）",
         "GRE, 美国研究生入学考试（Graduate Record Examination）"]
    
    var body: some View {
        ZStack {
            List {
                Section(header:Text("单词书列表")){
                    if UD_learningBook != "" {
                        VStack{
                            Text("学习中的课本: 《\(UD_learningBook)》")
                                .font(.headline)
                        }
                    }
                    
                    ForEach(0..<(bookList.count)){ index in
                        HStack {
                            ZStack {
                                Image(systemName: UD_learningBook_tmp == bookList[index]  ? "hexagon.fill" : "hexagon")
                                    .foregroundColor(Color(.systemIndigo))
                                Image(systemName: "hexagon")
                            }
                            
                            VStack(alignment:.leading) {
                                Text(bookList[index])
                                    .font(.callout)
                                Text(bookDescription[index])
                                    .font(.caption2)
                                    .foregroundColor(Color(.systemGray))
                            }.onTapGesture(perform: {
                                UD_learningBook_tmp = bookList[index]
                                selectedBookTag = bookList_Tags[index]
                            })
                        }
                        //                    .frame(width:UIScreen.main.bounds.width)
                        //                    .background(Color(.blue))
                    }
                }
                
                if !firstSelect{
                    Section(header:Text("设置")){
                        HStack{
                            //Text("保留已掌握的单词")
                            Toggle("保留已掌握的单词", isOn: $isKeepKnownWords)
                        }.onChange(of: isKeepKnownWords, perform: { _ in
                            if isKeepKnownWords{
                                isKeepKnownWords_Tag = "保留"}
                            else{
                                isKeepKnownWords_Tag = "不保留"
                            }
                        })
                    }
                }
                
                
                
                
            }.listStyle(InsetGroupedListStyle())
            .onAppear(perform: {
                if !firstSelect{
                    //print("不是首次选择")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
                        keepAlert = true
                    }
                }
            })
            .onDisappear(perform: {
                //重置选择的显示
                UD_learningBook_tmp = UD_learningBook
            })
            .alert(isPresented: $keepAlert, content: {
                Alert(title: Text("是否保留已掌握的单词"), message: Text("若变更后的单词书中有已掌握的单词，可以保留单词记录"), primaryButton: .destructive(Text("不保留")),
                      secondaryButton: .cancel(Text("保留"), action:{ isKeepKnownWords = true
                        isKeepKnownWords_Tag = "保留"
                      }))
            })
            
            
            if learnWordVM.isLoading{
                LoadingView()
            }
        }.navigationBarItems(trailing: Button(action:{
            if !firstSelect{
                changeAlert = true
            }else{
                //首次选择直接选，非首次选择弹出提示
                UD_learningBook = UD_learningBook_tmp
                learnWordVM.selectLearnBook(bookName: selectedBookTag, isKeep: isKeepKnownWords)
            }
        }
        ,label:{
            Text("使用该课本")
        })
        .alert(isPresented: $changeAlert, content: {
            Alert(title: Text("单词书选择确认"), message: Text("从《\(UD_learningBook)》变更为《\(UD_learningBook_tmp)》\n已掌握的单词: \(isKeepKnownWords_Tag)"), primaryButton: .destructive(Text("取消")), secondaryButton: .cancel(Text("确认"), action:{
                UD_learningBook = UD_learningBook_tmp
                learnWordVM.selectLearnBook(bookName: selectedBookTag, isKeep: isKeepKnownWords)
            }))
        })
        .foregroundColor(UD_learningBook_tmp != UD_learningBook ? Color(.systemBlue) : Color(.systemGray2))
        .disabled(UD_learningBook_tmp != UD_learningBook ? false : true)
        )
    }
}

struct BookChangeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            BookChangeView(wordVM: WordViewModel(), learnWordVM: LearnWordViewModel(),firstSelect: false)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
