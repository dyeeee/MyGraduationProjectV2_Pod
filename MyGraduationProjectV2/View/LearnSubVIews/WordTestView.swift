//
//  WordTestView.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/5/4.
//

import SwiftUI


struct WordTestView: View {
    @StateObject var wordVM: WordViewModel
    @StateObject var learnWordVM: LearnWordViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var todayReviewCount:Int = 0
    
    @AppStorage("UD_testWordNum") var UD_testWordNum = 5
    
    var body: some View {
        VStack {
            Text(" ")
            
            //
            ZStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color(.systemGray6))
                        .frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("小测完成")
                        }
                    })
                }.zIndex(1)
                
                ForEach(self.learnWordVM.randomTestWordList.reversed(), id: \.self) {
                    wordItem in
                    TestCardRouterView(learningWordItem: wordItem, learnWordVM: self.learnWordVM, wordVM: self.wordVM, todayReviewCount: self.$todayReviewCount)
                }.zIndex(2)

            }
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
//        .navigationBarHidden(true)
        .background(Color(.systemGray6)
                        .frame(width: UIScreen.main.bounds.width)
                        .edgesIgnoringSafeArea(.all))
        .hiddenTabBar()
        .ignoresSafeArea(edges:.bottom)
        .onAppear(perform: {
            //获取词
            self.learnWordVM.getWordTestWordItems(num:UD_testWordNum)

        })
        .onDisappear(perform: {
            self.learnWordVM.randomTestWordList = []
        })
    }
}

struct WordTestView_Previews: PreviewProvider {
    static var previews: some View {
        WordTestView(wordVM: WordViewModel(), learnWordVM: LearnWordViewModel())
    }
}
