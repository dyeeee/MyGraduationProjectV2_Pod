//
//  LearningView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/25.
//

import SwiftUI

struct LearningView: View {
    @StateObject var wordVM: WordViewModel
    @StateObject var learnWordVM: LearnWordViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("UD_allWordNum") var UD_allWordNum = 0 //单词总量，存在UD里
    @AppStorage("UD_unlearnedWordNum") var UD_unlearnedWordNum = 0 //未学习的总量，存在UD里
    @AppStorage("UD_learningWordNum") var UD_learningWordNum = 0 //学习中的总量，存在UD里
    @AppStorage("UD_knownWordNum") var UD_knownWordNum = 0 //已掌握的总量，存在UD里
    
    @AppStorage("UD_newWordNum") var UD_newWordNum = 10 //用户设定每日新词数量，存在UD里
    @AppStorage("UD_learnDayCount") var UD_learnDayCount = 1
    
    @AppStorage("UD_isLastLearnDone") var UD_isLastLearnDone = false
    
    @State var todayAllCount:Int = 36
    @State var todayNewCount:Int = 0
    @State var todayReviewCount:Int = 0
    
    @State var progressWidth = UIScreen.main.bounds.width - 80
    
    var wordExample = ["allow","alleviate","among"]
    
    var body: some View {
        VStack {
            
            //今日复习进度条
            VStack{
                HStack{
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        self.learnWordVM.saveToPersistentStoreThenRefresh()
                    }, label: {
                        Image(systemName: "chevron.left.square")
                            .font(.title)
                    })
                    ZStack(alignment:.leading) {
                        HStack(spacing:0) {
                            ZStack {
                                Rectangle()
                                    .frame(width: progressWidth/CGFloat(self.learnWordVM.todayAllCount)*CGFloat(todayNewCount), height: 25, alignment: .center)
                                    .foregroundColor(Color(.systemBlue))
                                Text(todayNewCount != 0 ? "\(todayNewCount)" : "")
                                
                            }
                            ZStack {
                                Rectangle()
                                    .frame(width: progressWidth/CGFloat(self.learnWordVM.todayAllCount)*CGFloat(todayReviewCount), height: 25, alignment: .center)
                                    .foregroundColor(Color(.systemGreen))
                                Text(todayReviewCount != 0 ? "\(todayReviewCount)" : "")
                            }
                        }
                        ZStack(alignment:.trailing) {
                            RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                                .stroke()
                                .frame(width: progressWidth, height: 25, alignment: .center)
                            Text("剩余: \(self.learnWordVM.todayAllCount - todayReviewCount - todayNewCount)")
                                
                                .padding(.trailing,4)
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 5.0, style: .continuous))
                    Spacer()
                }.padding([.leading,.trailing], 10)
                //                VStack {
                //                    Text("新词\(todayNewCount)")
                //                    Text("复习\(todayReviewCount)")
                //                    Text("总数\(todayAllCount)")
                //                    Text("今日进度\((todayNewCount+todayReviewCount)/todayAllCount)")
                //                }
            }
            //今日复习进度条
            
            //新词
            ZStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color(.systemGray6))
                        .frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
                    Button(action: {
                        self.UD_isLastLearnDone = true
                        
                        self.presentationMode.wrappedValue.dismiss()
                        
                        
                    }, label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("今日学习完成\n(补充统计数据、完成今日打卡)")
                        }
                    })
                }.zIndex(1)
                
                //复习的单词
                ForEach(self.learnWordVM.todayReviewWordList.reversed(), id: \.self) {
                    wordItem in
                    ReviewCardRouterView(learningWordItem: wordItem, learnWordVM: self.learnWordVM, wordVM: self.wordVM, todayReviewCount: self.$todayReviewCount)
                }.zIndex(2)
                
                //新学的单词
                ForEach(self.learnWordVM.todayNewWordList.reversed(), id: \.self) {
                    wordItem in
                    LearnCardView(learningWordItem: wordItem, learnWordVM: self.learnWordVM, wordVM: self.wordVM, todayNewCount: self.$todayNewCount)
                }.zIndex(3)
            }
            //.frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
            .overlay(
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .stroke(Color.black.opacity(0.2), lineWidth: 1.0)
            )
            
            //底部
            VStack{
                HStack{
                    Text("")
                }
            }.padding([.top,.bottom],10)
            //底部
        }
        .navigationBarHidden(true)
        .background(Color(.systemGray6)
                        .frame(width: UIScreen.main.bounds.width)
                        .edgesIgnoringSafeArea(.all))
        .hiddenTabBar()
        .ignoresSafeArea(edges:.bottom)
        .onAppear(perform: {
            //获取今天的词
            self.learnWordVM.getTodayList(newWordNum: UD_newWordNum, learnDayCount: UD_learnDayCount,byOnAppear: true)
        })
        .onDisappear(perform: {
            self.learnWordVM.getKnownWordItems()
            self.learnWordVM.getLearningWordItems()
            self.learnWordVM.getUnlearnedWordItems()
            self.learnWordVM.getDataStats()
        })
    }
}

struct LearningView_Previews: PreviewProvider {
    static var previews: some View {
        LearningView(wordVM: WordViewModel(), learnWordVM: LearnWordViewModel())
    }
}
