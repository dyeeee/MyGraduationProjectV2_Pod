//
//  WidgetWordVIew_Large.swift
//  MyGraduationProjectV2
//
//  Created by YES on 2021/3/12.
//
import WidgetKit
import SwiftUI

struct WidgetWordVIew_Large: View {
    let widgetWord: WidgetWord
    let color = [Color(.systemPurple),Color(.systemBlue)
                 ,Color(.systemTeal),Color(.systemIndigo),
                 Color(.systemOrange),Color(.systemPink)].randomElement()
    
    func dealExampleSentences_EN(str:String) -> [String] {
        let sentenceList = str.components(separatedBy: "<br>")
        var i = 0
        var sentenceList_EN:[String] = []
        
        while i<sentenceList.count {
            if (i % 2 == 0) {
                sentenceList_EN.append(sentenceList[i])
            }
            i = i + 1
        }
        return sentenceList_EN
    }
    
    func dealExampleSentences_CH(str:String) -> [String] {
        let sentenceList = str.components(separatedBy: "<br>")
        var i = 0
        var sentenceList_CH:[String] = []
        
        while i<sentenceList.count {
            if (i % 2 != 0) {
                sentenceList_CH.append(sentenceList[i])
            }
            i = i + 1
        }
        return sentenceList_CH
    }
    
    var body: some View {
        VStack(spacing:0) {
            //单词+音标
            HStack {
                VStack {
                    Text(widgetWord.wordContent)
                        .font(widgetWord.wordContent.count < 14 ? .title3 :.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.clear)
                        .overlay(Rectangle().frame(height:4)
                                    .foregroundColor(color)
                                    .offset(x:0,y:widgetWord.wordContent.count < 14 ? 7 : 6))
                }.overlay(
                    Text(widgetWord.wordContent)
                        .font(widgetWord.wordContent.count < 14 ? .title3 :.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("systemBlack"))
            )
            
                HStack(spacing:0) {
                    Image("EN")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 25, alignment: .trailing)
                    Text("\(dealEN_Widget(widgetWord.phonetic_EN))")
                        .font(.custom("Baskerville", size: 16,relativeTo: .body))
                    Spacer()
                }//.padding([.leading,.trailing],10)
                .foregroundColor(Color(.systemGray))
                
                Spacer()
                
   
            }
            

            //标签
            if widgetWord.wordTags != "nullTag" {
            HStack(spacing:3){
                ForEach(getTagsList_Widget(str: widgetWord.wordTags,limit: 10), id:\.self){
                    tag in
                    VStack {
                        Text(tag)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2.0)
                                    .stroke())
                    }.foregroundColor(Color("WordTagsColor"))
                }
                Spacer()
            }.padding([.trailing],0)
            .padding(.top,5)
            }
                
            Divider().padding(5).padding(.top,3)
            
            //英汉+英英
            HStack(alignment:.top) {
                VStack(alignment:.leading) {
                    Text("英汉释义")
                        .font(.caption2)
                        .padding(1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2.0)
                                .stroke())
                .foregroundColor(Color(.systemGray))
                    Text("\(dealTrans_Widget(widgetWord.translation))")
                        .font(.custom("Baskerville", size: 14,relativeTo: .body))
                        .padding(.top,-5)
                        //Spacer()
                }.padding([.trailing],5)
                Spacer(minLength: 0)

                VStack(alignment:.leading) {
                    Text("英英释义")
                        .font(.caption2)
                        .padding(1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2.0)
                                .stroke())
                .foregroundColor(Color(.systemGray))
                    Text("\(dealTrans_Widget(widgetWord.definition))")
                        .font(.custom("Baskerville", size: 14,relativeTo: .body))
                        .padding(.top,-5)
                        
                    //Spacer()
                        
                }//.padding([.leading],10)
            }.padding(.top,5)

            
            
            Divider().padding(5)
            
            //例句
            VStack(alignment:.leading,spacing:2) {
                    Text("例句")
                        .font(.caption2)
                        .padding(1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2.0)
                                .stroke())
                        .foregroundColor(Color(.systemGray))
                
                HighlightPartlyView(fullString: self.dealExampleSentences_EN(str: widgetWord.exampleSentences)[0], wordContent: widgetWord.wordContent,color: self.color!)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.callout)
                    
                
                    Text("\(self.dealExampleSentences_CH(str: widgetWord.exampleSentences)[0])")
                        //.opacity(0)
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color("systemBlack"))
//                            }
           
            
            }.padding(.top,5)
            Spacer()
            
            HStack {
                Spacer(minLength: 0)
                Text("by DYe")
            }.font(.custom("", size: 8,relativeTo: .caption2))
            .foregroundColor(Color(.systemGray2))
            //.padding([.trailing],15)
            .padding(.bottom,3)
            

        }.padding([.top],10)
        .padding([.leading,.trailing],15)
        
    }
}

struct WidgetWordVIew_Large_Previews: PreviewProvider {
    static var previews: some View {
        let demo = WidgetWord(wordContent: "abstract", phonetic_EN: "'æbstrækt", wordTags:"gk cet4 cet6 ky toefl ielts gre",definition: "/", translation: "a. 抽象的, 深奥的", exampleSentences: "Someone once told me a vivid and silly visualization can help people to understand an abstract concept. Let's see if it works. . .<br>曾有人告诉我一个明晰而无聊的可视物能帮助人们理解抽象的理论，让我们来看看当它工作时……<br>Abstract: traditional chinese medicine, known as an ancient medical science is marked by its obscurity and difficulty in terms of theory.")
        
        return Group{
            WidgetWordVIew_Large(widgetWord: demo)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            
        }
    }
}

