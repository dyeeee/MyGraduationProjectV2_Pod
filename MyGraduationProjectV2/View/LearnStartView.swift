//
//  LearnStartView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/20.
//

import SwiftUI

struct LearnStartView: View {
    @StateObject var wordVM: WordViewModel = WordViewModel()
    @StateObject var learnWordVM: LearnWordViewModel = LearnWordViewModel()
    @StateObject var dayContentVM: DayContentViewModel
    @StateObject var appearanceVM:AppearanceViewModel
    
    
    @State var progress = 0.8
    
    @State var selectedTag: String?
    
    @AppStorage("UD_learningBook") var UD_learningBook = ""
    @AppStorage("UD_allWordNum") var UD_allWordNum = 1 //单词总量，存在UD里
    @AppStorage("UD_unlearnedWordNum") var UD_unlearnedWordNum = 0 //未学习的总量
    @AppStorage("UD_learningWordNum") var UD_learningWordNum = 0 //学习中的总量
    @AppStorage("UD_knownWordNum") var UD_knownWordNum = 0 //已掌握的总量
    
    @AppStorage("UD_newWordNum") var UD_newWordNum = 10 //用户设定每日新词数量，存在UD里
    @AppStorage("UD_learnDayCount") var UD_learnDayCount = 1
    
    @AppStorage("UD_isLastLearnDone") var UD_isLastLearnDone = false
    
    
    @State var showHistoryCalendar = false
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("进度统计")){
                        
                        VStack(alignment: .leading,spacing:10){
                            HStack {
                                Text("\(UD_learningBook)").font(.headline)
                                Spacer()
                                Text("Day \(UD_learnDayCount)")
                                    .font(.headline)
                                    .padding(3)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke())
                                    .contextMenu {
                                        Button(action: {
                                            UD_isLastLearnDone.toggle()
                                        }) {
                                            Label("今日学习完成切换",systemImage:"switch.2")
                                        }
                                        Button(action: {
                                            setLearnDayTest()
                                            print("learnDayCount:\(UD_learnDayCount)")
                                        }) {
                                            Label("学习天数+1 && 今日学习未完成",systemImage:"plus.circle")
                                        }
                                    }
                                
                            }
                            VStack(alignment:.leading) {
                                HStack{
                                    Text("学习中 \(UD_learningWordNum)")
                                    Text("已掌握 \(UD_knownWordNum)")
                                }.font(.caption)
                                HStack{
                                    Text("剩余新词 \(UD_unlearnedWordNum)")
                                    Text("词汇量 \(UD_allWordNum)")
                                    Text("学习进度 \((Double(UD_knownWordNum)/(Double(UD_allWordNum) + 0.1))*100,specifier: "%.1f")%")
                                }.font(.caption)
                            }
                            
                            HStack {
                                ProgressView(value: (Double(UD_knownWordNum)/(Double(UD_allWordNum) + 0.1)))
                                    .scaleEffect(x: 1.0, y: 2, anchor: .center)
                                    .accentColor(.blue)
                            }
                            
                        }.padding([.top,.bottom],10)
                        VStack{
                            HStack() {
                                VStack{
                                    Text("今日新词")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    Text("\(self.UD_newWordNum)")
                                        .font(.custom("hyg5gjm", size: 18))
                                }
                                VStack{
                                    Text("今日复习")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    Text("\(self.learnWordVM.todayReviewCount)")
                                }
                                Spacer()
                                HStack {
                                    //Button实现navigationlink的写法
                                    Button(action: {
//                                        if isLastLearnDone{
//                                            self.selectedTag = "EmptyTag"
//                                        }
//                                        else{
//                                            self.selectedTag = "LearningView"
//                                        }
                                        //没用，还是会跳转
                                        self.selectedTag = "LearningView"
                                    }, label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(width: 150, height: 30, alignment: .center)
                                            Text(UD_isLastLearnDone ? "今日学习完成":"开始学习")
                                                .foregroundColor(Color(.white))
                                        }.frame(width: 150, height: 30, alignment: .center)
                                    })
                                    .disabled(UD_isLastLearnDone ? true : false)
                                    .foregroundColor(UD_isLastLearnDone ? Color(.systemGray2):Color(.systemBlue))
                                    .background(
                                        NavigationLink(
                                            destination: LearningView(wordVM: self.wordVM, learnWordVM: self.learnWordVM),
                                            tag: "LearningView",
                                            selection: $selectedTag,
                                            label: { EmptyView() }
                                        ).opacity(0.0)
                                        .disabled(UD_isLastLearnDone ? true : false)
                                    )
                                    .buttonStyle(PlainButtonStyle())
                                    
                                }
                            }
                            
                        }.padding([.top,.bottom],10)
                    }
                    
                    Section(header: Text("单词书")){
                        NavigationLink(
                            destination: WordTestView(wordVM: self.wordVM, learnWordVM: self.learnWordVM),
                            label: {
                                HStack(spacing:10) {
                                    Image(systemName: "pencil.and.outline")
                                    Text("单词测试")
                                }
                            })
                        
                        NavigationLink(
                            destination: LearningWordListVIew(learnWordVM: self.learnWordVM, wordVM: self.wordVM),
                            label: {
                                HStack(spacing:10) {
                                    Image(systemName: "doc.text.fill")
                                    Text("单词列表")
                                }
                            })
                        
                        HStack {
                            Spacer()
                            PieChartView(data:self.learnWordVM.wordStatusCount, title: "单词分布",form: ChartForm.custom)
                            Spacer()
                        }
                        
                        
                        NavigationLink(
                            destination: BookChangeView(wordVM: self.wordVM, learnWordVM: self.learnWordVM,firstSelect: false),
                            label: {
                                HStack(spacing:10) {
                                    Image(systemName: "book.fill")
                                    Text("变更单词书")
                                }
                            })
                        
                    }
                    
                    Section(header: Text("学习设置")){
                        
                        NavigationLink(
                            destination: LearnSetView(wordVM: self.wordVM, learnWordVM: self.learnWordVM),
                            label: {
                                HStack(spacing:10) {
                                    Image(systemName: "gearshape.fill")
                                    Text("学习设置")
                                }
                            })
                        
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle("单词学习")
                .navigationBarTitleDisplayMode(.inline)
                .showTabBar()
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button(action:{
                            dayContentVM.isLoading = true
                            print("loading")
                            self.showHistoryCalendar.toggle()
                        },label:{
                            Image(systemName:"calendar")
                        })
                    }
                })
                .sheet(isPresented: $showHistoryCalendar, content: {
                    HistoryCalendarView(dayContentVM:self.dayContentVM,isLoading:.constant(false))
                        .ifIs(Device.deviceType == .iPad && (self.appearanceVM.UD_storedColorScheme != "")){
                            $0.preferredColorScheme(self.appearanceVM.colorScheme)
                        }
                })
                
                if dayContentVM.isLoading{
                    
                    //动画失效？bug待排除
                    //LoadingView()
                    
                    ZStack {
                        ProgressView()
                            .scaleEffect(1.2)
                            .frame(width: 100, height: 100)
                            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).foregroundColor(Color(.systemGray5)))
                            .offset(x: 0, y: -70)
                            .zIndex(1)
                        //Text("加载中") //这样可以，效果待优化
                    }
                    
                }
            }.navigationViewStyle(StackNavigationViewStyle())
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct LearnStartView_Previews: PreviewProvider {
    static var previews: some View {
        LearnStartView(dayContentVM: DayContentViewModel(), appearanceVM: AppearanceViewModel())
    }
}
