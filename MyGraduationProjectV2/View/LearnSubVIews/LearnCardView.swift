//
//  LearnCardView.swift
//  MyGraduationProjectV1
//
//  Created by YES on 2021/1/26.
//

import SwiftUI

struct LearnCardView: View {
    @StateObject var learningWordItem:LearningWordItem
    @StateObject var learnWordVM: LearnWordViewModel
    @StateObject var wordVM:WordViewModel
    
    @Binding var todayNewCount:Int
    
    var body: some View {
        ZStack(alignment:.center) {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color.white)
                
            
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        Text("新单词")
                            .font(.callout)
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2.0)
                                    .stroke())
                    }.foregroundColor(Color("WordTagsColor"))
                        .padding(.top,20)
                    Spacer()
                }
                
                HStack {
                    VStack(alignment:.leading) {
                        HStack {
                            VStack {
                                    Text(self.learningWordItem.wordContent ?? "noContent")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.clear)
                                        .overlay(Rectangle().frame(height:6)
                                                    .foregroundColor(Color.blue.opacity(0.8))
                                                    .offset(x:0,y:12))
                                }.overlay(
                                    Text(self.learningWordItem.wordContent ?? "noContent")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                            )
                            Spacer()
//                            Button(action: {
//                                self.learningWordItem.nextReviewDay = -1
//                                self.learnWordVM.nextCard_Learn(item: self.learningWordItem,wordStatus: "known")
//                                self.todayNewCount = self.todayNewCount + 1
//                            }, label: {
//                                VStack {
//                                    Text("已掌握")
//                                        .font(.callout)
//                                        .padding(2)
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 2.0)
//                                                .stroke())
//                                }.foregroundColor(Color("CalendarOnColor"))
//                            })
                        }
                        
                        WordPhoneticView(phonetic_EN: self.learningWordItem.sourceWord?.phonetic_EN ?? "no phonetic_EN", phonetic_US: self.learningWordItem.sourceWord?.phonetic_US ?? "no phonetic_US",fontSize: 18)
                            .padding(.top, -5)
                    }
                    
                    Spacer()
                }.padding([.leading,.trailing],20)
                    
                    
                Divider()
                VStack(alignment:.leading) {
                    WordTranslationView(wordTranslastion: self.learningWordItem.sourceWord?.translation ?? "no Trans", wordDefinition: self.learningWordItem.sourceWord?.definition ?? "no Def")
                    
                    Divider()
                    
                    VStack(alignment:.leading){
                        Text("例句")
                            .font(.callout)
                            .foregroundColor(Color("WordSentencesColor"))
                        ScrollView {
                            WordExampleSentencesView(wordContent: self.learningWordItem.wordContent!, wordExampleSentences: self.learningWordItem.sourceWord?.exampleSentences ?? "noEXP",maxLine:1,showCH:true)
                        }
                    }
                }.padding([.leading,.trailing],20)
                
                    
                
                
                Spacer()
                
                Divider()
                // 底部按钮
                HStack {
                    Spacer()
                            HStack {
                                //Spacer()
                                Button(action: {
                                    self.learnWordVM.nextCard_Learn(item: self.learningWordItem)
                                    self.todayNewCount = self.todayNewCount + 1
                                }, label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                            .frame(width: UIScreen.main.bounds.width*0.75, height: 40, alignment: .center)
                                            .foregroundColor(Color(red: 245/255, green: 245/255, blue: 250/255))
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text("记住了").font(.custom("FZDIHT_JW--GB1-0", size: 18,relativeTo: .title))
                                        }.foregroundColor(Color(.systemGreen))
                                    }
                            })
                                //Spacer()
                            }
                    Spacer()
                }
                .padding(10)
                .padding(.bottom,5)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                
                //                    }
            }//.padding(.top,0)
            
            
        }
        .frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
    }
}

struct LearnCardView_Previews: PreviewProvider {
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
                    LearnCardView(learningWordItem: learnWord, learnWordVM: LearnWordViewModel(), wordVM: WordViewModel(), todayNewCount: .constant(0))
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
