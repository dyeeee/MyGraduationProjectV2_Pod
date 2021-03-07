//
//  ReviewCard2.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/3/7.
//

import SwiftUI


//一张复习卡片
struct ReviewCardView2: View {
    @StateObject var learningWordItem:LearningWordItem
    @StateObject var learnWordVM: LearnWordViewModel
    @StateObject var wordVM:WordViewModel
    
    @State var afterUnknown:Bool = false
    @Binding var todayReviewCount:Int  //绑定外部视图的今日进度统计
    
    @State var text = ""
    @State var correctWord = false
    
    var body: some View {
        //        if showThisCard {
        ZStack(alignment:.center) {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(afterUnknown ? Color(.systemGray6) : Color.white)
            
            
            VStack {
                HStack {
                    Spacer()
                    todayReviewCountView(reviewCount: self.learningWordItem.todayReviewCount)
                        .padding(.top,15)
                    Spacer()
                }
                
                if afterUnknown {
                    WordDetailView(wordItem: self.learningWordItem.sourceWord ?? WordItem(), wordVM: self.wordVM)
                    //.frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
                }
                else{
                    HStack {
                        VStack(alignment:.leading) {
                            HStack {
                                VStack {
                                    //                            Text("\(self.learningWordItem.todayReviewCount)")
                                    Text(self.learningWordItem.wordContent ?? "noContent")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.clear)
                                    //                            .overlay(Rectangle().frame(height:6)
                                    //                                        .foregroundColor(Color.blue.opacity(0.8))
                                    //                                        .offset(x:0,y:18))
                                }.overlay(
                                    TextField("Input", text: $text)
                                        .autocapitalization(.none)
                                        .foregroundColor(correctWord ? Color(.systemBlue) : Color(.systemRed))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: text, perform: { text in
                                            if text == self.learningWordItem.wordContent{
                                                correctWord = true
                                            }else{
                                                correctWord = false
                                            }
                                        })
                                )
                                .padding([.top],10)
                                
                                Spacer()
                                Button(action: {}, label: {
                                    VStack {
                                        Text("已掌握")
                                            .font(.callout)
                                            .padding(2)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 2.0)
                                                    .stroke())
                                    }.foregroundColor(Color("CalendarOnColor"))
                                })
                            }
                            
                            WordPhoneticView(phonetic_EN: self.learningWordItem.sourceWord?.phonetic_EN ?? "no phonetic_EN", phonetic_US: self.learningWordItem.sourceWord?.phonetic_US ?? "no phonetic_US",fontSize: 18)
                                .padding(.top, -5)
                        }
                        
                        Spacer()
                    }.padding([.leading,.trailing],20)
                    

                    Divider()
                    
                    VStack(alignment:.leading){
                        
                        HStack {
                            WordTranslationView(wordTranslastion: self.learningWordItem.sourceWord?.translation ?? "no Trans", wordDefinition: self.learningWordItem.sourceWord?.definition ?? "no Def")
                            Spacer()
                        }
                    }.padding([.leading,.trailing],30)
                    
                    Divider()
                    
                    VStack(alignment:.leading){
                        Text("例句")
                            .font(.callout)
                            .foregroundColor(Color("WordSentencesColor"))
                        
                        WordExampleSentencesView(wordContent: self.learningWordItem.wordContent!, wordExampleSentences: self.learningWordItem.sourceWord?.exampleSentences ?? "noEXP",maxLine:1,showCH:true,color: Color(.clear))
                    }.padding([.leading,.trailing],30)
                    
                    Spacer()
                    
                    
                }
                
                
                
                Spacer()
                if(!afterUnknown){
                    VStack(alignment:.leading){
                        Text("输入正确的单词")
                            .font(.callout)
                            .foregroundColor(Color("WordSentencesColor"))
                    }.padding([.leading,.trailing],30)
                }
                
                Divider()
                // 底部按钮
                HStack {
                    Spacer()
                    //                        ZStack {
                    if(!afterUnknown){
                        HStack{
                            Button(action: {
                                self.afterUnknown = true
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .frame(width: UIScreen.main.bounds.width*0.25, height: 40, alignment: .center)
                                        .foregroundColor(Color(red: 245/255, green: 245/255, blue: 250/255))
                                    HStack {
                                        Image(systemName: "flame.fill")
                                        
                                        Text("不认识").font(.custom("FZDIHT_JW--GB1-0", size: 18,relativeTo: .body))
                                    }.foregroundColor(Color(.systemRed))
                                }
                            })
                            
                            Button(action: {
                                self.learnWordVM.nextCard_Review(item: self.learningWordItem)
                                
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .frame(width: UIScreen.main.bounds.width*0.25, height: 40, alignment: .center)
                                        .foregroundColor(Color(red: 245/255, green: 245/255, blue: 250/255))
                                    HStack {
                                        Image(systemName: "cloud.fill")
                                        Text("模糊").font(.custom("FZDIHT_JW--GB1-0", size: 18,relativeTo: .body))
                                    }.foregroundColor(Color(.systemBlue))
                                }
                            })
                            
                            Button(action: {
                                self.learningWordItem.todayReviewCount += 1
                                //从列表取出放回结尾
                                self.learnWordVM.nextCard_Review(item: self.learningWordItem)
                                if self.learningWordItem.todayReviewCount == 2{
                                    //页面的（进度）次数统计+1
                                    self.todayReviewCount =  self.todayReviewCount + 1
                                }
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .frame(width: UIScreen.main.bounds.width*0.25, height: 40, alignment: .center)
                                        .foregroundColor(Color(.systemGray6))
                                    
                                    HStack {
                                        Image(systemName: "leaf.fill")
                                            .renderingMode(.template)
                                            .font(.title3)
                                        Text("认识").font(.custom("FZDIHT_JW--GB1-0", size: 18,relativeTo: .body))
                                    } .foregroundColor(correctWord ? Color(.systemGreen) : Color(.systemGray))
                                    
                                }
                            }).disabled(correctWord ? false : true)
                        }
                    }
                    if(afterUnknown){
                        HStack {
                            //Spacer()
                            Button(action: {
                                self.learnWordVM.nextCard_Review(item: self.learningWordItem)
                                self.afterUnknown = false
                                
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .frame(width: UIScreen.main.bounds.width*0.75, height: 40, alignment: .center)
                                        .foregroundColor(Color.white)
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("记住了").font(.custom("FZDIHT_JW--GB1-0", size: 18,relativeTo: .title))
                                    }.foregroundColor(Color(.systemGreen))
                                }
                            })
                            //Spacer()
                        }
                    }
                    //                        }
                    Spacer()
                }
                .padding(10)
                .padding(.bottom,5)
                .background(afterUnknown ? Color(.systemGray6) : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                
                //                    }
            }//.padding(.top,0)
            
            
        }
        .frame(width: UIScreen.main.bounds.width - 20, alignment: .center)
        //.padding(.bottom, 15)
        
        
    }
}


struct ReviewCardView2_Previews: PreviewProvider {
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
                    ReviewCardView2(learningWordItem: learnWord, learnWordVM: LearnWordViewModel(), wordVM: WordViewModel(),afterUnknown: false, todayReviewCount: .constant(0))
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
