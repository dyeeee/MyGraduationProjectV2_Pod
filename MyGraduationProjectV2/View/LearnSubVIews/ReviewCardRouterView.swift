//
//  ReviewCardRouterView.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/3/7.
//

import SwiftUI

struct ReviewCardRouterView: View {
    @StateObject var learningWordItem:LearningWordItem
    @StateObject var learnWordVM: LearnWordViewModel
    @StateObject var wordVM:WordViewModel
    
    @State var afterUnknown:Bool = false
    @Binding var todayReviewCount:Int  //绑定外部视图的今日进度统计
    
    var cardType = 2
    
    var body: some View {
        ZStack{
            if learningWordItem.todayReviewCount == 0 {
            ReviewCardView(learningWordItem: learningWordItem, learnWordVM: self.learnWordVM,
                           wordVM: self.wordVM, todayReviewCount: self.$todayReviewCount)
                .hiddenTabBar()
        }else if learningWordItem.todayReviewCount == 1{
            ReviewCardView2(learningWordItem: learningWordItem, learnWordVM: self.learnWordVM,
                            wordVM: self.wordVM, todayReviewCount: self.$todayReviewCount)
                .hiddenTabBar()
        }}.onAppear(perform: {
            
        })
    }
}

struct ReviewCardRouterView_Previews: PreviewProvider {
    static var previews: some View {
        let wordItem = WordItem(context: PersistenceController.preview.container.viewContext)
        wordItem.wordID = 24543
        wordItem.starLevel = 3
        wordItem.wordContent = "alleviate"
        wordItem.phonetic_EN = "ә'li:vieit"
        wordItem.phonetic_US = "[ə'livɪ'et]"
        wordItem.definition = "v provide physical relief, as from pain\nv make easier"
        wordItem.translation = "vt. 减轻, 使缓和"
        wordItem.collinsLevel = 1
        wordItem.wordTags = "cet6 ky toefl ielts gre"
        wordItem.bncLevel = 7706
        wordItem.frqLevel = 55
        wordItem.wordExchanges = "d:alleviated/i:alleviating/3:alleviates/p:alleviated"
        wordItem.exampleSentences = "Excuse me what eyedrop can be treated or to what eyedrop can be treated or alleviate myopic eyedrop ah?<br>请问一下有没有什么眼药水可以治疗或缓解近视的眼药水啊？<br>And ease the tension in the form of many, why not bring serious harm to the body of a factor to alleviate it?<br>而且缓解紧张情绪的形式很多，为什么非要拿一个严重危害身体的因素来缓解呢？<br>The reason that cats can alleviate negative moods is often attributed to attachment - the emotional bond between cat and owner.<br>猫能够改善人们负性情绪的原因往往都归于他们对人的依恋——猫与主人间的感情粘合剂。<br>"
        
        wordItem.wordNote = ""
        
        let learnWord = LearningWordItem(context: PersistenceController.preview.container.viewContext)
        learnWord.wordID = 24543
        learnWord.wordContent = "alleviate"
        learnWord.sourceWord = wordItem
        
        return
            VStack {
                VStack{
                    HStack{
                        Button(action: {
                            
                        }, label: {
                            Text("Back")
                        })
                        Rectangle()
                            .frame(width: 200, height: 20, alignment: .center)
                            .foregroundColor(Color(.systemTeal))
                        
                        Button(action: {
                            
                        }, label: {
                            Text("get")
                        })
                    }
                }
                
                ZStack {
                    ReviewCardRouterView(learningWordItem: learnWord, learnWordVM: LearnWordViewModel(), wordVM: WordViewModel(),afterUnknown: false, todayReviewCount: .constant(0))
                        //.frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                                .stroke(Color.black.opacity(0.2), lineWidth: 1.0)
                        )
                        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                    //.navigationBarTitleDisplayMode(.inline)
                    //.ignoresSafeArea(edges: .bottom)
                    
                }
                
                
                
            }
    }
}
